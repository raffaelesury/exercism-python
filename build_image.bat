:: Tells docker to build the image based on a Dockerfile in the same location
:: Passes the file containing the Exercism token as a secret, and a name
docker build --secret id=mytoken,src=token.txt --tag exercism-python .