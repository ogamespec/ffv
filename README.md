Attempt to reverse engineer SNES FFV game.

Задача проекта - поверхностно пробежаться по всей массе кода игры, вычленить оттуда ключевые места и задокументировать. Особый интерес представляет боевая система и поведение монстров в бою.

Ну вот например где написано что Elf Cape дает офигенный уворот от физических атак? Большинство проходили игру на Optimum шмоте и про Elf Cape даже не знают. А сколько ещё загадок хранят в себе остальные итемы и навыки?

http://www.gamefaqs.com/snes/588331-final-fantasy-v/faqs/30040

http://psxdev.ru/images/wys/ffv_title_screen.jpg

== Game engine parts ==

||<img src="http://psxdev.ru/images/wys/ffv_world.jpg" width=150px> <img src="http://psxdev.ru/images/wys/ffv_field.jpg" width=150px>||<img src="http://psxdev.ru/images/wys/ffv_battle.jpg" width=250px>||<img src="http://psxdev.ru/images/wys/ffv_menu.jpg" width=250px>||<img src="http://psxdev.ru/images/wys/ffv_bgfx.jpg" width=250px>||
||[WorldMap]+[Field]=[Scene] C0:0000||[Battle] C1:0000, C2:0000||[Menu] C2:A000||[BGFX] C3:0000||

== Sound engine ==

  * C4:0000 - SPC init
  * C4:0004 - write to [00:1D00] 4 bytes before call: 
    * 01 nn 08 0F: play music #nn
    * 02 nn 0F 88: play SFX #nn
    * 80 40 08 0F: fade-out ?
    * F2 22 08 0F: ??

== ROM information ==

Used ROM : Final Fantasy V (J) [T+Eng1.1_RPGe].smc

(english translation by RGPe)

No SMC 512-byte header.

== ROM header (0xFFC0) ==

  * Game title : "FINAL FANTASY 5      "
  * ROM makeup byte : 21, 0b00100001, [HiROM]
  * ROM type: 02
  * ROM size: 0B
  * SRAM size: 03
  * Creator license ID code: 00 C3
  * Version #: 00
  * Checksum complement: 0D E0
  * Checksum: F2 1F

== Interrupt vectors ==

  * NMI: 0xCEE0
  * IRQ: 0xCEE4
  * [RESET]: 0xCEC0

Регистры SNES : http://en.wikibooks.org/wiki/Super_NES_Programming/SNES_Hardware_Registers

http://nocash.emubase.de/fullsnes.htm
