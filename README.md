# :soccer: head-soccer-asm :soccer:

<p align="center">
<img src="https://github.com/oGabrielArruda/head-soccer-asm/blob/fa98a1593795d7b3511632499d9c0e0d9cf6b100/images/menu_image.png" 
data-canonical-src="https://gyazo.com/eb5c5741b6a9a16c692170a41a49c858.png" width="680" height="400" />
</p>



<p align="center">
  <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/oGabrielArruda/head-soccer-asm.svg">

  <img alt="GitHub language count" src="https://img.shields.io/github/languages/count/oGabrielArruda/head-soccer-asm.svg">

  <img alt="Repository size" src="https://img.shields.io/github/repo-size/oGabrielArruda/head-soccer-asm.svg">
  <a href="https://github.com/oGabrielArruda/head-soccer-asm/commits/master">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/oGabrielArruda/head-soccer-asm.svg">
  </a>

  <a href="https://github.com/oGabrielArruda/head-soccer-asm/issues">
    <img alt="Repository issues" src="https://img.shields.io/github/issues/oGabrielArruda/head-soccer-asm.svg">
  </a>

  <img alt="GitHub" src="https://img.shields.io/github/license/oGabrielArruda/head-soccer-asm.svg">
</p>

---
## :page_with_curl: Description

This game is a 1v1 soccer game, developed with MASM32. 

The game design and funtionalities are inspired on the Head Soccer mobile game.



## :arrow_down_small: Installation and Compiling

```bash
# If you have changed the code and want to compile it
runconverter.bat

# Just run the game
jogo.exe

```



## :man: Change characters photo

As you may have seen, the players images are me and my friend. To change the players image to whatever you want, there are two possibilities:


- Change it directly in the 'images' folder, by replacing player1.bmp and player2.bmp image files. 

- Modify the 'rsrc.rc' file, replacing ".\\images\\player1.bmp" and ".\\images\\player2.bmp" by the path of the new images.


Do the same thing if you want to change the ball image.

> <b> Reminder: </b> the default player image size is <b> 85x85 </b>.  And the ball image is <b> 45x45 </b>. If you are doing new characters or a new ball to the game,
they must be in this dimensions.


## :memo: License
[MIT](https://choosealicense.com/licenses/mit/)
