

container build workflow from phylotool

(there was older git repo cgmlstfinder_slimmed)

but anyway, seems like the dockerfile will pull the db 
so just need a cloud build for docker and then singulary to run it.

~~~

eg use:

docker pull ghcr.io/tin6150/cgmlstfinder:master

        docker run --rm -it \
       -v $cgMLST_DB:/database \
       -v $(pwd):/workdir \
       cgmlstfinder -o [OUTPUT PATH] -s [SPECIE] -db [DATABASE PATH] -t [TEMPORARY FILE] [INPUT/S FASTQ]



singularity pull --name cgmlstfinder.sif  docker://ghcr.io/tin6150/cgmlstfinder:master
                                                                                                                                
singularity run --bind ~tin//gs/tin-gh/cgmlstfinder_db/:/database  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i GCA_*.fna -s ecoli -db ~/gs/tin-gh/cgmlstfinder_db/ -o cgMlstFinder_Out
                                                                                                                                
singularity exec --bind ~tin//gs/tin-gh/cgmlstfinder_db/:/database  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  /bin/bash

ref:
stecusda/ run_EE1394_cgMlstFinder.sh for eg


