# This again, will have to be adapted based on your setup.

PROJECTS="$(grep 'aosip' .repo/manifests/manifests/caf.xml  | awk '{print $3}' | awk -F'"' '{print $2}')"
for project in ${PROJECTS}
do
    cd $project;
    git fetch aosip nougat;
    git push $(git remote -v | head -1 | awk '{print $2}' | sed -e 's/https:\/\/github.com\/AOSiP/ssh:\/\/localhost:29418\/AOSIP/') aosip/nougat:refs/heads/nougat;
    cd -;
done
