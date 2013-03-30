<?php
  $m = new SWFMovie();
  $m->setDimension(400, 100);
  $m->setBackground(0xff, 0xff, 0xff);

  $logo = new SWFSprite();
  $j = $m->add($logo);
  $j->setName("logo");

  $m->add(new SWFAction("loadMovie('splash-logo.php','logo');"));

  $step=0.1;
  for($i=0;;$i+=$step)
  {
	if($i>100)$i=100;
	$x=400-(400*$i/200)-200;	
	$y=100-(100*$i/200)-50;	
	$s=$i;
  	$m->add(new SWFAction("logo._rotation = $i; logo._xScale=$s; logo._yScale=$s; logo._x= $x; logo._y=$y;"));
	$m->nextFrame();
	$step*=1.2;
	if($i==100)break;
  }

  header('Content-type: application/x-shockwave-flash');
  $m->output();
?>
