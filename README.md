# aqua_model

As an avid board gamer, I love planning and deliberating moves. But counting points at the end is less fun. With the auqa projects I want to automate this part for the [Aqualin](https://boardgamegeek.com/boardgame/295948/aqualin) game.

In Auqalin, two players place colorful underwater animals on a common game board to end up with the largest swarms. There are 36 tokens, six animals in six different colors. One player is trying to place the same animals next to each other, the other is making groups in the same color. At the end, someone has to count the swarm sizes. And this is where this project begins. 

In the **auqa_model** project image recognition models are trained to classify each token on the board by color and animal. In the **aqua_win** project these algorithms are used inside an app to calculate the scores and determine the winner. 

# collecting images and preparing datasets

Images for training and testing porpuses were taken by myself. All tokens were randomly placed on the game board. The image was taken of the whole board and croped with R (syntax: XXX). Two datsets with the same images where created, one sorted by animals (crab, fish, jellyfish, seahorse, starfish, tortoise) and one sorted by color (blue, green, red, pink, purple, yellow).  

120 images (20 for each of the 6 categories) were sampled for the test dataset (syntax: XXX). Preprocessing for the training dataset contained rotating each image by 0, 90, 180 and 270 degrees (syntax: XXX). Each category included between 2756 and 2992 images. 80% of the images where used as testing dataset, 20% as validation dataset. 

Considering possible copyright issues, the datasets/images used are not uploaded to this project.

# analysis

Two models were fitted - one for each player (animal vs. color). 


## animal model

![animal_classfication](https://user-images.githubusercontent.com/38466492/196999622-f8a4cbb5-6ae5-44f1-a0ae-d00788960318.svg)


## color model

![color_classification](https://user-images.githubusercontent.com/38466492/196999542-212a258f-a546-4103-8abf-a6e61195899a.svg)

# sources 

This is my first time fitting an image recognition model therefore I used [this](https://www.r-bloggers.com/2021/03/how-to-build-your-own-image-recognition-app-with-r-part-1/) blog post by ApokalypsePartyTeam as a template.

# lessons learned - the not-to-do list

- don't underestimate the amount of images needed to train the model: In my naive mind the animals and colors seemed easy to distinguish and therefore hundreds of images won't be needed. I was wrong. 
- don't be to fixated to fit the one model: I planed one model to classify all 36 tokens at ones. Many categories means more time to process, more images and more aborted R seesions. Two models (one for animals and one for colors) will do it eigther. 
- don't ignore the hardware: My older laptop needed over an hour for one epoch, the new one needed six minutes.  
