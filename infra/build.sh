#
# THIS SCRIPT WAS CREATED FOR DEMONSTRATION PURPOSES ONLY.
# WHILE CONCEPTS MAY PROVIDE THE BASIS FOR PRODUCTION DEPLOYMENT
# SCRIPTS, IT IS NOT INTENDED FOR ANY PURPOSE OTHER THAN DEMONSTRATION
# IN ITS CURRENT FORM
#

# 
# build the npm package and zip the deployable application artifacts
# for use in the deployment. The folder "/build/Release" (relative to repo root)
# is included in the .gitignore so that build outputs will not be put in the repo
#
npm install ..
mkdir -p ../build/Release
zip -r ../build/Release/269.zip ../node_modules ../package-lock.json ../package.json ../server.js
