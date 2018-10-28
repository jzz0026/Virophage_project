
# coding: utf-8

import pandas as pd
import numpy as np

## IMG_ID to spid
ID_metagenome = pd.read_csv("../ID_metagenome_jamo.csv")
IMGID_to_spid = ID_metagenome[["taxon_oid","JGI Project ID / ITS SP ID"]]
IMGID_to_spid.columns = ["IMGID","SPID"]
IMGID_to_spid = IMGID_to_spid[IMGID_to_spid["SPID"] != 0]
IMGID_to_spid = IMGID_to_spid.astype("str")
IMGID_to_spid_dict = dict(zip(IMGID_to_spid["IMGID"],IMGID_to_spid["SPID"]))


## spid to path
spid_to_path = pd.read_csv("../ID_path.txt",sep=" ",header=None)
spid_to_path = spid_to_path[[0,1]]
spid_to_path.columns = ["SPID","path"]
spid_to_path = spid_to_path.astype("str")


#np.mean(spid_to_path["SPID"] == "3300000176") == 0


fasta_files = get_ipython().getoutput('ls ./*.fasta')
fasta_files = fasta_files[1:]
outfilename = "bbmap_cmd.txt"
outfile = open(outfilename, "w")

for i in fasta_files:
    IMGID = i.split("_")[0].split("/")[1]
    #IMGID = int(IMGID)
    #IMGID_to_spid[IMGID_to_spid["IMGID"] == IMGID]
    #print(IMGID)
    
    try:
        spid = IMGID_to_spid_dict[IMGID]
        if np.mean(spid_to_path["SPID"] == spid) != 0:
            outfile.write("bbmap.sh ref=" + i + " in=" + " in=".join(list(spid_to_path[spid_to_path["SPID"] == spid]["path"]))+" out="+i.split(".fasta")[0]+"_mapped.sam nodisk bs="+i.split(".fasta")[0]+".sh idtag=t ; bash "+i.split(".fasta")[0]+".sh ")
            outfile.write("; cat " + i.split(".fasta")[0] + "_mapped.sam" + "| grep -n \"YI:f:\" | awk -F \"YI:f:\" '{print $NF}' | sort -n > " + i.split(".fasta")[0]+ "_mappped_per.txt")
            outfile.write("; rm "+i.split(".fasta")[0] + "_mapped.sam"+ "\n")
    except:
        pass 
outfile.close()
        

