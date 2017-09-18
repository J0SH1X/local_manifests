cd device/qcom/sepolicy

git remote add lOS https://github.com/LineageOS/android_device_qcom_sepolicy

git fetch lOS

git cherry-pick 08a5a428fd55fa33370f31ace2a10a74817b5b2c

git cherry-pick 6ff8a5feb6d69d902d635ea07a043b8958996f7c

git cherry-pick 415717e1ff5df3528401621022566ca5b26cc587

cd ../../..
