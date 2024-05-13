filename=$(ls -Art /$HOME/Desktop/ss | tail -n 1)
echo "The file name is $filename"
cp "/$HOME/Desktop/ss/$filename" "/$HOME/Desktop/yxkd/assets/posts/gatech/nlp/$1"
echo "![image](../../../assets/posts/gatech/nlp/$1){: width='400' height='400'}" | pbcopy