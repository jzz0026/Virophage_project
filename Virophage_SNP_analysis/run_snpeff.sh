## cp gff into folder
for i in $(ls ../../../../virophage/Virophages_fna_files/gff/| awk -F "." '{print $1}') ; do cp ../../../../virophage/Virophages_fna_files/gff/${i}.gff ./${i}/genes.gff ; done

## cp fasta file into genome (tools/snpEff_latest_core/snpEff/data/)
for i in $(ls ../../../../virophage/Virophages_fna_files/*_SNP.vcf| awk -F "_SNP.vcf" '{print $1}') ; do cp ${i}.fasta ./genomes/ ; done

## add genomes into config file
ls data/genomes/33000* | awk -F "/" '{print $3}' | awk -F "." '{print $1}' | xargs -I {} echo "{}.genome : virophage" >> snpEff.config 

## build database
ls data/genomes/33000* | awk -F "/" '{print $3}' | awk -F "." '{print $1}' | xargs -I {} java -jar snpEff.jar build -gff3 -v {}

## set path to snpeff
snpEff=/global/projectb/scratch/jzz0026/tools/snpEff_latest_core/snpEff

## filter SNP with reads < 4
Filter_SNP_reads_4.ipynb

## run snpeff for SNP with reads <4
for i in $(ls *_filter.vcf | awk -F "_SNP_nohead_filter.vcf" '{print $1}') ; do echo "cd $path/${i}_snpeff ; java -Xmx10g -jar $snpEff/snpEff.jar -c $snpEff/snpEff.config ${i} 
../${i}_SNP_nohead_filter.vcf > ${i}_snpeff.vcf -csvStats ${i}_snpeff_stats.csv" >> snpeff_script.sh;  done

while read i ; do sbatch -t 2880 --mincpus=1 --mem=8G -D $PWD -J snpeff --wrap="${i}" ; done < snpeff_script.sh 
