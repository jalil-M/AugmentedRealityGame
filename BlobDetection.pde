import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Iterator;

import java.util.Collections;//to remove
import java.util.Arrays;//to remove

class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    // First pass: label the pixels and store labels' equivalences
    int [] labels= new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    int currentLabel=0;//I'm starting at 0, different from what was given

    //First-pass

    for (int i=0; i<input.height; i++)
    {
      for (int j=0; j<input.width; j++)
      {

        int pos=i*input.width+j;
        TreeSet<Integer> temp=new TreeSet<Integer>();
        if (brightness(input.pixels[i*input.width+j])!=0)
        {
          if (j!=0)//apo i
          {
            if (labels[i*input.width+j-1]!=0)//left
            {

              temp.add(labels[i*input.width+j-1]);
            }
          }
          if (i!=0)
          {
            if (j!=0)
            {
              if (labels[(i-1)*input.width+j-1]!=0)//up-left
              {

                temp.add(labels[(i-1)*input.width+j-1]);
              }
            }

            if (labels[(i-1)*input.width+j]!=0)//up
            {

              temp.add(labels[(i-1)*input.width+j]);
            }
            if (j!=input.width-1)
            {
              if (labels[(i-1)*input.width+j+1]!=0)////up-right
              {

                temp.add(labels[(i-1)*input.width+j+1]);
              }
            }
          }

          if (temp.isEmpty())
          {
            currentLabel++;
            labels[pos]=currentLabel;
            temp.add(currentLabel);
            labelsEquivalences.add(temp);
          } else {
            labels[pos] = temp.first();
            if (temp.size() > 1) {
              TreeSet<Integer> acc = new TreeSet<Integer>();
              while (temp.size() != 0) {
                acc.addAll(labelsEquivalences.get(temp.first()-1));
                temp.remove(temp.first());
              }
              TreeSet<Integer> labelsToUpdateEquivalance = (TreeSet)acc.clone();
              while (labelsToUpdateEquivalance.size() != 0) {

                labelsEquivalences.remove(labelsToUpdateEquivalance.first()-1);
                labelsEquivalences.add(labelsToUpdateEquivalance.first()-1, acc);
                labelsToUpdateEquivalance.remove(labelsToUpdateEquivalance.first());
              }
            }
          }
        }
      }
    }

    //Second-pass
    int [] labelsCount= new int [currentLabel+1];
    for (int i=0; i<input.height; i++)
    {
      for (int j=0; j<input.width; j++)
      {
        if (labels[i*input.width+j]!=0)
        {
          TreeSet<Integer> s=labelsEquivalences.get( labels[i*input.width+j]-1);
          int newlabel=s.first();
          labels[i*input.width+j]=newlabel;
          if ( onlyBiggest) labelsCount[newlabel]++;
        }
      }
    }
    //Last-part
    int maxpos=0;
    if (onlyBiggest) {
      int max=Integer.MIN_VALUE;

      for (int i=0; i<currentLabel; i++)
      {
        if (labelsCount[i]>max)
        {
          max=labelsCount[i];
          maxpos=i;
        }
      }
    }

    for (int i=0; i<input.height; i++)
    {
      for (int j=0; j<input.width; j++)
      {
        int pos=i*input.width+j;
        if (labels[pos]!=0)
        {            
          int tmpLabel=labels[pos];
          if (onlyBiggest)
          {

            if (tmpLabel!=maxpos)
              input.pixels[pos]=color(0, 0, 0);
            else input.pixels[pos]=color(255, 255, 255);
          } else {
            input.pixels[pos]=color((tmpLabel*90)%255, (tmpLabel*30)%255, (tmpLabel*10)%255);//not perfect, but good enough random number generator
          }
        }
      }
    }
    return input;
  }
}