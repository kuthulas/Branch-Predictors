clear
date;

if [ ! -d "results/" ]; then
	mkdir "results/";
fi

rm -rf results/*;

file="results/plot_this";
if [ ! -f "$file" ] ; then
	touch "$file"
fi

# Part A

printf "Part A: 2lev Performance Comparison - A3 vs A2\n\n";
l1size=1; l2size=512; hsize=8;
bmarks=(bzip2 crafty equake fma3d);
tags=(A2 A3);

for tag in ${tags[@]}; do
	printf "Compiling ${tag} source\n";
	cp store/bpred_${tag}.c simplesim-3.0/bpred.c
	cd simplesim-3.0
	make config-alpha >& /dev/null
	make >& /dev/null
	cd ../spec2000args
	printf "%s" "\addplot coordinates {" >> "../$file";

	for bmark in ${bmarks[@]}; do
		printf "Simulating ${tag} for ${bmark}...";
		cd ${bmark}
		./RUN$bmark ../../simplesim-3.0/sim-outorder ../../spec2000binaries/${bmark}00.peak.ev6 -max:inst 50000000 -fastfwd 20000000 -redir:sim ../../results/${bmark}_${tag}_out -bpred 2lev -bpred:2lev ${l1size} ${l2size} ${hsize} 0 -bpred:ras 8 -bpred:btb 64 2	>& /dev/null
		printf "Done\n";
		hit=$(sed -n -e '/^bpred_2lev.bpred_dir_rate/{p;q;}' ../../results/${bmark}_${tag}_out | cut -c 30-35);
		cd ../ 
		hitp=`echo "$hit * 100" | bc`;
		printf "%s" "(${bmark},${hitp}) " >> "../$file";
	done
	printf "%s\n" "};" >> "../$file";
	cd ../
	printf "\n"
done

# Part B
printf "Part B: 2lev Performance Comparison - GAg GAp PAg PAp\n\n";

preds=(GAg GAp PAg PAp);
GAg=(1 512 9);
GAp=(1 512 6);
PAg=(8 512 9);
PAp=(8 512 6);

for pred in ${preds[@]}; do
	cd spec2000args
	l1size=$pred"[0]";
	l2size=$pred"[1]";
	hsize=$pred"[2]";
	printf "%s" "\addplot coordinates {" >> "../$file";

	for bmark in ${bmarks[@]}; do
		printf "Simulating ${pred} for ${bmark}...";
		cd ${bmark}
		./RUN$bmark ../../simplesim-3.0/sim-outorder ../../spec2000binaries/${bmark}00.peak.ev6 -max:inst 50000000 -fastfwd 20000000 -redir:sim ../../results/${bmark}_${pred}_out -bpred 2lev -bpred:2lev ${!l1size} ${!l2size} ${!hsize} 0 -bpred:ras 8 -bpred:btb 64 2	>& /dev/null
		printf "Done\n";
		hit=$(sed -n -e '/^bpred_2lev.bpred_dir_rate/{p;q;}' ../../results/${bmark}_${pred}_out | cut -c 30-35);
		cd ../ 
		hitp=`echo "$hit * 100" | bc`;
		printf "%s" "(${bmark},${hitp}) " >> "../$file";
	done
	printf "%s\n" "};" >> "../$file";
	cd ../
	printf "\n"
done

date;
printf "Completed\n"