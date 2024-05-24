#!/bin/sh

# Nom de la tâche
#SBATCH --job-name=ernie_example

# Temps maximum d'exécution (ici 100 heures)
#SBATCH --time=100:00:00

# Partition (ou queue) à utiliser
#SBATCH -p kepler

# Nombre de GPU à utiliser
#SBATCH --gres=gpu:3

# Fichiers de sortie et d'erreur
#SBATCH --output=./out_ernie_example.txt
#SBATCH --error=./err_ernie_example.txt

# Notifications par email
#SBATCH --mail-type=ALL # (BEGIN, END, FAIL or ALL)
#SBATCH --mail-user=mohamed-amine.kenzeddine@etu.univ-amu.fr




# Exécution du script Python
python3 run_fewrel.py   --do_train   --do_lower_case   --data_dir data/fewrel/   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 10   --output_dir output_fewrel   --fp16   --loss_scale 128
# evaluate
python3 eval_fewrel.py   --do_eval   --do_lower_case   --data_dir data/fewrel/   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 10   --output_dir output_fewrel   --fp16   --loss_scale 128