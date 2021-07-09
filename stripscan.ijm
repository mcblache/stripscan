//folder with images
dir = getDirectory("Dossier à analyser ");
list = getFileList(dir);

//result file folder
Sauve = dir + "result" + File.separator;
File.makeDirectory(Sauve);

//folder "done"
fait =  dir + "done" + File.separator;
File.makeDirectory(fait);


//dialog Box
Dialog.create("Line Width");
Dialog.addNumber("Width:", 300);
Dialog.show();
linewidth = Dialog.getNumber();
run("Line Width...", "line="+linewidth+"");

//loop to open image
for (i=0;i<list.length; i++) {
pathi = dir+list[i];
showProgress(i, list.length);
if (!endsWith(pathi,"/"))run("Bio-Formats Importer", "open=pathi autoscale color_mode=Default open_series_1");
if (nImages>=1)        
{

//image name 
name = File.nameWithoutExtension;	

//create the border manually
setTool("polyline");
waitForUser("Draw the strip");
getLine(x1, y1, x2, y2, lineWidth); 

// image size and parameters
img = getTitle;
getDimensions(width, height, channels, slices, frames);
nbremask = width /lineWidth;
demiimg = width / 2;
widthimg = width; 
heightimg = height;

//Create first ROI
roiManager("Add");
roiManager("Select", 0);
roiManager("Rename", "000");
Roi.getBounds(x, y, width, height);

//choice of direction (left or right)
if (x>demiimg) {dx=-lineWidth;} else {dx=lineWidth;}
	
//Create all ROIs
for(n=0;n<nbremask;n++){roiManager("Add");}

//ROI number
nR = roiManager("Count") -1; 

//move the ROIs
for (r=1; r<nR; r++) {
          roiManager('select', r);
          getSelectionBounds(x, y, w, h);
          setSelectionLocation(x+(r*dx), y);
          roiManager('update');
         }
         
//remove ROIs not correct
for (r=0; r<nR ; r++) {
roiManager('select', r);
getSelectionBounds(x1, y1, w1, h1);
r2 = r+1;
roiManager('select', r2);
getSelectionBounds(x2, y2, w2, h2);
if(abs(x1-x2) != lineWidth){
	roiManager('select', r2);
	roiManager("Delete");
	nR = roiManager("Count") -1; 
	} 
else{}
}

//change fill color  
setForegroundColor(1, 1, 1);

//Create all masks  and associate images    
for (r=0; r<nR; r++) {
	newImage("mask", "8-bit black", widthimg, heightimg, 1);	
    roiManager('select', r);
    run("Fill", "slice");
    mask = getTitle;	
    imageCalculator("Multiply create stack",img ,mask);
  	close(mask);
         }  
         
 //create a stack with all new images        
run("Concatenate...", "all_open title=Concatenate");         
run("Hyperstack to Stack");
getDimensions(width, height, channels, slices, frames);
nbreChannel = channels*frames;
run("Stack to Hyperstack...", "order=xyczt(default) channels=channels slices=1 frames=frames display=Color");

// save stacks
saveAs("Tiff", Sauve + "\\ImageFinal_" + name);

// save ROIs
roiManager("deselect");
roiManager("Save", Sauve + "\\" + name  + ".zip");
roiManager("Deselect");
roiManager("Delete");

run("Close All");
pathfait = fait + list[i];
File.rename(pathi, pathfait);

     }}

	