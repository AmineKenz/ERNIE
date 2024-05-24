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
python example.py