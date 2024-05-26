#!/bin/sh

# Nom de la tâche
#SBATCH --job-name=ernie_example

# Temps maximum d'exécution (ici 100 heures)
#SBATCH --time=100:00:00

# Partition (ou queue) à utiliser
#SBATCH -p smp-opa

# Nombre de GPU à utiliser
#SBATCH --gres=gpu:3

# Fichiers de sortie et d'erreur
#SBATCH --output=./out_ernie_example.txt
#SBATCH --error=./err_ernie_example.txt

# Notifications par email
#SBATCH --mail-type=ALL # (BEGIN, END, FAIL or ALL)
#SBATCH --mail-user=mohamed-amine.kenzeddine@etu.univ-amu.fr




# Exécution du script Python
# Download Wikidump
  wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2
  # Download anchor2id
  wget -c https://cloud.tsinghua.edu.cn/f/6318808dded94818b3a1/?dl=1 -O anchor2id.txt
  # WikiExtractor
  python3 pretrain_data/WikiExtractor.py enwiki-latest-pages-articles.xml.bz2 -o pretrain_data/output -l --min_text_length 100 --filter_disambig_pages -it abbr,b,big --processes 4
  # Modify anchors with 4 processes
  python3 pretrain_data/extract.py 4
  # Preprocess with 4 processes
  python3 pretrain_data/create_ids.py 4
  # create instances
  python3 pretrain_data/create_insts.py 4
  # merge
  python3 code/merge.py

  # extract anchors
  python3 pretrain_data/utils.py get_anchors
  # query Mediawiki api using anchor link to get wikibase item id. For more details, see https://en.wikipedia.org/w/api.php?action=help.
  python3 pretrain_data/create_anchors.py 256
  # aggregate anchors
  python3 pretrain_data/utils.py agg_anchors

  python3 code/run_pretrain.py --do_train --data_dir pretrain_data/merge --bert_model bert_base --output_dir pretrain_out/ --task_name pretrain --fp16 --max_seq_length 256

  python3 code/run_fewrel.py   --do_train   --do_lower_case   --data_dir data/fewrel/   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 10   --output_dir output_fewrel   --fp16   --loss_scale 128
  # evaluate
  python3 code/eval_fewrel.py   --do_eval   --do_lower_case   --data_dir data/fewrel/   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 10   --output_dir output_fewrel   --fp16   --loss_scale 128

python3 code/run_tacred.py   --do_train   --do_lower_case   --data_dir data/tacred   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 4.0   --output_dir output_tacred   --fp16   --loss_scale 128 --threshold 0.4
# evaluate
python3 code/eval_tacred.py   --do_eval   --do_lower_case   --data_dir data/tacred   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 4.0   --output_dir output_tacred   --fp16   --loss_scale 128 --threshold 0.4

python3 code/run_typing.py    --do_train   --do_lower_case   --data_dir data/FIGER   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 2048   --learning_rate 2e-5   --num_train_epochs 3.0   --output_dir output_figer  --gradient_accumulation_steps 32 --threshold 0.3 --fp16 --loss_scale 128 --warmup_proportion 0.2
# evaluate
python3 code/eval_figer.py    --do_eval   --do_lower_case   --data_dir data/FIGER   --ernie_model ernie_base   --max_seq_length 256   --train_batch_size 2048   --learning_rate 2e-5   --num_train_epochs 3.0   --output_dir output_figer  --gradient_accumulation_steps 32 --threshold 0.3 --fp16 --loss_scale 128 --warmup_proportion 0.2

python3 code/run_typing.py    --do_train   --do_lower_case   --data_dir data/OpenEntity   --ernie_model ernie_base   --max_seq_length 128   --train_batch_size 16   --learning_rate 2e-5   --num_train_epochs 10.0   --output_dir output_open --threshold 0.3 --fp16 --loss_scale 128
# evaluate
python3 code/eval_typing.py   --do_eval   --do_lower_case   --data_dir data/OpenEntity   --ernie_model ernie_base   --max_seq_length 128   --train_batch_size 16   --learning_rate 2e-5   --num_train_epochs 10.0   --output_dir output_open --threshold 0.3 --fp16 --loss_scale 128

python3 code/score.py gold_file pred_file

# If you haven't installed tagme
pip install tagme
# Run example
python3 code/example.py
