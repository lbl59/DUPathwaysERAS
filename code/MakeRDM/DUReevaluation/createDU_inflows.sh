
#!/bin/bash
for R in {110..200..10}
do
	S=$(($R+9))
	#echo $R
	#echo $S

	ARRAY="#!/bin/bash\n\
	#SBATCH --job-name=SynGen\n\
	#SBATCH --output=./output/SynGen_$R.out\n\
	#SBATCH --error=./output/SynGen_$R.err\n\
	#SBATCH --nodes=1\n\
	#SBATCH --ntasks=1\n\
	#SBATCH --export=ALL\n\
	#SBATCH -t 1:00:00\n\
	#SBATCH --array=$R-$S\n\

	module load octave/6.3.0\n\
	time octave-cli ./generate_streamflows.m $SLURM_ARRAY_TASK_ID ./RDM_inflows_demands/RDM_$SLURM_ARRAY_TASK_ID/synthetic_inflows/ ../historical/"
	#echo $ARRAY
	echo -e $ARRAY | sbatch
	sleep 300
done

