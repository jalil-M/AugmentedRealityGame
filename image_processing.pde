
public static PVector rotation;
import processing.core.*;
import processing.video.*;
import processing.video.Capture;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

import gab.opencv.*;

public class imageprocessing extends PApplet {

  PImage img;
  PImage img3;
  PImage houghImg;

  OpenCV opencv;

  String input = "video";
  boolean use = true;
  int maxLines = 4;
  Movie cam;
  int min, max;
  PVector rotations;

  // THE FOLLOWING CODE WAS USED IN ASSIGNEMENT 12 FOR THE CAMERA PART !
  // Capture cam;
  /*public void setupCamera() {
   String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   //cam = new Capture(this,cameras[63]);
   cam = new Capture(this, 640,480,cameras[0]);
   cam.start();
   }
   }*/

  void settings() { 
    // The size of the Image Processing Window is in function of the Current Working Computer.
    size(1935, 490);
  } 


  public void setup() {
    opencv = new OpenCV(this, 100, 100);
    if (input == "still") {
      img = loadImage("board1.jpg");
    } else if (input == "camera") {
      // setupCamera();
    } else {
      // We used the absolute path of the video, because we had some issues with the data folder.
      cam = new Movie(this, "C:\\Users\\Jalil M\\Desktop\\gitrepos\\VC\\VCGame\\TGame\\testvideo.avi");
      cam.loop();
    }
  }

  void draw() { 

    if (cam.available())cam.read();
    img = cam.get();
    PImage img1 = img.copy();
    PImage img2;
    PImage img3;
    img1.loadPixels();

    // These values of the thresholdHSB are the most suitable for our Code.
    img1 = thresholdHSB(img1, 85, 140, 69, 255, 30, 255);
    img1 = gaussianKernel(img1);
    img1 = gaussianKernel(img1); //two gaussian gives us better results

    BlobDetection bl=new BlobDetection();
    img2 = scharr(img1.copy());
    img2 = thresholdHSB(img2, 0, 255, 0, 255, 200, 255);

    img3 = bl.findConnectedComponents(img1.copy(), true);
    List<PVector> lines = hough(img2, 4, 10);
    QuadGraph qg = new QuadGraph();


    List<PVector> corners=qg.findBestQuad(lines, img2.width, img2.height, 100000000, -1000000000, false);

    image(img, 0, 0); 
    for (int i = 0; i <lines.size(); i++) {
      PVector pv = lines.get(i);
      float r = pv.x;
      float phi = pv.y;
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = img2.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = img2.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
    ArrayList<PVector> cornersHomog= new ArrayList();
    if (!corners.isEmpty())
    {
      for (int i=0; i<corners.size(); i++) {
        PVector corner=corners.get(i);
        fill((i%3)*255, (i%2)*255, (i%1)*255, 120);//not perfect, but good enough random number generator
        ellipse(corner.x, corner.y, 80, 80 );
        cornersHomog.add(new PVector(corner.x, corner.y, 1.0));
      }

      // This value of the sample Rate is used because we need a fixed image.
      TwoDThreeD twodthreed=new TwoDThreeD(img2.width, img2.height, 0);
      List<PVector> cornersHomogSorted=qg.sortCorners(cornersHomog);
      PVector tempRotation=twodthreed.get3DRotations(cornersHomogSorted);

      //Since the rotation can be bigger than 90 degrees, we make sure to subtract 180 degrees so that it is withis the predicted bounds
      tempRotation.x=makeAngleInsideBouns(tempRotation.x);
      tempRotation.y=makeAngleInsideBouns(tempRotation.y);
      tempRotation.z=makeAngleInsideBouns(tempRotation.z);
 
      rotation=tempRotation;
    }

    img2.updatePixels();//update pixels 

    image(img2, img.width, 0); 
    image(img3, img.width*2, 0);
  }

  float makeAngleInsideBouns(double angle)
  {

    if (angle > PI/2.0) angle = angle - PI;
    else if (angle < -PI/2.0) angle = angle + PI;
    return (float)angle;
  }
  boolean imagesEqual(PImage img1, PImage img2) { //a utilitary function we used to test
    if (img1.width != img2.width || img1.height != img2.height) 
      return false; 
    for (int i = 0; i < img.width-1; i++) 
      for (int j = 0; j < img.height-1; j++)
        if (red(img1.pixels[i+j*img1.width]) != red(img2.pixels[i+j*img.width])) return false; 
    return true;
  }



  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result = createImage(img.width, img.height, RGB); 

    for (int i = 0; i < img.width * img.height; i++) { 
      color c = img.pixels[i];
      float h = hue(c);
      float s = saturation(c);
      float b = brightness(c);
      if ((h < minH || h > maxH) || (s < minS || s > maxS) || (b < minB || b > maxB)) {
        result.pixels[i] = color(0);
      } else result.pixels[i] = color(255);
    }
    return result;
  }
  PImage convolute(PImage img) {
    float[][] kernel = { 
      { 0, 0, 0 }, 
      { 0, 2, 0 }, 
      { 0, 0, 0 }
    };


    //float normFactor = 1.f;

    // create a greyscale image (type: ALPHA) for output 
    PImage result = createImage(img.width, img.height, ALPHA);


    return result;
  }
  PImage helperConvolution(float normFactor, PImage img, float[][] kernel) {
    PImage result = createImage(img.width, img.height, ALPHA);
    for (int i = 0; i < img.width * img.height; i++) { 
      result.pixels[i] = color(0);
    }
    for (int i = 1; i < img.width-1; i++) 
      for (int j = 1; j < img.height-1; j++) {
        result.pixels[i+j*img.width] = color((int)(
          brightness(img.pixels[i+(j-1)*img.width-1])*kernel[2][2]  +  brightness(img.pixels[i+(j-1)*img.width])*kernel[2][1] + brightness(img.pixels[i+(j-1)*img.width+1])*kernel[2][0]
          +brightness(img.pixels[i+j*img.width-1])*kernel[1][2]     +  brightness(img.pixels[i+j*img.width])*kernel[1][1]     + brightness(img.pixels[i+j*img.width+1])*kernel[1][0]
          +brightness(img.pixels[i+(j+1)*img.width-1])*kernel[0][2] +  brightness(img.pixels[i+(j+1)*img.width])*kernel[0][1] + brightness(img.pixels[i+(j+1)*img.width+1])*kernel[0][0]
          )/normFactor);
      }
    return result;
  }
  PImage gaussianKernel(PImage img) {
    float[][] kernel = { 
      { 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }
    };


    float normFactor = 99.f;

    return helperConvolution(normFactor, img, kernel);
  }

  PImage scharr(PImage img) {
    float[][] vKernel = { 
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 } 
    };

    float[][] hKernel = { 
      { 3, 10, 3 }, 
      { 0, 0, 0 }, 
      { -3, -10, -3 } 
    };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image 
    for (int i = 0; i < img.width * img.height; i++) { 
      result.pixels[i] = color(0);
    }
    float max=0; 
    float[] buffer = new float[img.width * img.height];
    for (int i = 1; i < img.width - 1; i++) { // Skip top and bottom edges 
      for (int j = 1; j < img.height - 1; j++) { // Skip left and right 
        float sum_v = (
          brightness(img.pixels[i+(j-1)*img.width-1])*vKernel[2][2]  +  brightness(img.pixels[i+(j-1)*img.width])*vKernel[2][1] + brightness(img.pixels[i+(j-1)*img.width+1])*vKernel[2][0]
          +brightness(img.pixels[i+j*img.width-1])*vKernel[1][2]     +  brightness(img.pixels[i+j*img.width])*vKernel[1][1]     + brightness(img.pixels[i+j*img.width+1])*vKernel[1][0]
          +brightness(img.pixels[i+(j+1)*img.width-1])*vKernel[0][2] +  brightness(img.pixels[i+(j+1)*img.width])*vKernel[0][1] + brightness(img.pixels[i+(j+1)*img.width+1])*vKernel[0][0]
          );
        float sum_h = (
          brightness(img.pixels[i+(j-1)*img.width-1])*hKernel[2][2]  +  brightness(img.pixels[i+(j-1)*img.width])*hKernel[2][1] + brightness(img.pixels[i+(j-1)*img.width+1])*hKernel[2][0]
          +brightness(img.pixels[i+j*img.width-1])*hKernel[1][2]     +  brightness(img.pixels[i+j*img.width])*hKernel[1][1]     + brightness(img.pixels[i+j*img.width+1])*hKernel[1][0]
          +brightness(img.pixels[i+(j+1)*img.width-1])*hKernel[0][2] +  brightness(img.pixels[i+(j+1)*img.width])*hKernel[0][1] + brightness(img.pixels[i+(j+1)*img.width+1])*hKernel[0][0]
          );
        buffer[j * img.width + i] = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (max < buffer[j * img.width + i]) max = buffer[j * img.width + i];
      }
    } 
    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges 
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right 
        int val=(int) ((buffer[y * img.width + x] / max)*255); 
        result.pixels[y * img.width + x]=color(val);
      }
    } 
    return result;
  }



  List<PVector> hough(PImage edgeImg, int nLines, int regionRadius) {
    float discretizationStepsPhi = 0.06f; 
    float discretizationStepsR = 2.5f; 
    int minVotes=50; 

    // dimensions of the accumulator 
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1); 

    //The max radius is the image diagonal, but it can be also negative 
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width + 
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

    // our accumulator 
    int[] accumulator = new int[phiDim * rDim];

    // Fill the accumulator: on edge points (ie, white pixels of the edge // image), store all possible (r, phi) pairs describing lines going 
    // through the point. 
    for (int y = 0; y < edgeImg.height; y++) { 
      for (int x = 0; x < edgeImg.width; x++) { 
        // Are we on an edge? 
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int i = 0; i < phiDim; i++) {
            float phi = i*discretizationStepsPhi;
            float r = x * cos(phi) + y * sin(phi);
            int r_discret = (int) (r/discretizationStepsR + rDim/2);
            accumulator[i*rDim+ r_discret]+=1;
          }
        }
      }
    } 

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    boolean add=true;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {

        int index = accPhi * rDim + accR;
        if (accumulator[index] > minVotes) {
          add=true;
          for (int neighPhi=-regionRadius/2; neighPhi < regionRadius/2; neighPhi++) {
            int correction = 0;
            if ( accPhi+neighPhi < 0) correction = phiDim;
            else if (accPhi+neighPhi >= phiDim) correction = -phiDim;

            for (int neighR=-regionRadius/2; neighR < regionRadius/2; neighR++) {

              if ( accR+neighR >= 0 && accR+neighR < rDim) {
                int tmpIndex= (accPhi + correction + neighPhi) * rDim + (accR + neighR);
                if (accumulator[index]<accumulator[tmpIndex]) {
                  add=false;
                  break;
                }
              }
            }
          } 
          if (add) bestCandidates.add(index);
        }
      }
    }
    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    nLines=min(nLines, bestCandidates.size());
    bestCandidates = new ArrayList(bestCandidates.subList(0, nLines));


    ArrayList<PVector> lines=new ArrayList<PVector>(); 
    for (int i = 0; i <nLines; i++) {   
      int idx=bestCandidates.get(i);
      // first, compute back the (r, phi) polar coordinates: 
      int accPhi = (int) (idx / (rDim)); 
      int accR = idx - (accPhi) * (rDim); 
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR; 
      float phi = accPhi * discretizationStepsPhi; 
      lines.add(new PVector(r, phi));
    }

    return lines;
  }

  class HoughComparator implements java.util.Comparator<Integer> {
    int[] accumulator;
    public HoughComparator(int[] accumulator) {
      this.accumulator = accumulator;
    }
    @Override
      public int compare(Integer l1, Integer l2) {
      if (accumulator[l1] > accumulator[l2]
        || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
      return 1;
    }
  }
}