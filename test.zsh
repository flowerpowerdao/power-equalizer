#!/bin/zsh

number_of_assets=7777
batch_size=1000
k=1

# while [ $k -le $number_of_assets ]; do
#   echo "for asset in {$k..$(($k+$batch_size))}; do \
#   if [ \$asset -gt $number_of_assets ]; \
#     then break; \
#   fi; \
#   echo \"uploading asset \$asset\"; \
# done"
#   k=$(($k+$batch_size))
# done | parallel 

upload_assets() {
  for asset in {$k..$(($k+$batch_size))}; do \
    if [ $asset -gt $number_of_assets ]; \
      then break; \
    fi; \
    echo "uploading asset $asset"; \
  done
}

while [ $k -le $number_of_assets ]; do
  # echo "" | env_parallel upload_assets
  upload_assets &
  k=$(($k+$batch_size))
done 

wait
echo "done"

# doit() { echo "$@"; }
# echo "" | env_parallel doit 