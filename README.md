# aqua_model

As an avid board gamer, I love planning and deliberating moves. But counting points at the end is less fun. With the auqa projects I want to automate this part for the [Aqualin](https://boardgamegeek.com/boardgame/295948/aqualin) game.

In Auqalin, two players place colorful underwater animals on a common game board to end up with the largest swarms. There are 36 tokens, six animals in six different colors. One player is trying to place the same animals next to each other, the other is making groups in the same color. At the end, someone has to count the swarm sizes. And this is where this project begins. 

In the **auqa_model** project an image recognition model is trained to classify each token on the board as one of the 36 tokens. In the **aqua_win** project this algorithm is used inside an app to calculate the scores and determine the winner. 

Considering possible copyright issues, the images used are not uploaded to this project.





# sources 

This is the first time fitting an image recognition modle therefore I used [this](https://www.r-bloggers.com/2021/03/how-to-build-your-own-image-recognition-app-with-r-part-1/) blog post by ApokalypsePartyTeam as a template.

# lessons learned - the not-to-do list

- don't underestimate the amount of images needed to train the model: In my naive mind the animals and colors seemed easy to distinguish and therefore hundreds of images won't be needed. I was wrong. 
- don't be to fixated to fit the one model: I planed one model to classify all 36 tokens at ones. Many categories means more time to process, more images and more aborted R seesions. Two models (one for animals and one for colors) will do it either. 
- don't ignore the hardware: My older laptop needed over an hour for one epoch, the new one needed six minutes.  
