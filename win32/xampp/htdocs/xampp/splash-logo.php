<?php
  $m = new SWFMovie();
  $m->setDimension(400, 100);
  $m->setBackground(0xff, 0xff, 0xff);

  $m->add(new SWFBitmap(fopen("img/xampp-logo.jpg", "rb")));

  for($i=0;$i<=100;$i++)
  {
	  $m->add(new SWFAction("alpha = $i;"));
	  $m->nextFrame();
  }

  header('Content-type: application/x-shockwave-flash');
  $m->output();
?>
