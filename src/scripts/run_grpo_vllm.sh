#!/bin/bash

# The latest vllm==0.7.2 is required for this script: pip3 install vllm==0.7.2 

export WANDB_PROJECT="r1-v"
export DEBUG_MODE="true"

# QWEN_PATH=checkpoints/Qwen/VL/Qwen2.5-VL-3B-Instruct
QWEN_PATH=checkpoints/Qwen/VL/Qwen2-VL-2B-Instruct
# DATA_PATH=playground/DocVQA-R1
DATA_PATH=playground/Clevr_CoGenT_TrainA_70K_Complex


OUTPUT_DIR=outputs
export LOG_PATH="./logs/vllm_run_2.txt"
RUN_NAME=r1v_test_2

# NOTE: you are expected to use X + 1 cards for X training proc and 1 vLLM proc 
# e.g., the visible devices should be 0,1,2,3,4 for 5 cards, and  --nproc_per_node="4"

CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 torchrun --nproc_per_node="7" \
    --nnodes="1" \
    --node_rank="0" \
    --master_addr="127.0.0.1" \
    --master_port="15001" \
    src/r1-v/src/open_r1/grpo.py \
    --output_dir $OUTPUT_DIR \
    --model_name_or_path $QWEN_PATH \
    --dataset_name $DATA_PATH \
    --max_prompt_length 512 \
    --max_completion_length 1024 \
    --temperature 1.0 \
    --num_generations 7 \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 2 \
    --logging_steps 1 \
    --bf16 \
    --report_to wandb \
    --gradient_checkpointing true \
    --attn_implementation sdpa \
    --max_pixels 400000 \
    --max_steps 13125 \
    --run_name $RUN_NAME \
    --save_steps 1000 \
    --save_only_model true \
    --use_vllm True \
    # --num_processes 8 \