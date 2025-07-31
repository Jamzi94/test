#!/bin/bash
# ==============================================================================
#      J.A.M.Z.I. AI STACK - CONFIGURATION & ASSET CATALOGUE
# ==============================================================================
# Ce fichier centralise tous les composants installables.
# Modifiez-le pour ajouter de nouveaux modèles, plugins, ou pour ajuster les packs.

# --- CATALOGUE DES COMPOSANTS DISPONIBLES ---

# 1. Modèles de Langage (Ollama)
# Clé = nom court, Valeur = nom complet sur le hub Ollama
declare -A OLLAMA_MODELS=(
    [codellama]="codellama:13b"
    [llama3]="llama3:latest"
    [mistral]="mistral:latest"
    [phi3]="phi3:medium"
    [dan-qwen]="https://huggingface.co/UnfilteredAI/DAN-Qwen3-1.7B/resolve/main/DAN-Qwen3-1.7B.Q4_K_M.gguf" # URL directe du fichier GGUF
)

# 2. Checkpoints ComfyUI (.safetensors, .ckpt)
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_CHECKPOINTS=(
    # Modèles de base originaux
    [sdxl-base]="https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors|comfyui/models/checkpoints/sd_xl_base_1.0.safetensors"
    [sdxl-refiner]="https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors|comfyui/models/checkpoints/sd_xl_refiner_1.0.safetensors"
    [sd15-pruned]="https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt|comfyui/models/checkpoints/v1-5-pruned-emaonly.ckpt"
    # Modèles vidéo originaux
    [svd-xt]="https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt/resolve/main/svd_xt.safetensors|comfyui/models/checkpoints/svd_xt.safetensors"
    [animatediff-v2]="https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt|comfyui/models/animatediff_models/mm_sd_v15_v2.ckpt" # Note: AnimateDiff va dans animatediff_models
    # Nouveaux modèles spécifiques
    [hidream-uncensored]="https://civitai.com/api/download/models/1795373|comfyui/models/checkpoints/HiDream-Uncensored.safetensors" # Ancien lien, sera mis à jour par hidream-dev-uncensored
    [wan-video-1.3b]="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2.1-T2V-1.3B.safetensors|comfyui/models/checkpoints/Wan2.1-T2V-1.3B.safetensors"
    [wan-video-1.4b-i2v-720p]="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2.1-I2V-1.4B-720P.safetensors|comfyui/models/checkpoints/Wan2.1-I2V-1.4B-720P.safetensors"
    [wan-video-1.4b-i2v-480p]="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2.1-I2V-1.4B-480P.safetensors|comfyui/models/checkpoints/Wan2.1-I2V-1.4B-480P.safetensors"
    [wan-fusionix]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan2.1_14B_FusionX.safetensors|comfyui/models/checkpoints/Wan2.1_14B_FusionX.safetensors"
    # Modèles identifiés dans les workflows et nouvelles analyses
    [hidream-dev-uncensored]="https://huggingface.co/e-n-v-y/hidream-uncensored/resolve/main/hidream_i1_dev_uncensored_fp8_v0.2.safetensors|comfyui/models/checkpoints/hidream_i1_dev_uncensored_fp8_v0.2.safetensors"
    [wan-1.3b-e20]="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_1.3B_fp16.safetensors?download=true|comfyui/models/checkpoints/wan_1.3B_e20.safetensors"
    [multitalk-model]="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/WanVideo_2_1_Multitalk_14B_fp8_e4m3fn.safetensors|comfyui/models/checkpoints/WanVideo_2_1_Multitalk_14B_fp8_e4m3fn.safetensors"
    # Modèles FusionX identifiés
    [wan-fusionix-phantom]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan14BT2VFusioniX_Phantom_fp16.safetensors|comfyui/models/checkpoints/Wan14BT2VFusioniX_Phantom_fp16.safetensors"
    [wan-fusionix-fp16]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan14BT2VFusioniX_fp16_.safetensors|comfyui/models/checkpoints/Wan14BT2VFusioniX_fp16_.safetensors"
    [wan-fusionix-base]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan14Bi2vFusioniX.safetensors|comfyui/models/checkpoints/Wan14Bi2vFusioniX.safetensors"
    [wan-fusionix-base-fp16]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan14Bi2vFusioniX_fp16.safetensors|comfyui/models/checkpoints/Wan14Bi2vFusioniX_fp16.safetensors"
    [wan-t2v-master]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/WanT2V_MasterModel.safetensors|comfyui/models/checkpoints/WanT2V_MasterModel.safetensors"
    # Liens directs confirmés NSFW-API
    [nsfw-realvisxl]="https://huggingface.co/NSFW-API/RealVisXL/resolve/main/realvisXL_v5.safetensors|comfyui/models/checkpoints/realvisXL_v5.safetensors"
    [nsfw-wan-retro-core]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Retro-Core/resolve/main/nsfw_wan_14b_retro_core.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_retro_core.safetensors"
    [nsfw-ponyrealism]="https://huggingface.co/NSFW-API/PonyRealism/resolve/main/pony_realism_23.safetensors|comfyui/models/checkpoints/pony_realism_23.safetensors"
    # Modèles NSFW-API confirmés OK (avec noms de fichiers corrigés)
    [nsfw-wan-14b-missionary-sex-french-kissing-position]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Missionary-Sex-French-Kissing-Position/resolve/main/nsfw_wan_14b_missionary_sex_french_kissing_position.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_missionary_sex_french_kissing_position.safetensors"
    [nsfw-wan-14b-spooning-leg-lifted-sex-position]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Spooning-Leg-Lifted-Sex-Position/resolve/main/nsfw_wan_14b_spooning_leg_lifted_sex_position.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_spooning_leg_lifted_sex_position.safetensors"
    [nsfw-wan-14b-panty-peel]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Panty-Peel/resolve/main/nsfw_wan_14b_panty_peel.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_panty_peel.safetensors"
    [nsfw-wan-14b-sex]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Sex/resolve/main/nsfw_wan_14b_sex.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_sex.safetensors"
    [nsfw-wan-14b-revealing-boobs]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Revealing-Boobs/resolve/main/nsfw_wan_14b_revealing_boobs.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_revealing_boobs.safetensors"
    [nsfw-wan-14b-cumshot-facials]="https://huggingface.co/NSFW-API/NSFW-Wan-14b-Cumshot-Facials/resolve/main/nsfw_wan_14b_cumshot_facials.safetensors|comfyui/models/checkpoints/nsfw_wan_14b_cumshot_facials.safetensors"
    [nsfw-base]="https://huggingface.co/NSFW-API/NSFW/resolve/main/nsfw.safetensors|comfyui/models/checkpoints/nsfw.safetensors"
    [lustify]="https://huggingface.co/NSFW-API/Lustify/resolve/main/lustify.safetensors|comfyui/models/checkpoints/lustify.safetensors"
    [eating-pussy]="https://huggingface.co/NSFW-API/eating_pussy/resolve/main/eating_pussy.safetensors|comfyui/models/checkpoints/eating_pussy.safetensors"
    [sex-helper-for-nsfw-wan-1.3b]="https://huggingface.co/NSFW-API/Sex_Helper_For_NSFW_Wan_1.3B/resolve/main/sex_helper_nsfw_wan_1_3b.safetensors?download=true|comfyui/models/checkpoints/sex_helper_nsfw_wan_1_3b.safetensors"
    [nsfw-wan-14b-fp8]="https://huggingface.co/NSFW-API/NSFW_Wan_14b/resolve/main/nsfw_wan_14b_e15_fp8.safetensors?download=true|comfyui/models/checkpoints/nsfw_wan_14b_e15_fp8.safetensors"
    [wan-1.3b-exp-e14]="https://huggingface.co/NSFW-API/NSFW_Wan_1.3b/resolve/main/wan_1.3B_exp_e14.safetensors?download=true|comfyui/models/checkpoints/wan_1_3B_exp_e14.safetensors"
    [futa-jerking-off]="https://huggingface.co/NSFW-API/FutaJerkingOff/resolve/main/futa_jerking_off.safetensors?download=true|comfyui/models/checkpoints/futa_jerking_off.safetensors"
    [futa-flacid]="https://huggingface.co/NSFW-API/FutaFlacid/resolve/main/futa_flacid.safetensors?download=true|comfyui/models/checkpoints/futa_flacid.safetensors"
    [facials-model]="https://huggingface.co/NSFW-API/Facials/resolve/main/Facials.safetensors?download=true|comfyui/models/checkpoints/Facials.safetensors"
    [doggy-facing-camera]="https://huggingface.co/NSFW-API/DoggyFacingCamera/resolve/main/doggy_facing_camera.safetensors?download=true|comfyui/models/checkpoints/doggy_facing_camera.safetensors"
    [revealing-boobs-model]="https://huggingface.co/NSFW-API/RevealingBoobs/resolve/main/revealing_boobs.safetensors?download=true|comfyui/models/checkpoints/revealing_boobs.safetensors"
    [futa-erect]="https://huggingface.co/NSFW-API/FutaErect/resolve/main/futa_erect.safetensors?download=true|comfyui/models/checkpoints/futa_erect.safetensors"
    [wan-undress]="https://huggingface.co/NSFW-API/WanUndress/resolve/main/WanUndress.safetensors?download=true|comfyui/models/checkpoints/WanUndress.safetensors"
    [wan-missionary-side]="https://huggingface.co/NSFW-API/WanMissionarySide/resolve/main/wan_missionary_side.safetensors?download=true|comfyui/models/checkpoints/wan_missionary_side.safetensors"
    [reverse-cowgirl-pov]="https://huggingface.co/NSFW-API/ReverseCowgirlPOV/resolve/main/reverse_cowgirl_pov.safetensors?download=true|comfyui/models/checkpoints/reverse_cowgirl_pov.safetensors"
    [missionary-side]="https://huggingface.co/NSFW-API/MissionarySide/resolve/main/missionary_side.safetensors?download=true|comfyui/models/checkpoints/missionary_side.safetensors"
    [breast-massage]="https://huggingface.co/NSFW-API/BreastMassage/resolve/main/BreastMassage.safetensors?download=true|comfyui/models/checkpoints/BreastMassage.safetensors"
    [cum-model]="https://huggingface.co/NSFW-API/Cum/resolve/main/Cum.safetensors?download=true|comfyui/models/checkpoints/Cum.safetensors"
    [female-masturbation]="https://huggingface.co/NSFW-API/FemaleMasturbation/resolve/main/female_masturbation.safetensors?download=true|comfyui/models/checkpoints/female_masturbation.safetensors"
    [pov-titjob]="https://huggingface.co/NSFW-API/POVTitjob/resolve/main/Titjob.safetensors?download=true|comfyui/models/checkpoints/Titjob.safetensors"
    [pov-blowjob]="https://huggingface.co/NSFW-API/POV_Blowjob/resolve/main/pov_bj.safetensors?download=true|comfyui/models/checkpoints/pov_bj.safetensors"
    [missionary-pov]="https://huggingface.co/NSFW-API/MissionaryPOV/resolve/main/MissionaryPOV.safetensors?download=true|comfyui/models/checkpoints/MissionaryPOV.safetensors"
    [touki]="https://huggingface.co/NSFW-API/Touki/resolve/main/Touki.safetensors?download=true|comfyui/models/checkpoints/Touki.safetensors"
    [facial-model-2]="https://huggingface.co/NSFW-API/Facial/resolve/main/Facial.safetensors?download=true|comfyui/models/checkpoints/Facial.safetensors"
    [reverse-cowgirl]="https://huggingface.co/NSFW-API/ReverseCowgirl/resolve/main/reverse_cowgirl.safetensors?download=true|comfyui/models/checkpoints/reverse_cowgirl.safetensors"
)

# 3. Modèles CLIP (Text Encoders, Vision Models)
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_CLIP=(
    [clip-vision-h]="https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/pytorch_model.safetensors|comfyui/models/clip_vision/clip_vision_h.safetensors"
    [umt5-xxl-fp8-e4m3fn]="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true|comfyui/models/clip/umt5-xxl-enc-fp8_e4m3fn.safetensors"
    [umt5-xxl-bf16]="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5-xxl-enc-bf16.safetensors?download=true|comfyui/models/clip/umt5-xxl-enc-bf16.safetensors"
    [llama-3.1-8b-instruct]="https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/text_encoder/model.safetensors|comfyui/models/clip/llama_3.1_8b_instruct_fp8_scaled.safetensors" # Placeholder, à confirmer
)

# 4. VAE ComfyUI
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_VAE=(
    [vae-ft-mse]="https://huggingface.co/stabilityai/sd-vae-ft-mse-840000-ema-pruned/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt|comfyui/models/vae/vae-ft-mse-840000-ema-pruned.ckpt"
    # Nouveaux VAE identifiés
    [wan-2.1-vae]="https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true|comfyui/models/vae/wan_2.1_vae.safetensors"
    [ae-vae]="https://huggingface.co/NSFW-API/CyberRealism/resolve/main/cyberrealisticXL_v11VAE.safetensors|comfyui/models/vae/ae.safetensors" # Lien direct confirmé
)

# 5. ControlNet Models
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_CONTROLNET=(
    [controlnet-openpose]="https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth|comfyui/models/controlnet/control_v11p_sd15_openpose.pth"
    [controlnet-depth]="https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth|comfyui/models/controlnet/control_v11f1p_sd15_depth.pth"
)

# 6. Upscale Models
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_UPSCALE=(
    [upscale-ultrasharp]="https://huggingface.co/lokCX/4x-UltraSharp/resolve/main/4x-UltraSharp.pth|comfyui/models/upscale_models/4x-UltraSharp.pth"
    [upscale-realesrgan]="https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus.pth|comfyui/models/upscale_models/RealESRGAN_x4plus.pth"
)

# 7. GFPGAN Models (Face Restoration)
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_GFPGAN=(
    [gfpgan-v1.4]="https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth|comfyui/models/gfpgan/weights/GFPGANv1.4.pth"
)

# 8. Wav2Lip Models (Lip Sync)
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_WAV2LIP=(
    [wav2lip-gan]="https://huggingface.co/Nekochu/Wav2Lip/resolve/main/wav2lip_gan.pth?download=true|comfyui/custom_nodes/ComfyUI_wav2lip/Wav2Lip/checkpoints/wav2lip_gan.pth"
    [s3fd]="https://huggingface.co/spaces/manavisrani07/gradio-lipsync-wav2lip/resolve/a9a9fcdf8d8812be592c40417812ac64fc6f13fa/face_detection/detection/sfd/s3fd.pth|comfyui/custom_nodes/ComfyUI_wav2lip/face_detection/detection/sfd/s3fd.pth"
)

# 9. LoRA ComfyUI
# Clé = nom court, Valeur = URL de téléchargement
declare -A MODELS_LORAS=(
    [hidream-skin]="https://civitai.com/api/download/models/1695611|comfyui/models/loras/HiDream-Skin-Detailer.safetensors"
    [hidream-photorealism]="https://civitai.com/api/download/models/1977271|comfyui/models/loras/Hi-Dream-Photorealism.safetensors"
    # Nouveaux LoRAs identifiés
    [wan-lightx2v-lora]="https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors|comfyui/models/loras/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors"
    [wan-revealing-boobs]="https://huggingface.co/NSFW-API/RevealingBoobs/resolve/main/revealingboobs.safetensors|comfyui/models/loras/revealing_boobs.safetensors" # Lien direct confirmé
    [hidream-dora-dicks]="https://huggingface.co/NSFW-API/hidream_dora_with_dicks_000008500_nostyle/resolve/main/hidream_dora_with_dicks_000008500_nostyle.safetensors|comfyui/models/loras/hidream_dora_with_dicks_000008500_nostyle.safetensors" # Supposé
    [wan-causvid-lora]="https://huggingface.co/vrgamedevgirl84/Wan14BT2VFusioniX/resolve/main/Wan21_CausVid_14B_T2V_lora_rank32.safetensors|comfyui/models/loras/Wan21_CausVid_14B_T2V_lora_rank32.safetensors"
    # LoRAs NSFW-API confirmées OK (avec noms de fichiers corrigés)
    [nsfw-wan-14b-lora]="https://huggingface.co/NSFW-API/NSFW_Wan_14b/resolve/main/nsfw_lora_wan_14b_e15.safetensors?download=true|comfyui/models/loras/nsfw_lora_wan_14b_e15.safetensors"
    [nsfw-wan-1.3b-lora]="https://huggingface.co/NSFW-API/NSFW_Wan_1.3b/resolve/main/nsfw_lora_wan_1.3b.safetensors?download=true|comfyui/models/loras/nsfw_lora_wan_1.3b.safetensors"
)

# 10. Plugins ComfyUI (Nœuds Personnalisés)
# Clé = nom court, Valeur = URL du dépôt Git
declare -A PLUGINS_GIT=(
    [manager]="https://github.com/ltdrdata/ComfyUI-Manager"
    [multitalk]="https://github.com/MeiGen-AI/MultiTalk"
    [comfyui-wav2lip]="https://github.com/Fannovel16/ComfyUI-wav2lip" # Ajouté pour Wav2Lip
    [animatediff-evolved]="https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved" # Ajouté pour AnimateDiff
    # Nouveaux plugins identifiés
    [audio-separation-nodes]="https://github.com/christian-byrne/audio-separation-nodes-comfyui"
    [comfyui-videohelpersuite]="https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    [comfyui-kjnodes]="https://github.com/kijai/ComfyUI-KJNodes"
    [comfyui-easy-use]="https://github.com/comfyanonymous/ComfyUI-Easy-Use"
    [was-node-suite]="https://github.com/WASasquatch/was-node-suite-comfyui"
    [cg-use-everywhere]="https://github.com/chrisgode/ComfyUI-Custom-Nodes-for-Use-Everywhere"
    [comfyui-dynamicprompts]="https://github.com/cbaoth/ComfyUI-DynamicPrompts"
    [comfyui-sampler-lcm-alternative]="https://github.com/ltdrdata/ComfyUI-Sampler-LCM-Alternative"
)

# 11. Workflows ComfyUI
# Clé = nom court, Valeur = URL de téléchargement directe (Patreon) ou chemin local (user_assets)
declare -A WORKFLOWS_COMFYUI=(
    [hidream-nsfw-guide]="https://www.patreon.com/file?h=133572160&m=495725419|comfyui/workflows/HiDream_NSFW_Guide.json"
    [multitalk-guide]="https://www.patreon.com/file?h=134078791&m=499215565|comfyui/workflows/MultiTalk_Guide.json"
    [wan-uncensored-t2v-patreon]="https://www.patreon.com/file?h=132402988&m=491547310|comfyui/workflows/Wan_Uncensored_T2V_Patreon.json"
    # Workflows locaux
    [multitalk-i2v]="file://$BASE_DIR/user_assets/comfyui_workflows/MultitalkI2V (1).json|comfyui/workflows/MultitalkI2V.json"
    [t2v-wan-uncensored-ai-verse]="file://$BASE_DIR/user_assets/comfyui_workflows/T2V Wan uncensored Ai Verse.json|comfyui/workflows/T2V_Wan_Uncensored_Ai_Verse.json"
    [uncensored-hidream-custom]="file://$BASE_DIR/user_assets/comfyui_workflows/Uncensored Hi Dream Custom.json|comfyui/workflows/Uncensored_Hi_Dream_Custom.json"
    [uncensored-hidream-llama]="file://$BASE_DIR/user_assets/comfyui_workflows/Uncensored Hi Dream Onlu LLama(1).json|comfyui/workflows/Uncensored_Hi_Dream_Only_LLama.json"
    [wan-causvid-uncensored-ai-verse]="file://$BASE_DIR/user_assets/comfyui_workflows/wan + causvid Uncensored Ai Verse (1).json|comfyui/workflows/Wan_Causvid_Uncensored_Ai_Verse.json"
)

# 12. Workflows n8n
# Clé = nom court, Valeur = chemin local (user_assets)
declare -A WORKFLOWS_N8N=(
    [my-workflow-6]="file://$BASE_DIR/user_assets/n8n_workflows/My workflow 6.json|n8n/workflows/My_workflow_6.json"
)

# --- DÉFINITION DES PACKS DE CAPACITÉS (Briques de construction internes) ---

# Pack de base pour la génération d'images (SDXL, SD1.5, VAE)
CAPABILITY_PACK_FOUNDATION_MODELS_CHECKPOINTS="sdxl-base sdxl-refiner sd15-pruned"
CAPABILITY_PACK_FOUNDATION_MODELS_VAE="vae-ft-mse"

# Pack d'amélioration de la qualité (Upscalers, GFPGAN)
CAPABILITY_PACK_ENHANCEMENT_MODELS_UPSCALE="upscale-ultrasharp upscale-realesrgan"
CAPABILITY_PACK_ENHANCEMENT_MODELS_GFPGAN="gfpgan-v1.4"
CAPABILITY_PACK_ENHANCEMENT_PLUGINS=""

# Pack d'animation et de contrôle (SVD, AnimateDiff, ControlNet)
CAPABILITY_PACK_ANIMATION_MODELS_CHECKPOINTS="svd-xt animatediff-v2"
CAPABILITY_PACK_ANIMATION_MODELS_CONTROLNET="controlnet-openpose controlnet-depth"
CAPABILITY_PACK_ANIMATION_PLUGINS="animatediff-evolved"

# Pack de synchronisation labiale (Wav2Lip)
CAPABILITY_PACK_LIP_SYNC_MODELS_WAV2LIP="wav2lip-gan s3fd"
CAPABILITY_PACK_LIP_SYNC_PLUGINS="comfyui-wav2lip"

# --- DÉFINITION DES PACKS DE PRODUCTION (Présentés à l'utilisateur) ---

# Pack 1: IA Conversatonnelle
PACK_LLM_CORE_SERVICES="ollama open-webui"
PACK_LLM_CORE_MODELS_OLLAMA="llama3 mistral codellama"

# Pack 2: Usine d'Automatisation
PACK_AUTOMATION_CORE_SERVICES="n8n postgres redis"
PACK_AUTOMATION_WORKFLOWS_N8N="my-workflow-6"

# Pack 3: Studio Créatif de Base (Images SFW de haute qualité)
PACK_CREATIVE_BASE_SERVICES="comfyui"
PACK_CREATIVE_BASE_PLUGINS="manager ${CAPABILITY_PACK_ENHANCEMENT_PLUGINS}" # Ajout des plugins d'amélioration
PACK_CREATIVE_BASE_MODELS_CHECKPOINTS="${CAPABILITY_PACK_FOUNDATION_MODELS_CHECKPOINTS}"
PACK_CREATIVE_BASE_MODELS_VAE="${CAPABILITY_PACK_FOUNDATION_MODELS_VAE}"
PACK_CREATIVE_BASE_MODELS_UPSCALE="${CAPABILITY_PACK_ENHANCEMENT_MODELS_UPSCALE}"
PACK_CREATIVE_BASE_MODELS_GFPGAN="${CAPABILITY_PACK_ENHANCEMENT_MODELS_GFPGAN}"

# Pack 4: Studio Vidéo Avancé (SFW)
PACK_VIDEO_ADVANCED_SFW_SERVICES="comfyui n8n postgres redis"
PACK_VIDEO_ADVANCED_SFW_PLUGINS="manager multitalk ${CAPABILITY_PACK_ANIMATION_PLUGINS} ${CAPABILITY_PACK_LIP_SYNC_PLUGINS} audio-separation-nodes comfyui-videohelpersuite comfyui-kjnodes comfyui-easy-use was-node-suite cg-use-everywhere comfyui-dynamicprompts comfyui-sampler-lcm-alternative"
PACK_VIDEO_ADVANCED_SFW_MODELS_CHECKPOINTS="${CAPABILITY_PACK_FOUNDATION_MODELS_CHECKPOINTS} ${CAPABILITY_PACK_ANIMATION_MODELS_CHECKPOINTS} wan-video-1.3b wan-video-1.4b-i2v-720p wan-fusionix wan-1.3b-e20 multitalk-model"
PACK_VIDEO_ADVANCED_SFW_MODELS_CLIP="clip-vision-h umt5-xxl-fp8-e4m3fn umt5-xxl-bf16 llama-3.1-8b-instruct"
PACK_VIDEO_ADVANCED_SFW_MODELS_VAE="${CAPABILITY_PACK_FOUNDATION_MODELS_VAE} wan-2.1-vae ae-vae"
PACK_VIDEO_ADVANCED_SFW_MODELS_CONTROLNET="${CAPABILITY_PACK_ANIMATION_MODELS_CONTROLNET}"
PACK_VIDEO_ADVANCED_SFW_MODELS_UPSCALE="${CAPABILITY_PACK_ENHANCEMENT_MODELS_UPSCALE}"
PACK_VIDEO_ADVANCED_SFW_MODELS_GFPGAN="${CAPABILITY_PACK_ENHANCEMENT_MODELS_GFPGAN}"
PACK_VIDEO_ADVANCED_SFW_MODELS_WAV2LIP="${CAPABILITY_PACK_LIP_SYNC_MODELS_WAV2LIP}"
PACK_VIDEO_ADVANCED_SFW_MODELS_LORAS="wan-lightx2v-lora wan-causvid-lora"
PACK_VIDEO_ADVANCED_SFW_WORKFLOWS_COMFYUI="multitalk-guide multitalk-i2v t2v-wan-uncensored-ai-verse wan-causvid-uncensored-ai-verse"
PACK_VIDEO_ADVANCED_SFW_WORKFLOWS_N8N="my-workflow-6"

# Pack 5: Atelier d'Images Photoréalistes (NSFW)
PACK_IMAGE_PHOTOREAL_NSFW_SERVICES="comfyui ollama open-webui"
PACK_IMAGE_PHOTOREAL_NSFW_PLUGINS="manager comfyui-easy-use was-node-suite cg-use-everywhere comfyui-dynamicprompts comfyui-sampler-lcm-alternative"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_OLLAMA="dan-qwen"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_CHECKPOINTS="${CAPABILITY_PACK_FOUNDATION_MODELS_CHECKPOINTS} hidream-uncensored hidream-dev-uncensored nsfw-realvisxl nsfw-wan-retro-core nsfw-ponyrealism"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_CLIP="llama-3.1-8b-instruct"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_VAE="${CAPABILITY_PACK_FOUNDATION_MODELS_VAE} ae-vae"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_UPSCALE="${CAPABILITY_PACK_ENHANCEMENT_MODELS_UPSCALE}"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_GFPGAN="${CAPABILITY_PACK_ENHANCEMENT_MODELS_GFPGAN}"
PACK_IMAGE_PHOTOREAL_NSFW_MODELS_LORAS="hidream-skin hidream-photorealism hidream-dora-dicks wan-revealing-boobs"
PACK_IMAGE_PHOTOREAL_NSFW_WORKFLOWS_COMFYUI="hidream-nsfw-guide uncensored-hidream-custom uncensored-hidream-llama"

# Pack 6: Studio Vidéo Complet (NSFW)
PACK_VIDEO_FULL_NSFW_SERVICES="comfyui ollama open-webui n8n postgres redis"
PACK_VIDEO_FULL_NSFW_PLUGINS="manager multitalk ${CAPABILITY_PACK_ANIMATION_PLUGINS} ${CAPABILITY_PACK_LIP_SYNC_PLUGINS} audio-separation-nodes comfyui-videohelpersuite comfyui-kjnodes comfyui-easy-use was-node-suite cg-use-everywhere comfyui-dynamicprompts comfyui-sampler-lcm-alternative"
PACK_VIDEO_FULL_NSFW_MODELS_OLLAMA="dan-qwen"
PACK_VIDEO_FULL_NSFW_MODELS_CHECKPOINTS="${CAPABILITY_PACK_FOUNDATION_MODELS_CHECKPOINTS} ${CAPABILITY_PACK_ANIMATION_MODELS_CHECKPOINTS} hidream-uncensored wan-video-1.3b wan-video-1.4b-i2v-720p wan-fusionix hidream-dev-uncensored wan-1.3b-e20 multitalk-model nsfw-realvisxl nsfw-wan-retro-core nsfw-ponyrealism nsfw-wan-14b-missionary-sex-french-kissing-position nsfw-wan-14b-spooning-leg-lifted-sex-position nsfw-wan-14b-panty-peel nsfw-wan-14b-sex nsfw-wan-14b-revealing-boobs nsfw-wan-14b-cumshot-facials nsfw-base lustify eating-pussy sex-helper-for-nsfw-wan-1.3b nsfw-wan-14b-fp8 wan-1.3b-exp-e14 futa-jerking-off futa-flacid facials-model doggy-facing-camera revealing-boobs-model futa-erect wan-undress wan-missionary-side reverse-cowgirl-pov missionary-side breast-massage cum-model female-masturbation pov-titjob pov-blowjob missionary-pov touki facial-model-2 reverse-cowgirl"
PACK_VIDEO_FULL_NSFW_MODELS_CLIP="clip-vision-h umt5-xxl-fp8-e4m3fn umt5-xxl-bf16 llama-3.1-8b-instruct"
PACK_VIDEO_FULL_NSFW_MODELS_VAE="${CAPABILITY_PACK_FOUNDATION_MODELS_VAE} wan-2.1-vae ae-vae"
PACK_VIDEO_FULL_NSFW_MODELS_CONTROLNET="${CAPABILITY_PACK_ANIMATION_MODELS_CONTROLNET}"
PACK_VIDEO_FULL_NSFW_MODELS_UPSCALE="${CAPABILITY_PACK_ENHANCEMENT_MODELS_UPSCALE}"
PACK_VIDEO_FULL_NSFW_MODELS_GFPGAN="${CAPABILITY_PACK_ENHANCEMENT_MODELS_GFPGAN}"
PACK_VIDEO_FULL_NSFW_MODELS_WAV2LIP="${CAPABILITY_PACK_LIP_SYNC_MODELS_WAV2LIP}"
PACK_VIDEO_FULL_NSFW_MODELS_LORAS="hidream-skin hidream-photorealism wan-lightx2v-lora wan-revealing-boobs hidream-dora-dicks wan-causvid-lora nsfw-wan-14b-lora nsfw-wan-1.3b-lora"
PACK_VIDEO_FULL_NSFW_WORKFLOWS_COMFYUI="hidream-nsfw-guide multitalk-guide wan-uncensored-t2v-patreon multitalk-i2v t2v-wan-uncensored-ai-verse uncensored-hidream-custom uncensored-hidream-llama wan-causvid-uncensored-ai-verse"
PACK_VIDEO_FULL_NSFW_WORKFLOWS_N8N="my-workflow-6"

# Pack 7: Déploiement Total (Le vrai "Full Monty")
PACK_FULL_MONTY_SERVICES="ollama open-webui comfyui n8n postgres redis"
PACK_FULL_MONTY_PLUGINS="manager multitalk comfyui-wav2lip animatediff-evolved audio-separation-nodes comfyui-videohelpersuite comfyui-kjnodes comfyui-easy-use was-node-suite cg-use-everywhere comfyui-dynamicprompts comfyui-sampler-lcm-alternative"
PACK_FULL_MONTY_MODELS_OLLAMA="codellama llama3 mistral phi3 dan-qwen"
PACK_FULL_MONTY_MODELS_CHECKPOINTS="sdxl-base sdxl-refiner sd15-pruned svd-xt animatediff-v2 hidream-uncensored wan-video-1.3b wan-video-1.4b-i2v-720p wan-video-1.4b-i2v-480p wan-fusionix hidream-dev-uncensored wan-1.3b-e20 multitalk-model nsfw-realvisxl nsfw-wan-retro-core nsfw-ponyrealism nsfw-wan-14b-missionary-sex-french-kissing-position nsfw-wan-14b-spooning-leg-lifted-sex-position nsfw-wan-14b-panty-peel nsfw-wan-14b-sex nsfw-wan-14b-revealing-boobs nsfw-wan-14b-cumshot-facials nsfw-base lustify eating-pussy sex-helper-for-nsfw-wan-1.3b nsfw-wan-14b-fp8 wan-1.3b-exp-e14 futa-jerking-off futa-flacid facials-model doggy-facing-camera revealing-boobs-model futa-erect wan-undress wan-missionary-side reverse-cowgirl-pov missionary-side breast-massage cum-model female-masturbation pov-titjob pov-blowjob missionary-pov touki facial-model-2 reverse-cowgirl"
PACK_FULL_MONTY_MODELS_CLIP="clip-vision-h umt5-xxl-fp8-e4m3fn umt5-xxl-bf16 llama-3.1-8b-instruct"
PACK_FULL_MONTY_MODELS_VAE="vae-ft-mse wan-2.1-vae ae-vae"
PACK_FULL_MONTY_MODELS_CONTROLNET="controlnet-openpose controlnet-depth"
PACK_FULL_MONTY_MODELS_UPSCALE="upscale-ultrasharp upscale-realesrgan"
PACK_FULL_MONTY_MODELS_GFPGAN="gfpgan-v1.4"
PACK_FULL_MONTY_MODELS_WAV2LIP="wav2lip-gan s3fd"
PACK_FULL_MONTY_MODELS_LORAS="hidream-skin hidream-photorealism wan-lightx2v-lora wan-revealing-boobs hidream-dora-dicks wan-causvid-lora nsfw-wan-14b-lora nsfw-wan-1.3b-lora"
PACK_FULL_MONTY_WORKFLOWS_COMFYUI="hidream-nsfw-guide multitalk-guide wan-uncensored-t2v-patreon multitalk-i2v t2v-wan-uncensored-ai-verse uncensored-hidream-custom uncensored-hidream-llama wan-causvid-uncensored-ai-verse"
PACK_FULL_MONTY_WORKFLOWS_N8N="my-workflow-6"
