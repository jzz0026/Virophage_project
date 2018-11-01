## README

### bbmap and samtools SNP calling
### 1. run the script for bbamp, getting identities, coverages and SNP of mapped reads
./run_script.sh

### 2. Plot percentage against freqency and SNP against coverage
Plot_per_freq_and_SNP_cov.ipynb

### SNPeff for synonymous/non-synonymous SNP 
### 3. SNPeff
./run_snpeff.sh
while read i ; do sbatch -t 2880 --mincpus=1 --mem=8G -D $PWD -J snpeff --wrap="${i}" ; done < snpeff_script.sh

### 4. calculate synonymous/non-synonymous for each gene
Calculate S_N sites.ipynb