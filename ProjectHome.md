Attempt to reverse engineer SNES FFV game.

Задача проекта - поверхностно пробежаться по всей массе кода игры, вычленить оттуда ключевые места и задокументировать. Особый интерес представляет боевая система и поведение монстров в бою.

Ну вот например где написано что Elf Cape дает офигенный уворот от физических атак? Большинство проходили игру на Optimum шмоте и про Elf Cape даже не знают. А сколько ещё загадок хранят в себе остальные итемы и навыки?

http://www.gamefaqs.com/snes/588331-final-fantasy-v/faqs/30040

![http://psxdev.ru/images/wys/ffv_title_screen.jpg](http://psxdev.ru/images/wys/ffv_title_screen.jpg)

## Game engine parts ##

|<img src='http://psxdev.ru/images/wys/ffv_world.jpg' width='150px'> <img src='http://psxdev.ru/images/wys/ffv_field.jpg' width='150px'><table><thead><th><img src='http://psxdev.ru/images/wys/ffv_battle.jpg' width='250px'></th><th><img src='http://psxdev.ru/images/wys/ffv_menu.jpg' width='250px'></th><th><img src='http://psxdev.ru/images/wys/ffv_bgfx.jpg' width='250px'></th></thead><tbody>
<tr><td><a href='WorldMap.md'>WorldMap</a>+<a href='Field.md'>Field</a>=<a href='Scene.md'>Scene</a> C0:0000</td><td><a href='Battle.md'>Battle</a> C1:0000, C2:0000</td><td><a href='Menu.md'>Menu</a> C2:A000</td><td><a href='BGFX.md'>BGFX</a> C3:0000</td></tr></tbody></table>

<h2>Sound engine</h2>

<ul><li>C4:0000 - SPC init<br>
</li><li>C4:0004 - write to [00:1D00] 4 bytes before call:<br>
<ul><li>01 nn 08 0F: play music #nn<br>
</li><li>02 nn 0F 88: play SFX #nn<br>
</li><li>80 40 08 0F: fade-out ?<br>
</li><li>F2 22 08 0F: ??</li></ul></li></ul>

<h2>ROM information</h2>

Used ROM : Final Fantasy V (J) [T+Eng1.1_RPGe].smc<br>
<br>
(english translation by RGPe)<br>
<br>
No SMC 512-byte header.<br>
<br>
<h2>ROM header (0xFFC0)</h2>

<ul><li>Game title : "FINAL FANTASY 5      "<br>
</li><li>ROM makeup byte : 21, 0b00100001, <a href='HiROM.md'>HiROM</a>
</li><li>ROM type: 02<br>
</li><li>ROM size: 0B<br>
</li><li>SRAM size: 03<br>
</li><li>Creator license ID code: 00 C3<br>
</li><li>Version #: 00<br>
</li><li>Checksum complement: 0D E0<br>
</li><li>Checksum: F2 1F</li></ul>

<h2>Interrupt vectors</h2>

<ul><li>NMI: 0xCEE0<br>
</li><li>IRQ: 0xCEE4<br>
</li><li><a href='RESET.md'>RESET</a>: 0xCEC0</li></ul>

Регистры SNES : <a href='http://en.wikibooks.org/wiki/Super_NES_Programming/SNES_Hardware_Registers'>http://en.wikibooks.org/wiki/Super_NES_Programming/SNES_Hardware_Registers</a>

<a href='http://nocash.emubase.de/fullsnes.htm'>http://nocash.emubase.de/fullsnes.htm</a>