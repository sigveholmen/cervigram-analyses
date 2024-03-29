// This macro will output binary skeletons of blood vessels identified in a cervigram

dir1 = getDirectory("Choose Source Directory ");
list = getFileList(dir1);
dir2 = getDirectory("Choose Destination Directory ");

setBatchMode(true);

erode = 4;
dilate = 14;

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

filepath = dir2 +"resultater_Kolposkopi_"+dayOfMonth+"."+month+"_"+hour+"."+minute+".txt";

outputFile = File.open(filepath);
print(outputFile, "File	satMean	satMin	satMax	greenMean	greenMin	greenMax	blueMean	blueMin	blueMax");
File.close(outputFile);

run("Set Measurements...", "area redirect=None decimal=3");


for (img=0; img<list.length; img++) {
	
	open(dir1+list[img]);
		
	//Profiling
	selectWindow(list[img]);
	run("Duplicate...", "title=profiling_HSV");
	
	run("Colors...", "foreground=white background=black selection=yellow");
	run("Options...", "iterations=1 black count=1");
	
	run("HSB Stack");
	run("Convert Stack to Images");
	
	//Mean Hue
	selectWindow("Hue");
	close();
	selectWindow("Brightness");
	close();
	
	//Mean sat
	selectWindow("Saturation");
	run("Restore Selection");
	getStatistics(tmp, sat_mean);
	
	selectWindow(list[img]);
		
	run("RGB Stack");
	run("Convert Stack to Images");
	
	//Mean red
	selectWindow("Red");
	close();
	
	//Mean green
	selectWindow("Green");
	run("Restore Selection");
	getStatistics(tmp, green_mean);
		
	//Mean blue
	selectWindow("Blue");
	run("Restore Selection");
	getStatistics(tmp, blue_mean, blue_min);
	
		
	//Green window
	//Mean 32
	//STD 15
	filter_green = "pass";
	green_min = green_mean - 32 - (0*15);
	if (green_min > 255) green_min = 255;
	green_max = green_mean - 32 + (3*15);
	if (green_max > 255) green_max = 255;
	
	//Blue window
	//Mean 26
	//STD 12
	filter_blue = "pass";
	blue_min = blue_mean - 26 - (1*12);
	if (blue_min < 0) blue_min = 0;
	blue_max = blue_mean - 26 + (4*12);
	if (blue_max > 255) blue_max = 255;

	
	//Sat window
	//SD 15.3
	//mean 37
	filter_sat = "pass";
	sat_min = sat_mean + 37 - (1*15.3);
	if (sat_min < 0) sat_min = 0;
	sat_max = sat_mean + 37 + (2*15.3);
	if (sat_max > 255) sat_max = 255;
	
	//Apply thresholds
	
	//Sat window
	selectWindow("Saturation");
	setThreshold(sat_min, sat_max);
	run("Make Binary", "thresholded remaining");
	if (filter_sat=="stop")  run("Invert");
	// saveAs("Gif", dir2+list[img] + "_Sat.gif");
	rename(list[img] + "_Sat.gif");

    //green window
    selectWindow("Green");
    setThreshold(green_min, green_max);
    run("Make Binary", "thresholded remaining");
    if (filter_green=="stop")  run("Invert");
    // saveAs("Gif", dir2+list[img] + "_Green.gif");
    rename(list[img] + "_Green.gif");

    //blue window
    selectWindow("Blue");
    setThreshold(blue_min, blue_max);
    run("Make Binary", "thresholded remaining");
    if (filter_blue=="stop")  run("Invert");
    // saveAs("Gif", dir2+list[img] + "_Blue.gif");
    rename(list[img] + "_Blue.gif");

    //Intersection
    imageCalculator("AND create", list[img] + "_Sat.gif",list[img] + "_Green.gif");
    selectWindow(list[img] + "_Green.gif");
    close();
    imageCalculator("AND create", "Result of "+list[img] + "_Sat.gif",list[img] + "_Blue.gif");
    // saveAs("Gif", dir2+list[img] + "_intersection.gif");
    rename(list[img] + "_intersection.gif");
	
	selectWindow("Result of "+list[img] + "_Sat.gif");
	close();
	selectWindow(list[img] + "_Blue.gif");
	close();
	selectWindow(list[img] + "_Sat.gif");
	close();
	
	selectWindow(list[img] + "_intersection.gif");

	run("Options...", "iterations="+erode+" black count=1");
	run("Erode");
	
	run("Options...", "iterations="+dilate+" black count=1");
	run("Dilate");
	
//	run("Make Binary");
	run("Skeletonize");

	saveAs("PNG", dir2+list[img] + "_skeleton");
	close();

	//output filename and values
	File.append(list[img]+"	"+sat_mean+"	"+sat_min+"	"+sat_max+"	"+green_mean+"	"+green_min+"	"+green_max+"	"+blue_mean+"	"+blue_min+"	"+blue_max, filepath);
		
	call("java.lang.System.gc");
}

beep();
