## wirte run bbmap script, bbmap_cmd.txt
python wirte_bbmap_script.py

## modified to cmd only mapping info, no sam/bam files
cat bbmap_cmd.txt | sed "s/out=.*.sam//g" | sed "s/bs=.*//g" > bbmap_cmd_only_info.txt

## run bbmap only info
while read i ; do echo "sbatch -t 2880 --mincpus=8 --mem=128G -D $PWD -J meta_spades --wrap="${i}"" ; done < bbmap_cmd.txt

## get ref with > 60000bp of mapped reads
ls *.out | xargs -I {} grep "mapped:" {} -H | sort -k 5 | awk '{ if ($5 > 30000) { print } }' | awk -F ":" '{print $1}' | sort | uniq > mapped_30000bp_reads.txt
cat mapped_30000bp_reads.txt | xargs -I {} grep 'ref=./' {} | awk -F "ref=./" '{print $2}' | awk -F "," '{print $1}' |awk -F " " '{print $1}' | sort | uniq > mapped_30000bp_reads_ref.txt 

## grep cmd based on selected reference
cat mapped_30000bp_reads_ref.txt | xargs -I {} grep {} bbmap_cmd.txt > bbmap_cmd_mapped_30000bp_reads_ref.txt


## run bbmap for genomes with > 60000bp of mapped reads, output sam bam 
while read i ; do sbatch -t 2880 --mincpus=8 --mem=128G -D $PWD -J bbmap --wrap="${i}" ; done < bbmap_cmd_mapped_30000bp_reads_ref.txt

## run bedtools to generate genomecov for each position
for i in $(ls *.bam | awk -F "." '{print $1}') ; do sbatch -t 2880 --mincpus=8 --mem=128G -D $PWD -J bedtools --wrap="bedtools genomecov -ibam ${i}.bam -d > ${i}_coverage.bed" ; done
