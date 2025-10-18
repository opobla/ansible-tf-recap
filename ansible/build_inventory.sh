
# [web_servers]
# web-1 ansible_host=130.211.81.175
# web-2 ansible_host=104.199.45.83
# web-3 ansible_host=34.38.124.77
# web-4 ansible_host=35.187.68.111
# web-5 ansible_host=34.38.254.104

WEB_SERVER_IPS=$(gcloud compute instances list --format=json --filter="tags.items:web-server" | jq '.[].networkInterfaces[].accessConfigs[0].natIP')

echo "[web_servers"]

INDEX=1

for IP in $WEB_SERVER_IPS
do
    echo "web-$INDEX ansible_host=$IP"
    INDEX=$(($INDEX + 1))
done

cat << EOF
[web_servers:vars]
ansible_user=ogarcia
ansible_ssh_private_key_file=../tf/terraform-key
EOF
