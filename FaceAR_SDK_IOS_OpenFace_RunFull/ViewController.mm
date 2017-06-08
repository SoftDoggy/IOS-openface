//
//  ViewController.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "ViewController.h"

///// opencv
#import <opencv2/opencv.hpp>
///// C++
#include <iostream>
///// user
#include "FaceARDetectIOS.h"
//

@interface ViewController ()

@end

@implementation ViewController {
    FaceARDetectIOS *facear;
    int frame_count;
    cv::Mat_<double> res;
    int rows;//the rows of res
    int i;//assign which point to use
    int x,y;//get the x and y of the point
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    ///////////////////
//    facear =[[FaceARDetectIOS alloc] init];
    
}

- (IBAction)startButtonPressed:(id)sender
{
    i=0;
    [self.videoCamera start];
}
- (IBAction)stopButtonPressed:(id)sender {
    [self.videoCamera stop];
}

- (void)processImage:(cv::Mat &)image
{
    cv::Mat targetImage(image.cols,image.rows,CV_8UC3);
    cv::cvtColor(image, targetImage, cv::COLOR_BGRA2BGR);

    if(targetImage.empty()){
        std::cout << "targetImage empty" << std::endl;
    }
    else
    {
        float fx, fy, cx, cy;
        cx = 1.0*targetImage.cols / 2.0;
        cy = 1.0*targetImage.rows / 2.0;
    
        fx = 500 * (targetImage.cols / 640.0);
        fy = 500 * (targetImage.rows / 480.0);
    
        fx = (fx + fy) / 2.0;
        fy = fx;
        res=[[FaceARDetectIOS alloc] run_FaceAR:targetImage frame__:frame_count fx__:fx fy__:fy cx__:cx cy__:cy];
        rows = res.rows/2;
        x = res.at<double>(i);
        y = res.at<double>(i+rows);
        x-=20;
        //y+=64;
        printf("mm-res:x-%dy-%d\n",x,y);
        //imageView.frame.size.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _adornment.frame=CGRectMake(x,y, 100, 100);
        }];
        frame_count = frame_count + 1;
        
    }
    cv::cvtColor(targetImage, image, cv::COLOR_BGRA2RGB);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
