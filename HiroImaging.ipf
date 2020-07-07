#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.80		// version of procedure
#pragma IgorVersion = 6.2

#include "HiroCoreServices"
#include "HiroOdor"

// Written by Hirofumi Watari, Ph.D. © 2016. All rights reserved.
// This supports Ca imaging data in Stroh lab

// What's new in HiroImaging 0.80 (2016-10-20);Supports removing silent cells from the Pearson matrix for Isa;---
// What's new in HiroImaging 0.79 (2016-08-24);Supports exporting peak info for Miriam;---
// What's new in HiroImaging 0.78 (2016-08-12);Supports tabulation of all groups in the Distance and Pearson graphs;---
// What's new in HiroImaging 0.77 (2016-08-11);Fixed a bug that fail to keep track of excluded ROIs during randomization;---
// What's new in HiroImaging 0.76 (2016-07-29);A final update;---
// What's new in HiroImaging 0.75 (2016-07-18);Supports a new app for Consuelo;---
// What's new in HiroImaging 0.74 (2016-05-19);Supports a new app for Ting;---
// What's new in HiroImaging 0.73 (2016-05-18);Fixed a bug that causes the results from Pearson's correlation to disappear in the first ROI;This bug first appeared in vers 0.71;---
// What's new in HiroImaging 0.72 (2016-05-17);Supports exporting PeakLoc datapoints for Hendrik;---
// What's new in HiroImaging 0.71 (2016-05-13);Improved multi-threading on histogram and Pearson's r calculations in step 4;---
// What's new in HiroImaging 0.70 (2016-05-12);Fixed a bug that incorrectly randomizes data when some ROIs are not included;---
// What's new in HiroImaging 0.69 (2016-05-12);Supports optional randomization of data in step 4;---
// What's new in HiroImaging 0.68 (2016-05-04);Improved randomization of ROI map and raster data (fast);Improved multi-threaded smoothing;Fixed a bug that causes an error when the freq cutoff values are changed in step 3;Fixed a bug that fails to show Pearson vs Distance graph under a certain situation;---
// What's new in HiroImaging 0.67 (2016-05-02);Supports randomization of ROI map and raster data (slow);---
// What's new in HiroImaging 0.66 (2016-04-29);Supports display of Mean ± SEM or individual data points for group analysis in step 4;---
// What's new in HiroImaging 0.65 (2016-04-28);Supports tabulated data on Distance and Pearson groups in step 4;Fixed a bug where changing the frequency cutoff causes an error in step 3;Changed the bin-size in step 4;Updated menu;---
// What's new in HiroImaging 0.64 (2016-04-26);Smoothing is multi-threaded (more than 2x faster on a two-core processor);---
// What's new in HiroImaging 0.63 (2016-04-25);Fixed a minor bug that caused an error when downloading the new script;---
// What's new in HiroImaging 0.62 (2016-04-25);Fixed a bug that causes an error when the user cancels the file open dialog;---
// What's new in HiroImaging 0.61 (2016-04-20);Fixed a bug that causes an error under certain circumstance in the Time Machine for Isa;---
// What's new in HiroImaging 0.60 (2016-04-20);Supports dynamic categorization of silent, low, medium, and high frequency cells for Isa (beta);Plots the mean±STEM for each group;---
// What's new in HiroImaging 0.59 (2016-04-19);Supports color scale in Pearson's r plot for Isa;---
// What's new in HiroImaging 0.58 (2016-04-18);Supports stimulus artifact subtraction for Ting;---
// What's new in HiroImaging 0.57 (2016-04-15);Supports ROI map scaled in µm;A cleaner UI for Step 2;---
// What's new in HiroImaging 0.56 (2016-04-14);Resized some graphs in Step 3;Fixed an issue where Time Machine fails when a table is open;---
// What's new in HiroImaging 0.55 (2016-04-13);One-time patch that reverts a step for Isa;Supports distance between ROIs expressed in µm;Updated the menu;---
// What's new in HiroImaging 0.54 (2016-04-08);Supports improved X-axis scrolling;---
// What's new in HiroImaging 0.53 (2016-04-06);Supports Georg's analysis;---
// What's new in HiroImaging 0.52 (2016-03-30);Fine-tuned the display of histogram and raster in Step 4;---
// What's new in HiroImaging 0.51 (2016-03-30);Added a menu that advances to the next step;---
// What's new in HiroImaging 0.50 (2016-03-30);Fixed a bug where step 4 graphs don't fit on Isa's monitor;---
// What's new in HiroImaging 0.49 (2016-03-28);Supports Pearsons vs distance analysis;---
// What's new in HiroImaging 0.48 (2016-03-24);Supports dynamic UI for Pearson's analysis;---
// What's new in HiroImaging 0.47 (2016-03-22);Supports rapid raster to histogram conversion;Supports automatic Pearson's r analysis;---
// What's new in HiroImaging 0.46 (2016-03-16);Supports M2I binary files;---
// What's new in HiroImaging 0.45 (2016-03-16);Improved highpass filtering;Improved detection of foot and tail;Prevents peak detection to hang during a rare infinite loops;---
// What's new in HiroImaging 0.44 (2016-03-16);Fitted curve changes to yellow when tau is outside of expected range;Performs curve fitting in the background;Fixed a bug where an error dialog shows if the first trace contains no peak;---
// What's new in HiroImaging 0.43 (2016-03-15);Fixed a bug where unselected peak was measured and stored under certain circumstances;---
// What's new in HiroImaging 0.42 (2016-03-15);Supports optional display of the fitted curve;---
// What's new in HiroImaging 0.41 (2016-03-14);Fine tuned peak measurements;Supports display of peak measurements in a table;Automated curve fitting;---
// What's new in HiroImaging 0.40 (2016-03-12);Supports event-driven loading of ROI maps;ROI map supports user-defined image size;---
// What's new in HiroImaging 0.39 (2016-03-08);Measures and stores features of the peak automatically;---
// What's new in HiroImaging 0.38 (2016-03-07);Improved the detection of foot and tail;---
// What's new in HiroImaging 0.37 (2016-03-04);Auto-detects foot and tail of peaks;---
// What's new in HiroImaging 0.36 (2016-03-03);Improved highpass filtering;Fixed a bug when ROI map doesn't exist;---
// What's new in HiroImaging 0.35 (2016-03-02);Added display for highpass filtered traces per Isa's request;A minor bug fix;---
// What's new in HiroImaging 0.34 (2016-02-29);Supports dynamic colorization of ROI map based on frequency;---
// What's new in HiroImaging 0.33 (2016-02-28);Supports peak rasterization and calculates frequency and IPI;---
// What's new in HiroImaging 0.32 (2016-02-27);Supports manual editing of peak location;---
// What's new in HiroImaging 0.31 (2016-02-25);Improved the algorithm for automatic peak detection;Added precise controls for peak detection;---
// What's new in HiroImaging 0.30 (2016-02-23);Supports baseline analysis for Consuelo;---
// What's new in HiroImaging 0.29 (2016-02-18);Removed N flag from Cursor to make it compatible with Igor Pro version 6.2;---
// What's new in HiroImaging 0.28 (2016-02-15);Features automatic peak detection with threshold slider;---
// What's new in HiroImaging 0.27 (2016-02-14);Allows custom range to analyze;---
// What's new in HiroImaging 0.26 (2016-02-13);Reduces noise dynamically by adjusting a slider;Added ROI switcher;---
// What's new in HiroImaging 0.25 (2016-02-12);Imports Tab-delimited data files;Reduces background noise automatically;---


menu "CaImaging"
	"Open Imaging File/1", OpenImagingData()
	"-"
	//"Next Step/2",hiroImagingNextStep()
	//"Time Machine for Isa/2",patchTimeMachineStep4to3()
	"-"
	Submenu "Top Graph"
		"Resize Window/7",ResizeWindow(0,0)
		"-"
		"Append stimulus bar to existing graph", Bar(0)
	End
	"-"
	
	Submenu "Axes"
		"X-Axis Scrolling.../5",XAxisScrolling2(0,0)
		"-"
		"Y-Axis Scale...",SetYAxisRange()
		"-"
		"Autoscale Axes",AutoscaleAxes()
		"-"
		"Show Axes",ShowAxes()
		"Hide Axes",WipeAllAxes()
	End
	"-"
	"-"
	Submenu "Special"
		"for Georg/4",hiroGPOpenTextFile()
		"-"
		"for Consuelo/6",hiroCFOpenTextFile()
//		Submenu "for Consuelo"
//			"Open File",hiroCFOpenTextFile()
//			"-"
//			"Analyze OL Response",OdorLightBaselineAnalysis()
//		End
		"-"
		Submenu "for Ting"
			"Analyze green-laser evoked responses/8",hiroTFevokedStep0()
			"-"
			"-"
			"Test-subtract stimulus artifact",hiroTFOpenTextFile()
		End
		"-"
		Submenu "for Hendrik"
			"Save PeakLoc info for MATLAB/9",patchExportPeakLoc(1)
		End
		"-"
		Submenu "for Miriam"
			"Save Custom Peak info for MATLAB",patchExportPeakLocExtended(1)
		End
		"-"
		Submenu "for Isa"
			"Remove silent cells from the Pearson Square Matrix",hiroPearsonMatrixWOSilent()
		End
	End
	"-"
	"-"
	"About this menu", AboutHiroScript()
End

static constant km2i_Version=2			// unsupported m2i file version

// Step 1
static constant kInitDenoiseValue=20		// Gaussian (binomial)
static constant kInitOffsetValue=-100	// default separation between M0 and M_smooth
static constant kPaddingRangeBack=1.1	// separation between M_smooth and wRangeBack

static constant kScaleBarVertical=1.008	// position of the scale bar;used as prel
static constant kScaleBarLabel=1.009

// Step 2
static constant kDefaultSDMultiple=3.5	// 3.5 times SD above the mean is the default threshold for peak detection
static constant kDefaultSecRefractoryPeriod=1	// s
static constant kFactorRejectBand=0.1	// f1=factor/fs (end of reject band for hipass filter)
static constant kFactorPassBand=0.12	// f2=factor/fs (start of the pass band)
static constant kNumFIRFiltCoeff=450	// number of FIR filter coefficients for highpass filtering
static constant ksPredictedDecayBaseline=7	// s after peak
static constant ksPaddingPeakDetection=3	// s to reject peak detection
static constant ksTauRangeLow=0.4	// s low cut off for tau (user will see curve as yellow as a warning)
static constant ksTauRangeHigh=4	// s high cut off for tau
static constant ksCurveColorWarning=0.75	// yellow

// Step 3
static constant kROILowCutoffFreq=0.3		// per min
static constant kROIHighCutoffFreq=3		// per min
static constant kROIMapWindowSize=350	// points

// Step 4
static constant kmsDefaultBinSize=66	// ms
static constant kOffsetWaveBHistogram=-1.2
static constant kOffsetWaveBRaster=-0.1

// Step 1: Open data--denoise, and adjust range if needed
Function OpenImagingData()
	
	Variable type	// 6 for Stroh lab txt or bin
	
	type = GetFileInfo(6)	// Creates a global variables for file name and path
	
	String nameDF
	
	SVAR fileName
	SVAR folderPath
	
	if (type==3)
		LoadDataAsGeneralText(1)	// 1 loads as Matrix
		nameDF = ReplaceString(".txt", fileName, "")
	elseif (type==6)
		hiroOpenM2IBinaryStroh(folderPath+fileName)
		nameDF = ReplaceString(".bin", fileName, "")
	elseif (type==-1)
		Print "User canceled"
		Abort
	else
		Print "Wrong file type: see Hiro"
		Abort
	endif
	
	NVAR nRegions
	
	Print "Hiro's Igor Pro Scripts 2010-2016 © Hirofumi Watari, Ph.D."
	Print folderPath+fileName
	Print "-Loaded",num2str(nRegions),"traces"
	
	Variable fs
	String yUnits
	if (type==3)
		// ask sampling freq and units for y-axis
		yUnits = "dF/F"
		do
			Prompt fs, "Sampling frequency (Hz) - must be greater than zero"
			Prompt yUnits, "Y-axis units"
			DoPrompt/HELP="Sampling freq must be greater than 0 Hz. Hit a tab-key to toggle between the two fields." "Data Info",fs,yUnits
			
			if (V_flag == 1)
				Print "User Canceled Procedure"
				Abort	//quit if cancel button was clicked
			endif
		while(fs<=0)
	else
		WAVE FH=FileHeader0
		fs=FH[3]
		if (FH[4])
			yUnits="dF/F"
		else
			yUnits="F"
		endif
	endif
	
	// Rename "temp" DF
	CheckDFDuplicates(nameDF)
	
	// Fix wave scaling
	// Because the waves are loaded as a matrix, it doesn't need loops
	WAVE M0
	SetScale/P x 0,1/fs,"s", M0
	SetScale d 0,0,yUnits, M0
	
	hiroSmooth(kInitDenoiseValue)	// M_smooth is created
	
	// Show the first trace as a stack (top: original, bottom: noise-reduced)
	Variable itrace=0
	WAVE M_smooth
	DoWindow GraphStep1
	if (V_flag)
		KillWindow GraphStep1
	endif
	Display/N=GraphStep1 as "Step 1: Browse and Smooth"
	AppendToGraph M0[][itrace], M_smooth[][itrace]
	//ModifyGraph offset(M_smooth)={0,kInitOffsetValue}	// find a good separation distance automatically
	
	ModifyGraph margin(left)=75
	ModifyGraph noLabel(left)=2,axThick(left)=0
	
	// These traces are in the background as gray color
	ModifyGraph rgb(M0)=(34952,34952,34952)
	ModifyGraph rgb(M_smooth)=(34952,34952,34952)
	
	// Add a vertical scale bar (20 units)
	SetDrawEnv xcoord= prel,ycoord= left
	DrawLine kScaleBarVertical,-50,kScaleBarVertical,-30
	SetDrawEnv xcoord= prel,ycoord= left,textrot= 90
	DrawText kScaleBarLabel,-50,num2str(20)+" "+yUnits
	
	ResizeWindow(1280,400)
	
	NewDataFolder/O :Controls
	
	// Add a slider to adjust smoothing
	Make/N=3 :Controls:sliderTicValue
	Make/T/N=3 :Controls:sliderTicLabel
	
	WAVE sliderTicValue=:Controls:sliderTicValue
	WAVE/T sliderTicLabel=:Controls:sliderTicLabel
	
	sliderTicValue=-x*kInitDenoiseValue
	sliderTicLabel[0]="None"
	sliderTicLabel[2]="Denoise"
	
	Slider sliderSmooth pos={1,250},size={69,50}
	Slider sliderSmooth proc=SliderProcSmooth,value=-kInitDenoiseValue,limits={sliderTicValue[2],sliderTicValue[0],1}
	Slider sliderSmooth userTicks={sliderTicValue,sliderTicLabel}
	Slider sliderSmooth help={"Adjust to reduce noise"}
	
	// Add setvar to adjust smoothing
	SetVariable setvarSmooth title="n",pos={1,230},size={60,20}
	SetVariable setvarSmooth proc=SetVarProcSmooth,value=_NUM:kInitDenoiseValue,limits={sliderTicValue[0],-sliderTicValue[2],0},live=1
	SetVariable setvarSmooth userData=num2str(kInitDenoiseValue)	// saves the value
	SetVariable setvarSmooth help={"Adjust amount of smoothing"}
	
	// Add numerical incrementors to move from one ROI to another
	SetVariable setvarROI title="ROI",pos={1,350},size={60,20}
	SetVariable setvarROI proc=SetVarProcROI,value=_NUM:itrace+1,limits={1,nRegions,1},live=1
	SetVariable setvarROI userData=num2str(-1)	// saves the index of the stimulus ROI as a string (used in Georg's experiment only)
	SetVariable setvarROI help={"Show trace in the particular ROI"}
	
	// Add a checkbox to include or exclude ROI for analysis (checked by default)
	CheckBox checkInclude title="Include",pos={1,370},proc=CheckProcInclude,value=1
	CheckBox checkInclude help={"Check to include this ROI for analysis"}
	
	Make/N=(nRegions) selROI		// keeps track of ROIs
	WAVE selROI
	selROI=1	// initialize
	
	// Add a range selector: make a wave, and add two cursors at the start and end
	Variable n=DimSize(M0,0)
	Make/N=(n) :Controls:wRangeBack
	WAVE wRangeBack=:Controls:wRangeBack
	SetScale/P x 0,deltax(M0),"s", wRangeBack
	AppendToGraph wRangeBack
	
	//OffsetRangeSel(0)
	
	// Colorize wRangeBack on z-axis
	Duplicate wRangeBack,:Controls:wRangeSel
	WAVE wRangeSel=:Controls:wRangeSel
	wRangeSel=1	// 1 is black, 0 is white
	ModifyGraph zColor(wRangeBack)={wRangeSel,*,*,Grays,1}
	
	ModifyGraph lsize(wRangeBack)=2
	ModifyGraph lstyle(wRangeBack)=1
	
	// The N flag doesn't exist in Igor Pro 6.2
	//Cursor/A=1/N=1 A wRangeBack leftx(wRangeBack)
	//Cursor/A=1/N=1/P B wRangeBack n
	
	Cursor/A=1 A wRangeBack leftx(wRangeBack)
	Cursor/A=1/P B wRangeBack n
	
	SetWindow kwTopWin,hook(MyCursorHook)=MyWindowHookCursor,hookevents=7
	UpdateTraceRange(0)	// Creates selected region in darker color (wSel and wSmoothSel)
	WAVE wSel,wSmoothSel
	AppendToGraph wSel,wSmoothSel
	//ModifyGraph offset(wSmoothSel)={0,kInitOffsetValue}
	
	Variable/G offset=-7*sqrt(Variance(wSel))
	ModifyGraph offset(M_smooth)={0,offset}	// find a good separation distance automatically
	ModifyGraph offset(wSmoothSel)={0,offset}
	OffsetRangeSel(0,offset)
	
	UpdateTraceColor(1)
	
	// Add a button to go to Step 2
	Button buttonToStep2 title="Step 2: Peak detection >>",pos={1000,50},size={200,20}
	Button buttonToStep2 proc=ButtonProcToStep2,fColor=(0,0,65535)
	Button buttonToStep2 valueColor=(65535,65535,65535)
	Button buttonToStep2 help={"Click to start semi-auto peak detection"}
	
End


//Function hiroImagingNextStep()
//	// Advance to the next step from the menu
//	
//	NVAR/Z step	// Current step (if saved).  If not saved, find this programmatically.
//	if (!NVAR_Exists(step))
//		// Create one
//		Variable/G step
//	endif
//	
//	DoWindow GraphStep3
//	if (V_flag==2)
//		// not yet supported
//	elseif (V_flag==1)
//		// current step is either 3 or 4
//		DoWindow GraphROIPairs
//		if (V_flag==1)
//			// currently step 4
//			step=4
//		else
//			step=3
//		endif
//	else
//		// step 1 or 2
//		DoWindow GraphStep2
//		if (V_flag==1)
//			// current step 2
//			step=2
//		else
//			// current step 1
//			step=1
//		endif
//	endif
//	
//	// Advance to the next step
//	switch(step)
//		case 1:
//			hiroStep2()
//			break
//		case 2:
//			hiroStep3()
//			break
//		case 3:
//			hiroStep4()
//			break
//		case 4:
//			DoAlert/T="Hiro's Igor Pro Scripts" 0,"There is no next step (yet).\r\rEither that Hiro has not made the next step yet or that you've reached the final step. Ask him."
//			break
//		default:
//			DoAlert/T="Hiro's Igor Pro Scripts" 0,"There is no next step (yet).\r\rEither that Hiro has not made the next step yet or that you've reached the final step. Ask him."
//	endswitch
//	
//End


Function hiroOpenM2IBinaryStroh(filePath)
	// Imports custom binary file from MATLAB in Stroh Lab
	
	String filePath	// e.g., "Mac HD:Users:hiro:Desktop:handsoff.bin"
	
	// Load the first three for ID check
	GBLoadWave/B/A=FileID/T={4,4}/W=1/U=3/Q filePath
	
	WAVE FID=FileID0
	if (FID[2]>=km2i_Version)
		Abort "This version is not yet supported"
	endif
	
	// Load File Header
	GBLoadWave/B/A=FileHeader/T={4,4}/W=1/U=(FID[0])/Q filePath
	
	WAVE FH=FileHeader0
	Variable nFileHeader=FH[0]
	Variable nDataHeader=FH[1]
	Variable nFileVersion=FH[2]
	Variable fs=FH[3]
	Variable type=FH[4]		// 0 for original, 1 for dF/F
	
	// Load Data Header
	GBLoadWave/B/A=DataHeader/T={4,4}/S=(8*nFileHeader)/U=(nDataHeader)/W=1/Q filePath
	WAVE w=DataHeader0
	Variable nRows=w[0]
	Variable nCols=w[1]
	
	Variable pnts2Skip=nFileHeader+nDataHeader
	
	// Load just the trace portions
	GBLoadWave/B/A=m2i_data/T={4,4}/S=(8*pnts2Skip)/U=(nRows)/W=(nCols)/Q filePath
	
	// Package into a matrix
	String dataList=WaveList("m2i_data*",";","")
	dataList=SortList(dataList,";",16)
	//Print dataList
	Concatenate/KILL dataList,M0
	
	Variable/G nRegions=nCols
	
	// Load each ROI in a loop
	DFREF dfrSaved=GetDataFolderDFR()
	NewDataFolder/O/S ROIs
	DFREF dfrROIs=GetDataFolderDFR()
	
	String nameW
	Variable i
	for (i=0;i<nRegions;i+=1)
		KillWaves w
		
		pnts2Skip+=nRows*nCols
		GBLoadWave/B/A=DataHeader/T={4,4}/S=(8*pnts2Skip)/U=(nDataHeader)/W=1/Q filePath
		WAVE w=DataHeader0
		nRows=w[0]
		nCols=w[1]
		//Print i,nRows,nCols
		
		pnts2Skip+=nDataHeader
		GBLoadWave/B/A=roi/T={4,4}/S=(8*pnts2Skip)/U=(nRows)/W=(nCols)/Q filePath
		
		// Package into a two-column matrix
		WAVE ROIx=roi0
		WAVE ROIy=roi1
		nameW="ROI_"+num2str(i+1)
		Concatenate/KILL {ROIx,ROIy}, $nameW
	endfor
	KillWaves w
	SetDataFolder dfrSaved
	
	// Estimate x,y coordinates for ROI map
	NewDataFolder/O/S map
	Make/D/O/N=(nRegions) wOrigX,wOrig
	WAVE wOrigX
	WAVE wOrig
	for (i=0;i<nRegions;i+=1)
		nameW="ROI_"+num2str(i+1)
		//Print nameW
		WAVE w=dfrROIs:$nameW
		Make/FREE/N=(DimSize(w,0)) wX,wY
		wX=w[p][0]
		wY=w[p][1]
		wOrigX[i]=mean(wX)
		wOrig[i]=mean(wY)
	endfor
	
	Variable/G imageWidth=FH[5]
	Variable/G imageHeight=FH[6]
	if (nFileVersion>1)
		Variable/G imageWidthMicron=FH[7]	// supported in version 1.01
		//? if zero
		
		Variable/G imageScaleFactor=imageWidth/imageWidthMicron		// pixels/µm
		
		// convert pixels to µm
		imageWidth/=imageScaleFactor
		imageHeight/=imageScaleFactor
		
		wOrig/=imageScaleFactor
		wOrigX/=imageScaleFactor
		SetScale d 0,0,"µm", wOrig,wOrigX
		
		SetDataFolder dfrSaved
	
		DuplicateDataFolder :ROIs,:ROIs_scaled
		
		DFREF dfrROIscaled=:ROIs_scaled
		
		for (i=0;i<nRegions;i+=1)
			nameW="ROI_"+num2str(i+1)
			WAVE w=dfrROIscaled:$nameW
			w/=imageScaleFactor
			SetScale x 0,0,"µm", w
			SetScale y 0,0,"µm", w
		endfor
	endif
	
	SetDataFolder dfrSaved
	
//	Print filePath
//	Print "-Loaded ROI positions"
//	Print "-Image size",imageWidth,"x",imageHeight,"µm"
//	Print "-Scale factor",imageScaleFactor,"pixels/µm"
	
End


Function hiroSmoothMultiThread(value)
	// a multi-thread version of hiroSmooth()
	// requires splitColumn() and hiroSmoothMT()
	
	Variable value
	
	WAVE M0
	
	Variable nRows=DimSize(M0,0)
	Variable nCols=DimSize(M0,1)
	
	Make/FREE/WAVE/N=(nCols) wref
	
	DFREF dfrFree=NewFreeDataFolder()	// this DF gets killed automatically after use
	
//	Variable i
//	String nameW
//	for(i=0;i<nCols;i+=1)
//		nameW="wFree"+num2str(i)
//		// get a non-free wave from matrix (setting to /FREE causes error with $nameW)
//		// store with a unique name inside a free DF
//		// then assign it to an inline wave ref (important--without this the wref will overwrite and use the last reference only)
//		Duplicate/O/R=[*][i] M0, dfrFree:$nameW/WAVE=w
//		wref[i]=w
//	endfor
	
	Make/T/FREE/N=(nCols) wList="wFree"+num2str(x)
	
	//MultiThread wref=splitColumn(M0,dfrFree,wList[p],p)
	
	// basic for-loop is better until the known issue in the multithread above is solved
	Variable i
	for (i=0;i<nCols;i+=1)
		Duplicate/R=[][i] M0, dfrFree:$wList[i] /WAVE=w
		wref[i]=w
	endfor
	
	Make/FREE/WAVE/N=(nCols) theResult
	
	MultiThread theResult=hiroSmoothMT(wref[p],value)
	
	Make/D/O/N=(nRows,nCols) M_smooth
	
	Make/FREE/N=(nCols) dummy
	
	MultiThread dummy=setColumn(M_smooth,theResult[p],p)
	
	// reset wave scaling (because it gets lost in the Make function above)
	SetScale/P x leftx(M0),deltax(M0),WaveUnits(M0,0), M_smooth
	SetScale d 0,0,WaveUnits(M0,-1), M_smooth
	
End


ThreadSafe Function/WAVE hiroSmoothMT(w, value)
	
	WAVE w
	Variable value
	
	Smooth value, w
	
	return w
	
End


Function hiroSmooth(value)
	// works on current DF with a matrix M_smooth
	
	Variable value
	
	WAVE M0
	
	//Variable t=tic()
	
	// depricated--replaced by hiroSmoothMultiThread()
//	Duplicate/O M0,M_smooth
//	WAVE M_smooth
//	
//	if (value)
//		Smooth/DIM=0 value, M_smooth
//	endif
	
	if (value)
		// multi-threaded smoothing
		// 2.5x faster when value=20 on data with 109 ROIs and 300 s each
		// Core2Duo, early 2008 MBP with 6GB RAM, SSD
		hiroSmoothMultiThread(value)
	else
		Duplicate/O M0,M_smooth
	endif
	
	//toc(t)
	
	// Update wSmoothSel
	WAVE/Z wSmoothSel
	if (WaveExists(wSmoothSel))
		//Variable i=str2num(GetUserData("","setvarROI",""))
		ControlInfo setvarROI
		Variable i=V_Value-1	// convert from 1-based to zero-based
		UpdateTraceRange(i)
	endif
	
End


Function SliderProcSmooth(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				// remove minus sign
				Variable value=abs(curval)
				
				// Save in setvarSmooth userData
				SetVariable setvarSmooth userData=num2str(value)
				SetVariable setvarSmooth value=_NUM:value
				
				hiroSmooth(value)
				DoUpdate
			endif
			break
	endswitch

	return 0
End


Function SetVarProcSmooth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Store this value as a string
			sva.userData=num2str(dval)
			
			//print dval
			
			//sva.value=_NUM:dval
			Slider sliderSmooth value=-dval	// add a minus sign
			
			hiroSmooth(dval)
			DoUpdate
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcROI(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Update traces
			WAVE M0
			WAVE M_smooth
			Variable i
			i=dval-1	// index is zero-based, unlike the ROI which is one-based
			
			ReplaceWave trace=M0,M0[][i]
			ReplaceWave trace=M_smooth,M_smooth[][i]
			
			// Read selROI wave and update checkbox
			WAVE selROI
			Variable checked=selROI[i]
			CheckBox checkInclude value=checked
			
			// Update trace color based on the checkbox
			UpdateTraceColor(checked)
			
			// Update trace range if set
			UpdateTraceRange(i)
			
			// position wRangeBack set % below the minimum of current M_smooth
			//OffsetRangeSel(i)
			NVAR offset
			OffsetRangeSel(i,offset)
			
			//ModifyGraph zColor(wRangeBack)={wRangeSel,*,*,Grays,1}
			
			// Store this value as a string
			//sva.userData=num2str(i)
			
			// for Georg's experiment only
			ControlInfo checkGPSetStim
			if (V_flag>0)
				if (i==str2num(sva.userData))
					CheckBox checkGPSetStim value=1
				else
					CheckBox checkGPSetStim value=0
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function OffsetRangeSel(i,offset)
	
	// position wRangeBack set % below the minimum of current M_smooth
	Variable i	// zero-based ROI
	Variable offset
	
	// get a ref to current M0.  Note that WAVE w=M0[][i] isn't allowed. Use MatrixOp
	WAVE M0
	
	MatrixOp/FREE w=col(M0,i)
	//ModifyGraph offset(wRangeBack)={0,kInitOffsetValue+kPaddingRangeBack*WaveMin(w)}
	ModifyGraph offset(wRangeBack)={0,offset+kPaddingRangeBack*WaveMin(w)}
	
End


Function CheckProcInclude(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			// Store this in master wave
			WAVE selROI
			
			//Variable i=str2num(GetUserData("","setvarROI",""))
			ControlInfo setvarROI
			Variable i=V_Value-1	// convert from 1-based to zero-based
			
			selROI[i]=checked
			
			// Update trace color
			UpdateTraceColor(checked)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcShowCurveFit(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if (checked)
				ModifyGraph hideTrace(wCurves)=0
			else
				ModifyGraph hideTrace(wCurves)=1
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function MyWindowHookCursor(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 0:				// Activate
			// Handle activate
			break

		case 1:				// Deactivate
			// Handle deactivate
			break
		case 7:				// cursormoved
			//String traceName=s.traceName
			//String cursorName=s.cursorName
			//Variable pointNumber=s.pointNumber
			//Print traceName,cursorName, pointNumber
			//Print pcsr(A)
			//Print pcsr(B)
			
			//Variable i=str2num(GetUserData("","setvarROI",""))
			ControlInfo setvarROI
			Variable i=V_Value-1	// convert from one-based to zero-based
			
			UpdateTraceRange(i)
			
			break
			
		// And so on . . .
	endswitch

	return hookResult		// 0 if nothing done, else 1
End


Function UpdateTraceColor(checked)
	
	Variable checked
	
	WAVE wSel
	WAVE wSmoothSel
			
	if (checked)
		ModifyGraph rgb(wSel)=(1,16019,65535),rgb(wSmoothSel)=(65535,0,0)
	else
		ModifyGraph rgb(wSel)=(34952,34952,34952)
		ModifyGraph rgb(wSmoothSel)=(34952,34952,34952)
	endif
	
End


Function UpdateTraceRange(i)
	
	Variable i	// zero-based ROI number
	
	WAVE M0
	WAVE M_smooth
	Duplicate/O/R=[pcsr(A),pcsr(B)][i] M0,wSel
	Duplicate/O/R=[pcsr(A),pcsr(B)][i] M_smooth,wSmoothSel
	
	Redimension/N=(numpnts(wSel)) wSel
	Redimension/N=(numpnts(wSmoothSel)) wSmoothSel
	
	WAVE wRangeSel=:Controls:wRangeSel
	wRangeSel=0
	wRangeSel[pcsr(A),pcsr(B)]=1
	
End


Function ButtonProcToStep2(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroStep2()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


// --- Step 2: Peak detection

Function hiroStep2()
	
	NVAR/Z step
	if (NVAR_Exists(step))
		step=2
	endif
	
	DoWindow/F GraphStep1
	
	// disable control
	Button buttonToStep2 disable=2
	
	Variable pA,pB
	
	pA=pcsr(A)
	pB=pcsr(B)
	
	//String nameWinStep1=WinName(0,1,1)
	
	// Hide the first window
	//DoWindow/HIDE=1 $nameWinStep1
	DoWindow/HIDE=1 GraphStep1
	
	// Make a new window
	DoWindow GraphStep2
	if (V_flag)
		KillWindow GraphStep2
	endif
	Display/N=GraphStep2 as "Step 2: Detect Peaks and stuff"
	
	//String nameWinStep2=WinName(0,1,1)
	
	WAVE selROI
	NVAR nRegions
	Variable i
	do
		if (selROI[i]==1)
			break
		endif
		i+=1
	while(i<nRegions)
	
	// Make a wave that stores the number of peaks (used for frequency calculation later)
	// Also make waves to store IPI-related info
	Make/N=(nRegions) wNumPeaks,wPointsBetwPeaks_avg,wPointsBetwPeaks_sd
//	Note wNumPeaks, "Counts the total number of peaks: used for frequency calculation"
//	Note wPointsBetwPeaks_avg, "Average points between peaks: used for avg IPI calculation"
//	Note wPointsBetwPeaks_sd, "Standard deviation for points between peaks: used for SD IPI calculation"
	
	// Create a "selected" version of the M_smooth
	WAVE M_smooth
	Duplicate/O/R=[pA,pB][*] M_smooth,M_smoothSel
	
	WAVE M_smoothSel
	Duplicate/O/R=[*][i] M_smoothSel,wSmoothSel
	
	WAVE w=wSmoothSel
	Variable nRows=numpnts(w)
	Redimension/N=(nRows) w
	
	AppendToGraph w
	
	// for curve fitting
	Duplicate/O wSmoothSel,wCurves,wZCurves
	WAVE wCurves
	wCurves=NaN
	AppendToGraph/W=GraphStep2 wCurves
	ModifyGraph zColor(wCurves)={wZCurves,0,1,Rainbow,1}
	
	ControlInfo checkShowCurveFit
	if (!V_Value)
		ModifyGraph hideTrace(wCurves)=1
	endif
	
	// Make matrices with four layers: auto, add, del, and master.  These are the raster database (0 and 1s)
	Make/B/N=(nRows,nRegions,4) M_Peaks
	SetScale/P x leftx(w),deltax(w),"s", M_Peaks
//	Make/B/FREE/N=(numpnts(w)) wPeaksAuto,wPeaksAdd,wPeaksDel,wPeaks
	
//	WAVE M_Peaks
//	wPeaksAuto=M_Peaks[p][i][0]
	
	// Make a wave that holds the peak marker location
//	Duplicate w,wPeaksAuto
//	WAVE wPeaksAuto
//	wPeaksAuto=NaN
	
	//Duplicate wPeaksAuto,wPeaks
	
	Duplicate w,wMarkers		// this is the scaled wave showing peak markers for the ROI shown
	WAVE wMarkers
	wMarkers=NaN
	AppendToGraph wMarkers
	ModifyGraph mode(wMarkers)=3,marker(wMarkers)=8,opaque(wMarkers)=1
	
	ModifyGraph margin(left)=75
	ModifyGraph noLabel(left)=2,axThick(left)=0
	
	// Add a vertical scale bar (20 units)
	String yUnits=WaveUnits(w,-1)
	SetDrawEnv xcoord= prel,ycoord= left
	DrawLine kScaleBarVertical,20,kScaleBarVertical,40
	SetDrawEnv xcoord= prel,ycoord= left,textrot= 90
	DrawText kScaleBarLabel,20,num2str(20)+" "+yUnits
	
	ResizeWindow(1280,400)
	
	// Add a slider to adjust threshold
	Make/N=3 :Controls:sliderTicValue2
	Make/T/N=3 :Controls:sliderTicLabel2
	
	WAVE sliderTicValue2=:Controls:sliderTicValue2
	WAVE/T sliderTicLabel2=:Controls:sliderTicLabel2
	
	WAVE M_smoothSel
	Variable maxPeak=WaveMax(M_smoothSel)
	//Variable defaultMultiple=maxPeak/4	// empirically estimated from Isa's data
	//sliderTicValue2={maxPeak,maxPeak/2,0}
	sliderTicValue2={15,8,1}
	sliderTicLabel2[0]="High"
	sliderTicLabel2[2]="Low"
	
	// Add a setvar to adjust threshold (this is a mirror of the slider)
	SetVariable setvarSetSD title="SD",pos={1,130},proc=SetVarProcSetSD
	SetVariable setvarSetSD value= _NUM:kDefaultSDMultiple,limits={1,15,0},live=1
	SetVariable setvarSetSD userData=num2str(kDefaultSDMultiple)	// saves the value
	
	Slider sliderThreshold pos={1,150},size={69,125}
	Slider sliderThreshold proc=SliderProcThreshold,value=kDefaultSDMultiple,limits={sliderTicValue2[2],sliderTicValue2[0],0.5}
	Slider sliderThreshold userTicks={sliderTicValue2,sliderTicLabel2}
	Slider sliderThreshold help={"Adjust threshold for peak detection"}
	
	// Refractory period: don't count as a peak within a certain seconds after detecting one
	SetVariable setvarSetRefractoryPeriod title="sec",pos={1,300},proc=SetVarProcSetRefractoryPeriod
	SetVariable setvarSetRefractoryPeriod value= _NUM:kDefaultSecRefractoryPeriod,limits={0,10,0},live=1
	SetVariable setvarSetRefractoryPeriod userData=num2str(kDefaultSecRefractoryPeriod)	// saves the value
	
	Slider sliderRefractoryPeriod pos={1,315},vert=0,side=0
	Slider sliderRefractoryPeriod proc=SliderProcRefractoryPeriod,value=0
	Slider sliderRefractoryPeriod limits={0,10,0}
	
	// Add numerical incrementors to move from one ROI to another
	SetVariable setvarROI2 title="ROI",pos={1,350},size={60,20}
	SetVariable setvarROI2 proc=SetVarProcROI2,value=_NUM:i+1,limits={1,nRegions,1},live=1
	SetVariable setvarROI2 userData=num2str(i)	// saves the index of the first ROI as a string
	SetVariable setvarROI2 help={"Show trace in the particular ROI"}
	
	// Add a checkbox to show or hide curve fitting (unchecked by default)
	CheckBox checkShowCurveFit title="Show curve fit",pos={1,370},proc=CheckProcShowCurveFit,value=0
	CheckBox checkShowCurveFit help={"Check to show fitted curves"}
	
	// flippy triangle to show or hide highpass graph
	CheckBox triangleUnderDaHood title="",pos={1,385}
	CheckBox triangleUnderDaHood proc=CheckProcTriangleUnderDaHood,mode=2
	
	SetAxis left *,maxPeak
	
	// Add a button to go to Step 3
	Button buttonToStep3 title="Step 3: Rasterize >>",pos={1000,50},size={200,20}
	Button buttonToStep3 proc=ButtonProcToStep3,fColor=(0,0,65535)
	Button buttonToStep3 valueColor=(65535,65535,65535)
	Button buttonToStep3 help={"Click to rasterize"}
	
	// Make a new display with highpassed response-this will be updated in hiroDetectPeaks
	Make/O/N=0 wSmoothSel_highpass
	DoWindow GraphHighpass
	if (V_flag)
		KillWindow GraphHighpass
	endif
	Display/N=GraphHighpass wSmoothSel_highpass as "Highpass filtered"
	ModifyGraph/W=GraphHighpass margin(left)=75,rgb=(34952,34952,34952)
	
	ResizeWindow(1280,200)
	AutoPositionWindow/E/M=1
	
	DoWindow/F GraphStep2
	DoWindow/HIDE=1 GraphHighpass
	
	hwEditPeaks()
	
	Duplicate/O w,wZ
	wZ=0
	//ModifyGraph zColor(wSmoothSel)={wZ,0,1,RedWhiteBlue,0}
	ModifyGraph zColor(wSmoothSel)={wZ,0,1,BlueBlackRed,1}
	
	hiroDetectPeaks(i,kDefaultSDMultiple,kDefaultSecRefractoryPeriod)
	
End


Function CheckProcTriangleUnderDaHood(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if (checked)
				DoWindow/HIDE=0 GraphHighpass
			else
				DoWindow/HIDE=1 GraphHighpass
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSetSD(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			//Variable i=str2num(GetUserData("","setvarROI2",""))	// zero-based current ROI number
			ControlInfo setvarROI2
			Variable i=V_Value-1	// convert from one-based to zero-based
			
			ControlInfo setvarSetRefractoryPeriod
			Variable rp=V_Value
			
			//hiroDetectPeaks(i,dval,str2num(GetUserData("","setvarSetRefractoryPeriod","")))
			hiroDetectPeaks(i,dval,rp)
			DoUpdate
			
			// Update slider (a mirror)
			Slider sliderThreshold value=dval
			
			// Save the threshold value
			sva.userData=num2str(dval)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SliderProcThreshold(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				//Variable i=str2num(GetUserData("","setvarROI2",""))	// zero-based current ROI number
				
				ControlInfo setvarROI2
				Variable i=V_Value-1	// convert from one-based to zero-based
				
				ControlInfo setvarSetRefractoryPeriod
				Variable rp=V_Value
				
				//hiroDetectPeaks(i,curval,str2num(GetUserData("","setvarSetRefractoryPeriod","")))
				hiroDetectPeaks(i,curval,rp)
				DoUpdate
				
				// Update setvar (a mirror)
				SetVariable setvarSetSD value= _NUM:curval
				
				// Save the threshold value
				SetVariable setvarSetSD userData=num2str(curval)
			endif
			break
	endswitch

	return 0
End


Function SetVarProcSetRefractoryPeriod(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Update slider (a mirror)
			Slider sliderRefractoryPeriod value=dval
			
			// Save the userData value
			sva.userData=num2str(dval)
			SetVariable setvarSetRefractoryPeriod value=_NUM:dval
			
			//Print dval,str2num(GetUserData("","setvarSetRefractoryPeriod",""))
			
			//Variable i=str2num(GetUserData("","setvarROI2",""))	// zero-based current ROI number
			
			ControlInfo setvarROI2
			Variable i=V_Value-1	// convert from one-based to zero-based
			
			ControlInfo setvarSetSD
			Variable sd=V_Value
			
			//hiroDetectPeaks(i,str2num(GetUserData("","setvarSetSD","")),dval)
			hiroDetectPeaks(i,sd,dval)
			DoUpdate
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SliderProcRefractoryPeriod(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				// Update setvar (a mirror)
				SetVariable setvarSetRefractoryPeriod value= _NUM:curval
				
				// Save the userData value
				SetVariable setvarSetRefractoryPeriod userData=num2str(curval)
				
				//Variable i=str2num(GetUserData("","setvarROI2",""))	// zero-based current ROI number
				
				ControlInfo setvarROI2
				Variable i=V_Value-1	// convert from one-based to zero-based
				
				ControlInfo setvarSetSD
				Variable sd=V_Value
				
				//hiroDetectPeaks(i,str2num(GetUserData("","setvarSetSD","")),curval)
				hiroDetectPeaks(i,sd,curval)
				DoUpdate
			endif
			break
	endswitch

	return 0
End


Function UpdateTraceROI2(selected,auto)
	
	Variable selected	// 0 or 1
	Variable auto		// 0 for manual, 1 for auto
						// SetVarProcROI2 vs hiroDetectPeaksFullAuto
	
	if (selected)
		if (!auto)
			Slider sliderThreshold disable=0
			SetVariable setvarSetSD disable=0
			Slider sliderRefractoryPeriod disable=0
			SetVariable setvarSetRefractoryPeriod disable=0
			CheckBox checkShowCurveFit disable=0
		endif
		
		// Show trace on GraphHighpass
		ModifyGraph/W=GraphHighpass hideTrace=0
		
		// Show wMarkers
		ModifyGraph/W=GraphStep2 hideTrace(wMarkers)=0
		
		// show color
		//ModifyGraph/W=GraphStep2 rgb(wSmoothSel)=(65535,0,0)
		WAVE wZ
		ModifyGraph/W=GraphStep2 zColor(wSmoothSel)={wZ,0,1,BlueBlackRed,1}
	else
		// this ROI is not analyzed
		if (!auto)
			Slider sliderThreshold disable=2
			SetVariable setvarSetSD disable=2
			Slider sliderRefractoryPeriod disable=2
			SetVariable setvarSetRefractoryPeriod disable=2
			CheckBox checkShowCurveFit disable=2
		endif
		
		// Erase draw layer on GraphHighpass
		DrawAction/W=GraphHighpass delete
		ModifyGraph/W=GraphHighpass hideTrace=1
		
		// hide wMarkers
		ModifyGraph/W=GraphStep2 hideTrace(wMarkers)=1
		
		// hide color
		ModifyGraph/W=GraphStep2 rgb(wSmoothSel)=(34952,34952,34952)
		ModifyGraph/W=GraphStep2 zColor(wSmoothSel)=0
	endif
	
End


Function SetVarProcROI2(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable i
			i=dval-1	// index is zero-based, unlike the ROI which is one-based
			
			// Update trace (this is done within hiroDetectPeaks)
			//WAVE M_smoothSel
			//Duplicate/O/R=[*][i] M_smoothSel, wSmoothSel
			
			// Update peak markers
			//hwUpdatePeakMarkers(i)
			
			WAVE selROI
			UpdateTraceROI2(selROI[i],0)	// update trace appearance, e.g., color, control status, etc.
			
			if (selROI[i])
				// Detect peaks
				ControlInfo setvarSetSD
				Variable sd=V_Value
				
				ControlInfo setvarSetRefractoryPeriod
				Variable rp=V_Value
				//hiroDetectPeaks(i,str2num(GetUserData("","setvarSetSD","")),str2num(GetUserData("","setvarSetRefractoryPeriod","")))
				hiroDetectPeaks(i,sd,rp)
			else
				// Update trace
				WAVE M_smoothSel
				Duplicate/O/R=[*][i] M_smoothSel, wSmoothSel
			endif
			
			// Store this value as a string
			sva.userData=num2str(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroDetectPeaks(i,multipleSD,sRefractoryPeriod)
	// Auto-detect peaks in the trace on the graph
	
	Variable i			// ROI number (zero-based)
	
	Variable multipleSD	// e.g., 3.5
	Variable sRefractoryPeriod
	
	// Update trace
	WAVE M_smoothSel
	Duplicate/O/R=[*][i] M_smoothSel, wSmoothSel
	
	WAVE selROI
	if (!selROI[i])
		return -1	// skip unselected ROI
	endif
	
	WAVE wSmoothSel
	Variable n=numpnts(wSmoothSel)
	
	// Flush wPeaksAuto
	WAVE M_Peaks
	Make/B/FREE/N=(n) wPeaksAuto
	//WAVE wPeaksAuto
	//wPeaksAuto=M_Peaks[p][i][0]
	//wPeaksAuto=NaN
	//wPeaksAuto=0
	
	// Make an optional invisible wave that is highpass filtered
	Duplicate/O wSmoothSel,wSmoothSel_highpass
	WAVE wHi=wSmoothSel_highpass
	//Duplicate/O/FREE wSmoothSel,wHi
	
	// Apply high pass filter to flatten baseline
	// For highpass filtering, 0 < f1 < f2 < 0.5 (the normalized Nyquist frequency)
	Variable dx=deltax(wHi)
	Variable f1=kFactorRejectBand * dx		// same as f1=0.15/fs
	Variable f2=kFactorPassBand * dx
	
	// prepare coefficient for zero-phase filtering
	Duplicate/FREE wHi,wHi_coef
	
	// 101 is the number of FIR filter coefficients to generate--the larger the better stop-band rejection.
	// Wavemetrics recommends 101 as a start
	FilterFIR/COEF/HI={f1,f2,kNumFIRFiltCoeff} wHi_coef	// zero-phase coefficient
	FilterFIR/COEF=wHi_coef wHi				// high pass applied
	
	Variable sd=sqrt(Variance(wHi))
	Variable avg=mean(wHi)
	
	Variable threshold=avg+multipleSD*sd
	
	// Show the mean and the threshold on the GraphHighpass
	DrawAction/W=GraphHighpass delete	// clear
	
	Variable x1=leftx(wSmoothSel)
	Variable x2=rightx(wSmoothSel)
	SetDrawEnv/W=GraphHighpass xcoord= bottom,ycoord= left,dash= 2
	DrawLine/W=GraphHighpass x1,avg,x2,avg
	
	SetDrawEnv/W=GraphHighpass xcoord= bottom,ycoord= left,dash= 2
	DrawLine/W=GraphHighpass x1,threshold,x2,threshold
	
	Variable loc	// current location of the peak as pnt
	
	// Find the first one
	//FindPeak/M=(threshold)/P/Q wSmoothSel
//	FindPeak/M=(threshold)/P/Q wHi
//	
//	if (V_flag==0)	// peak found
//		loc=V_PeakLoc
//		//?wPeaksAuto[loc]=V_PeakVal
//		//wPeaksAuto[loc]=wSmoothSel[loc]
//		wPeaksAuto[loc]=1
//	endif
	
	// Is the refractory period set by the user?
	Variable pRefractoryPeriod
	if (sRefractoryPeriod)
		pRefractoryPeriod=round(sRefractoryPeriod/deltax(wSmoothSel))
		if (!pRefractoryPeriod)	// don't let this be zero (prevent inifinite loop below)
			pRefractoryPeriod=1
		endif
	else
		pRefractoryPeriod=1	// start the next scan one point over
	endif
	
	//Print sRefractoryPeriod,pRefractoryPeriod
	
	Variable pRangeBack=floor(ksPaddingPeakDetection/dx)	// a few seconds in terms of points
	
	// Prevent the first point to be the peak
	loc=1
	
	Variable locEnd=n-pRangeBack
	
	// Loop to find the rest
	do
		//?FindPeak/M=(threshold)/P/Q/R=[loc,n-1] wSmoothSel
		//FindPeak/M=(threshold)/P/Q/R=[loc,n-1] wHi
		FindPeak/M=(threshold)/P/Q/R=[loc,locEnd] wHi	// prevents a peak to be found at the last 5 s (important for EdgeStats later)
		if (V_flag==0)
			if (wPeaksAuto[loc]==0)
				loc=floor(V_PeakLoc)
				//Print floor(loc)
				//?wPeaksAuto[loc]=V_PeakVal
				//wPeaksAuto[loc]=wSmoothSel[loc]
				wPeaksAuto[loc]=1
			else
				// it picked up the same peak. move forward
			endif
			//Print loc,locEnd
		endif
		loc+=pRefractoryPeriod
		// special case: if the loc exceeds the pad, break (otherwise it can loop infinitely)
		if (loc>locEnd)
			break
		endif
	while(V_flag==0)
	
	// Update M_Peaks
	M_Peaks[][i][0]=wPeaksAuto[p]
	
	//Print sum(wPeaksAuto),sum(M_Peaks)
	
	// Update the peak database and the markers
	hwUpdatePeakMarkers(i)
	
End


Function hwUpdatePeakMarkers(i)
	
	Variable i	// zero-based ROI number
	
	// Save and blank peak marker
	WAVE M_Peaks
	Make/B/FREE/N=(DimSize(M_Peaks,0)) wPeaksAuto,wPeaksAdd,wPeaksDel,wPeaks
//	WAVE wPeaksAuto
//	WAVE wPeaksAdd
//	WAVE wPeaksDel
//	WAVE wPeaks
	wPeaksAuto=M_Peaks[p][i][0]
	wPeaksAdd=M_Peaks[p][i][1]
	wPeaksDel=M_Peaks[p][i][2]
	//wPeaks=M_Peaks[p][i][3]
	
	// Save
	wPeaks=wPeaksAuto+wPeaksAdd-wPeaksDel
	//? This can create 0,1,2, and -1. is this okay?  should I reduce it down to just 0 and 1?
	
	// Update M_Peaks
	M_Peaks[][i][3]=wPeaks[p]
	
	//Print sum(wPeaks)
	
	// flush and update peak markers
	Extract/FREE/INDX wPeaks,wINDX,wPeaks>0	// nevermind, it's okay
	WAVE wSmoothSel
	WAVE wMarkers
	wMarkers=NaN
//	if (numpnts(wINDX))
//		wMarkers[wINDX[p]]=wSmoothSel[wINDX[p]]
//	endif
	
	Variable npnts=numpnts(wSmoothSel)
	Variable n=numpnts(wINDX)
	
	// Make a matrix that stores variables for each peak in this ROI
	if (n)
		NewDataFolder/O :Features
		String nameM="M_features_"+num2str(i)
		Make/O/D/N=(n,19) :Features:$nameM
		WAVE M=:Features:$nameM
		
		// initialize
		M=NaN
		
		// Dimention labels
		SetDimLabel 1,0,ROI,M
		SetDimLabel 1,1,Baseline,M
		SetDimLabel 1,2,FootLoc,M
		SetDimLabel 1,3,PeakLoc,M
		SetDimLabel 1,4,TailLoc,M
		SetDimLabel 1,5,FootValue,M
		SetDimLabel 1,6,PeakValue,M
		SetDimLabel 1,7,TailValue,M
		SetDimLabel 1,8,FootLocX,M
		SetDimLabel 1,9,PeakLocX,M
		SetDimLabel 1,10,TailLocX,M
		SetDimLabel 1,11,PeakAmp,M
		SetDimLabel 1,12,DurationX,M
		SetDimLabel 1,13,Dur2PeakX,M
		SetDimLabel 1,14,FitBase,M
		SetDimLabel 1,15,FitA,M
		SetDimLabel 1,16,Tau,M
		SetDimLabel 1,17,FitConst,M
		SetDimLabel 1,18,PeakArea,M
		
		// Automatically fill the first column with ROI number (one-based)
		M[][0]=i+1
	endif
	
	// Store number of peaks (for frequency calculation later)
	WAVE wNumPeaks
	wNumPeaks[i]=n
	
	// Temporarily make a wave that keeps track of inter-peak intervals
	Variable keepIPI
	if (n>1)
		Make/FREE/N=(n-1) wIPI
		keepIPI=1
	endif
	
	//Variable t=tic()
	
	// Area measurement requires positive values. Make a wave for that.
	Duplicate/FREE wSmoothSel,wPositive
	Variable minW=abs(WaveMin(wPositive))
	MultiThread wPositive+=minW		// multithread slightly faster on Core2Duo with 10000 pnts
	
	//toc(t)
	
	// Differentiate
//	Differentiate wSmoothSel /D=wDeriv
//	WAVE wDeriv
	
	WAVE wHi=wSmoothSel_highpass
	Variable avg=mean(wHi)
	Variable sd=sqrt(Variance(wHi))
	Variable threshold=avg-sd
	
	// colorize detected peak
	Duplicate/O wSmoothSel,wZ
	wZ=0
	Variable pFoot,vFoot,vFoot_shift
	Variable pTail,vTail,vTail_shift
	
	Variable dx=deltax(wSmoothSel)
//	Variable pRangeFront=floor(2.5/dx)		// 2 s in terms of points
	Variable pRangeBack=floor(ksPredictedDecayBaseline/dx)
//	ControlInfo/W=GraphStep2 setvarSetRefractoryPeriod
//	Variable pRangeBack=floor(V_Value/dx)
	Variable avgpnts=1
	
	Variable sdSmoothSel=sqrt(Variance(wSmoothSel))
	
	Duplicate/FREE wSmoothSel,wBaseline
//	WAVE wBaseline
	Variable vPredBase
	Variable pBase_front=floor(1/dx)
	Variable pBase_back=floor(5/dx)
	Variable p1,p2
	
	Variable xPeak,xFoot,xTail,xDur,xDur2Peak
	
	// For curve fitting
	Variable fit_y0,fit_A,fit_tau,fit_const
	WAVE wCurves
	WAVE wZCurves
	fit_y0=NaN
	fit_A=NaN
	fit_tau=NaN
	fit_const=NaN
	wCurves=NaN
	wZCurves=0
	
	//Print "-"
	Variable pPrePeak=round(10/dx)	// 10 s worth of data points
	
	Variable j,k,mm
	for (j=0;j<n;j+=1)
		// Update peak markers
		k=wINDX[j]
		wMarkers[k]=wSmoothSel[k]
		
		// blank near peak so as to expose the baseline
		if (k>=pBase_front)
			p1=k-pBase_front
		else
			p1=pBase_front-k
		endif
		if (k+pBase_back<npnts)
			p2=k+pBase_back
		else
			p2=npnts-k
		endif
		wBaseline[p1,p2]=NaN
		
		// Predict baseline value near this peak
		// WARNING: p1 is repurposed below
		// Check to make sure there are enough datapoints in front of the peak
		p1=k-pPrePeak
		if (p1<0)
			// this peak is too close to the start
			p1=0
		endif
		
		//Duplicate/FREE/R=[k+5,k+15] wSmoothSel,wSnippet
		//Duplicate/FREE/R=[k-150,k] wBaseline,wSnippet	//? check for out-of-range
		Duplicate/FREE/R=[p1,k] wBaseline,wSnippet
		Extract/FREE wSnippet,wSnippet2,numtype(wSnippet)==0
		if (numpnts(wSnippet2)>5)
			vPredBase=StatsMedian(wSnippet2)
			sdSmoothSel=sqrt(Variance(wSnippet2))
		elseif (j==0)
			// for the first peak, just go for it
			vPredBase=StatsMedian(wSnippet2)
			sdSmoothSel=sqrt(Variance(wSnippet2))
		else
			//Print j,"not enough baseline points, use previous median"
		endif
//		Print j,vPredBase
		
		// Find the foot
//		EdgeStats/R=[k,k-pRangeFront]/P/F=0/A=(avgpnts)/Q/T=(pRangeFront) wSmoothSel
//		pFoot=V_EdgeLoc1
//		if (pFoot<0)
//			pFoot=0
//		endif
		// Not too good--many times the search goes too far
		
		// look for a previous zero-crossing on the derivative--this is sensitive method
		// start from two points back to make sure it doesn't cross zero at the peak
//		FindLevel/P/R=[k-2,0] wDeriv, 0
//		if (V_flag==0)
//			pFoot=floor(V_LevelX)
//		else
//			pFoot=NaN
//		endif
		// This works great except when there is a hump during the rise it stops there--need a threshold value
		
		// FindPeak backwards; threshold is one negative SD on the highpassed trace
		FindPeak/N/R=[k,0]/P/M=(threshold)/Q wHi
		if (V_flag==0)
			pFoot=floor(V_PeakLoc)
			vFoot=wSmoothSel[pFoot]
		else
			pFoot=NaN
			vFoot=NaN
			//Print j,"missing foot"
			// Manually search the baseline using FindLevel
			FindLevel/R=[k,0]/P/Q wSmoothSel,vPredBase
			if (V_flag==0)
				pFoot=floor(V_LevelX)
				//Print j,"foot adjusted"
			endif
		endif
		
		// Refine: check if the foot is close to baseline
		if (abs(vFoot-vPredBase)>0.5*sdSmoothSel)
			//Print "foot too high",j,vFoot,vTail
			// This is often caused by an undetected peak in front of this peak
			// Manually search the baseline using FindLevel
			FindLevel/R=[k,0]/P/Q wSmoothSel,vPredBase
			if (V_flag==0)
				pFoot=floor(V_LevelX)
				//Print j,"foot adjusted"
			endif
		endif
		
		// Find the tail
		mm=k+pRangeBack
//		if (mm>npnts)
//			// prevent out-of-index error
//			mm=npnts-1
//		endif
		
//		EdgeStats/R=[k,mm]/P/F=0/A=(avgpnts)/Q/T=(pRangeBack) wSmoothSel
//		if (V_flag==0)	// Level 3 found
//			pTail=floor(V_EdgeLoc3)
//			vTail=V_EdgeLvl3
//		elseif (V_flag==1)	// one or two levels found
//			// estimate
//			pTail=floor(V_EdgeLoc2+(V_EdgeLoc2-V_EdgeLoc1))
//			vTail=wSmoothSel[pTail]
//		else
//			pTail=NaN
//			vTail=NaN
//		endif
		
		//FindLevel/R=[k,mm]/EDGE=2/P/Q/T=(pRangeBack) wSmoothSel,vPredBase+0.5*sdSmoothSel
		// Sometimes if /T is present the pTail ends on a rising note. Omit.
		FindLevel/R=[k,mm]/P/Q/EDGE=2 wSmoothSel,vPredBase
		if (V_flag==0)
			pTail=floor(V_LevelX)
			vTail=wSmoothSel[pTail]
			//Print j,"good tail",pFoot,pTail
		else
			// This happens when the point doesn't reach predicted baseline value
			// Try to fit from the peak to end until it crosses 0.5 SD baseline value
			//FindLevel/R=[k,npnts-1]/P/Q wSmoothSel,vPredBase+0.5*sdSmoothSel
			FindLevel/R=[k,mm]/P/Q wSmoothSel,vPredBase+0.5*sdSmoothSel
			if (V_flag==0)
				pTail=floor(V_LevelX)
				vTail=wSmoothSel[pTail]
				//Print j,"tail adjusted 1",vPredBase,vTail
				//Print j,"tail adjusted 1",pFoot,pTail
			else
				// last resort: this may erroneously end on a rising phase
				//Print j,"missing tail, try edgestats"
				// Sometimes if /T is present the pTail ends on a rising note. Omit.
				EdgeStats/R=[k,mm]/P/F=0/A=(avgpnts)/Q/T=(pRangeBack) wSmoothSel
				EdgeStats/R=[k,mm]/P/F=0/A=(avgpnts)/Q wSmoothSel
				if (V_flag==0)	// Level 3 found
					pTail=floor(V_EdgeLoc3)
					//vTail=wSmoothSel[pTail]
					vTail=V_EdgeLvl3
					//Print j,"mm not long enough?",mm-pTail,pTail
					// Sometimes the pTail ends on a rising note. Refine?
					
				elseif (V_flag==1)	// one or two levels found
					// estimate
					pTail=floor(V_EdgeLoc2+(V_EdgeLoc2-V_EdgeLoc1))
					vTail=wSmoothSel[pTail]
				else
					//Print j,"no luck"
					pTail=NaN
					vTail=NaN
				endif
			endif
		endif
		
		// Refine?: check if the tail is close to baseline
		// Don't do this: it bleeds through too much if the baseline is going upward
//		if (abs(vTail-vPredBase)>0.5*sdSmoothSel)
//			//Print "tail too high",j,vTail,vTail
//			// This is often caused by FindLevel ending on the rising phase within restricted section
//			// Manually search the baseline backwards using FindLevel
//			FindLevel/R=[pTail,npnts-1]/P/Q wSmoothSel,vPredBase
//			if (V_flag==0)
//				pTail=floor(V_LevelX)
//				Print j,"tail adjusted 2",pTail
//			endif
//		endif
		
		// Curve Fitting
		Variable V_FitError
		V_FitError=0	// initialize to suppress singlular matrix error (see "Special Variables for Curve Fitting")
		
		KillWaves/Z W_coef,W_fitConstants,W_sigma
		
		Variable pLength=pTail-k+1
		CurveFit/N=1/W=2/Q/L=(pLength) exp_XOffset, wSmoothSel[k,pTail]/D
		WAVE/Z wFit=fit_wSmoothSel
		Variable jj
		for (jj=k;jj<k+pLength;jj+=1)
			// copy this instance to wCurves
			wCurves[jj]=wFit[jj-k]
		endfor
		WAVE/Z W_coef		// {y0,A,tau}
		//WAVE W_sigma		// SD values of the above
		
		if (WaveExists(W_coef))
			fit_y0=W_coef[0]
			fit_A=W_coef[1]
			fit_tau=W_coef[2]
		endif
		
		WAVE/Z W_fitConstants
		if (WaveExists(W_fitConstants))
			fit_const=W_fitConstants[0]
		endif
		
		// check if this is a bad fit
		if (fit_tau>0 && fit_A>0)
			if (V_chisq<6000)
				wZCurves[k,pTail]=1		// red
			else
				wZCurves[k,pTail]=ksCurveColorWarning
			endif
			if (ksTauRangeLow>fit_tau || fit_tau>ksTauRangeHigh)
				// tau is out-of-range
				wZCurves[k,pTail]=ksCurveColorWarning
			else
				wZCurves[k,pTail]=1		// red
			endif
		else
			wZCurves[k,pTail]=ksCurveColorWarning
		endif
		
		// If either pFoot or pTail is NaN, an error occurs--workaround
		if (numtype(pFoot)==0 && numtype(pTail)==0)
			wZ[pFoot,pTail]=1
		endif
		
		// keep track of number of points between this peak and the next
		if (keepIPI)
			if (j<n-1)
				wIPI[j]=wINDX[j+1]-k
			endif
		endif
		
		// Save variables to M_features
		xPeak=pnt2x(wSmoothSel,k)
		if (numtype(pFoot)==0)
			vFoot=wSmoothSel[pFoot]			// final calculation if pFoot was adjusted
			vFoot_shift=wPositive[pFoot]
			xFoot=pnt2x(wSmoothSel,pFoot)	// if pFoot is NaN, the result is -7.04093e+07 (weird)
		else
			vFoot=NaN
			vFoot_shift=NaN
			xFoot=NaN
		endif
		if (numtype(pTail)==0)
			vTail=wSmoothSel[pTail]
			vTail_shift=wPositive[pTail]
			xTail=pnt2x(wSmoothSel,pTail)
		else
			vTail=NaN
			vTail_shift=NaN
			xTail=NaN
		endif
		
		xDur=xTail-xFoot
		xDur2Peak=xPeak-xFoot
		
		M[j][1]=vPredBase		// estimated baseline value (after blanking nearby peaks)
		M[j][2]=pFoot			// location of detected foot
		M[j][3]=k				// location of detected peak
		M[j][4]=pTail			// location of detected tail
		M[j][5]=vFoot			// value of detected foot (on wSmoothSel)
		M[j][6]=wSmoothSel[k]	// value of detected peak
		M[j][7]=vTail		// value of detected tail
		M[j][8]=xFoot			// in s
		M[j][9]=xPeak			// in s
		M[j][10]=xTail			// in s
		M[j][11]=wSmoothSel[k]-vPredBase	// amplitude of detected peak (baseline subtracted)
		M[j][12]=xDur		// duration in s
		M[j][13]=xDur2Peak	// duration to peak in s
		M[j][14]=fit_y0			// baseline after tail as determined by the fit
		M[j][15]=fit_A			// what is this?
		M[j][16]=fit_tau			// tau
		M[j][17]=fit_const			// fit constant
		//M[j][18]=area(wSmoothSel,xFoot,xTail)-(vPredBase*xDur)			// area (rectangular baseline subtracted)
		//M[j][18]=area(wSmoothSel,xFoot,xTail)-(xDur*(vFoot+vTail)/2)	// area (trapezoid baseline subtracted)
		M[j][18]=area(wPositive,xFoot,xTail)-(xDur*(vFoot_shift+vTail_shift)/2)		// area (trapezoid baseline subtracted)
		
	endfor
	
	if (n)
		//ModifyGraph zColor(wSmoothSel)={wZ,*,*,RedWhiteBlue,0}
		//ModifyGraph zColor(wSmoothSel)={wZ,0,1,BlueBlackRed,1}
		
		// Bring the marker to the front
		//ReorderTraces wMarkers,{wCurves}
	else
		//ModifyGraph zColor(wSmoothSel)=0
		
		// Prevent an error that can happen when no peak is detected on the first selected trace
//		WAVE/Z fit_wSmoothSel
//		if (WaveExists(fit_wSmoothSel))
//			// append a dummy
//			Make/O/N=200 fit_wSmoothSel
//			WAVE fit_wSmoothSel
//			fit_wSmoothSel=NaN
//			AppendToGraph/W=GraphStep2 fit_wSmoothSel/TN=fit_wSmoothSel
//		endif
		
	endif
	
	// hide the fitted curve
	if (WaveExists(wFit))
		ModifyGraph hideTrace(fit_wSmoothSel)=1
	endif
	
	WAVE wPointsBetwPeaks_avg
	WAVE wPointsBetwPeaks_sd
	if (keepIPI)
		// Store average and sd of number of points in between peaks (for IPI calculation later)
		wPointsBetwPeaks_avg[i]=mean(wIPI)
		wPointsBetwPeaks_sd[i]=sqrt(Variance(wIPI))
	else
		wPointsBetwPeaks_avg[i]=NaN
		wPointsBetwPeaks_sd[i]=NaN
	endif
	
End


Function hiroDetectPeaksFullAuto()
	// Automatically detect peaks from current ROI to the end
	
	//Variable i=str2num(GetUserData("","setvarROI2",""))
	ControlInfo setvarROI2
	Variable i=V_Value-1	// convert from one-based to zero-based
	
	ControlInfo setvarSetSD
	Variable sd=V_Value
	
	ControlInfo setvarSetRefractoryPeriod
	Variable rp=V_Value
	
	Variable j
	NVAR nRegions
	
	WAVE selROI
	for (j=i;j<nRegions;j+=1)
		//hiroDetectPeaks(j,str2num(GetUserData("","setvarSetSD","")),str2num(GetUserData("","setvarSetRefractoryPeriod","")))
		hiroDetectPeaks(j,sd,rp)
		SetVariable setvarROI2 value=_NUM:j
		
		UpdateTraceROI2(selROI[j],1)
		
		DoUpdate
	endfor
	
End


//-- Manually editing detected peaks

Function hwEditPeaks()
	
	SetWindow kwTopWin,hook(getpxlhook)= hwGetPixelWindowHook
	
End


Function hwGetPixelWindowHook(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0
	switch(s.eventCode)
		case 0:              // Activate
			// Handle activate
		break
		case 1:              // Deactivate
			// Handle deactivate
			break
		case 5:		// Mouseup
	      		String key
	      		key = TraceFromPixel(s.mouseLoc.h,s.mouseLoc.v,"")
//	      		print key
	      		hwHitPointReader(key)
	      		hookResult = 1
	      		break
	      	case 11:	// Keyboard
	      		switch(s.keyCode)
	      			case 13:	// Return key
	      				hookResult = 1
	      				break
	      			case 27:	// Esc (Cancel)
					
		      			print "User canceled procedure"
		      			SetWindow kwTopWin, hook(getpxlhook)=$""
		      			hookResult = 1
	      			break
	      		endswitch
	      		break
	endswitch
	return hookResult       // 0 if nothing done, else 1
End


Function hwHitPointReader(info)
	
	// Process the input in this order:
	// 1) Reference a column (i.e., ROI) in M_PeaksAuto expressed as 0 and 1
	// 2) Update a column in M_PeaksAdd expressed as 0 and 1
	// 3) Update a column in M_PeaksDel expressed as 0 and 1
	// 4) Add 1 and 2, then subtract 3 to get M_Peaks (master)
	// 5) Extract point indeces of M_Peaks and update wPeaks on the graph
	
	String info
	String strTrace,strPoint
//	Variable n
	Variable point, i
	
	//i=str2num(GetUserData("","setvarROI2",""))
	ControlInfo setvarROI2
	i=V_Value-1	// convert from one-based to zero-based
	
	strTrace= StringByKey("TRACE",info,":",";")
	if (strlen(strTrace))
//		if (cmpstr(strTrace, "wBaseline")==0)
//			// user clicked on the wBaseline by accident. Default to the previous trace.
//			SVAR strPrevTrace
//			strTrace = strPrevTrace
//		endif
		if (cmpstr(strTrace, "wMarkers")==0)
			// user clicked on the marker. Delete the nearest hitpoint.  Default selection to the previous trace.
//			SVAR strPrevTrace
//			strTrace = strPrevTrace
			strTrace = "wSmoothSel"
		endif
		//print "Trace:", strTrace
	else
		// clicked on nothing
		return 0
	endif
	
	strPoint=StringByKey("HITPOINT",info,":",";")
	if (strlen(strPoint))
		point=str2num(strPoint)
//		print "Hit Point:", point
		
//		WAVE w=wPoints
//		n=numpnts(w)
		
//		Variable j=0
//		do
//			if (w[j]==point)	// Is this point already recorded?  If so, delete.  Otherwise the CurveFit error can occur later.
//				DeletePoints j,1,w
//				delpntconfirmed = 1
//			endif
//			j+=1
//		while(j<n)
//		
//		n=numpnts(wPoints)
		
//		Variable pntExists
		WAVE M_Peaks
		Make/B/FREE/N=(DimSize(M_Peaks,0)) wPeaksAuto,wPeaksAdd,wPeaksDel,wPeaks
//		WAVE wPeaksAuto
//		WAVE wPeaksAdd
//		WAVE wPeaksDel
//		WAVE wPeaks
		wPeaksAuto=M_Peaks[p][i][0]
		wPeaksAdd=M_Peaks[p][i][1]
		wPeaksDel=M_Peaks[p][i][2]
		wPeaks=M_Peaks[p][i][3]
		
//		Extract/FREE/INDX w,wINDX,w==point
//		if (numpnts(wINDX))
//			pntExists=1
//		endif
		
		if (wPeaks[point])
			// the point exists
			if (wPeaksAdd[point])
				// Delete from add list
				wPeaksAdd[point]=0
			endif
			if (wPeaksAuto[point])
				// Add to del list
				wPeaksDel[point]=1
			endif
		else
			// this is a new point
			wPeaksAdd[point]=1
			if (wPeaksDel[point])
				// Remove from Del list
				wPeaksDel[point]=0
			endif
		endif
		
		// Update M_Peaks
		M_Peaks[][i][1]=wPeaksAdd[p]
		M_Peaks[][i][2]=wPeaksDel[p]
			
		// Update markers
		hwUpdatePeakMarkers(i)
		
	endif
End

//--

Function ButtonProcToStep3(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			// move to step 3
			hiroStep3()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


// Step 3: rasterize and quantify

Function hiroStep3()
	
	NVAR/Z step
	if (NVAR_Exists(step))
		step=3
	endif
	
	DoWindow/F GraphStep2
	
	// Turn off window hook from step 2
	SetWindow kwTopWin, hook(getpxlhook)=$""
	
	// Disable controls
	Slider sliderThreshold disable=2
	SetVariable setvarSetSD disable=2
	Slider sliderRefractoryPeriod disable=2
	SetVariable setvarSetRefractoryPeriod disable=2
	CheckBox checkShowCurveFit disable=2
	Button buttonToStep3 disable=2
	
	// auto-complete peak detection for the rest of the ROIs
	hiroDetectPeaksFullAuto()
	
	DoWindow/HIDE=1 GraphHighpass
	DoWindow/HIDE=1 GraphStep2
	
	// Concatenate peak features
	DFREF dfrSaved=GetDataFolderDFR()
	SetDataFolder :Features
	String listM=WaveList("M_features_*",";","")
	
	listM=SortList(listM,";",16)	// sort in alphanumerical order
	
	if (ItemsInList(listM))
		//Concatenate/NP=0 listM,M_features
		Concatenate/NP=0/KILL listM,M_features
	endif
	
	SetDataFolder dfrSaved
	
	// Calculate frequency of peaks
	WAVE wNumPeaks
	Duplicate/O wNumPeaks,wFreqPeaks
//	Note/K wFreqPeaks
//	Note wFreqPeaks, "Frequency of peaks (per min)"
	
	WAVE wPointsBetwPeaks_avg
	Duplicate/O wPointsBetwPeaks_avg,wIPI_avg
//	Note/K wIPI_avg
//	Note wIPI_avg, "Average inter-peak interval (s)"
	
	WAVE wPointsBetwPeaks_sd
	Duplicate/O wPointsBetwPeaks_sd,wIPI_sd
//	Note/K wIPI_sd
//	Note wIPI_sd, "Standard deviation for inter-peak interval (s)"
	
	//Variable t=tic()
	
	WAVE wSmoothSel
	//wFreqPeaks/=(rightx(wSmoothSel)-leftx(wSmoothSel))	// Hz
	wFreqPeaks/=(rightx(wSmoothSel)-leftx(wSmoothSel)-ksPaddingPeakDetection)	// Hz (less a few secs padding)
	wFreqPeaks*=60	// convert to per min
	wIPI_avg*=deltax(wSmoothSel)
	wIPI_sd*=deltax(wSmoothSel)
	
	//toc(t)
	
	// Prompt to load ROI map if needed
	Variable loadedROImap
	if (!DataFolderExists(":map"))
//		DoAlert/T="Step 3: ROI map" 2,"Next:\rDo you have a ROI map? (as a text file)"
//		if (V_flag==1)
//			loadedROImap=hiroLoadROIMap()
//		endif
	else
		loadedROImap=1
	endif
	
	WAVE M_Peaks
	
	Variable nRows=DimSize(M_Peaks,0)
	Variable nCols=DimSize(M_Peaks,1)
	
//	Make/FREE/N=(nRows,nCols)
	
	Duplicate/FREE/R=[*][*][3] M_Peaks,M_Free
	
	// make a vector to hold 2D info
	Make/O/N=(nRows*nCols) M_Rasters
	WAVE M_Rasters
	
	// find point numbers of all peaks
	Extract/FREE/INDX M_Free,M_INDX,M_Free>0
//	WAVE M_INDX
	// blank M_Rasters
//	Make/O/N=(nRows*nCols) wRasters
	
	M_Rasters=NaN
	
	// Fill in peak info
	Variable ii
	for(ii=0;ii<numpnts(M_INDX);ii+=1)
		M_Rasters[M_INDX[ii]]=0
	endfor
	
	// Make the vector into 2D matrix
	Redimension/N=(nRows,nCols) M_Rasters
	SetScale/P x leftx(wSmoothSel),deltax(wSmoothSel),"s", M_Rasters
	
	DoWindow GraphStep3
	if (V_flag)
		KillWindow GraphStep3
	endif
	Display/K=2/N=GraphStep3 as "Step 3: Rasters"
	
	// Make custom label based on the selected ROIs only
	WAVE selROI
	Extract/FREE/INDX selROI,wINDX,selROI==1
	
	Variable n=numpnts(wINDX)
	
	Make/T/O/N=(n) :Controls:figTicLabel
	WAVE/T figTicLabel=:Controls:figTicLabel
	figTicLabel=num2str(wINDX[p]+1)		// make it 1-based
	Make/O/N=(n) :Controls:figTicValue
	
	WAVE figTicValue=:Controls:figTicValue
	figTicValue=-x
	
	String nameTrace
	Variable j
	for(ii=0;ii<n;ii+=1)
//		if (ii==0)
//			nameTrace="M_Rasters"
//		else
//			nameTrace="M_Rasters#"+num2str(ii)
//		endif
		nameTrace="Raster_"+figTicLabel(ii)	// name is 1-based
		j=str2num(figTicLabel(ii))-1			// 0-based for point number
		AppendToGraph M_Rasters[][j]/TN=$nameTrace	// TN flag Requires Igor Pro 6.20
		ModifyGraph offset($nameTrace)={0,figTicValue[ii]}
	endfor
	
	ModifyGraph mode=3,marker=10
	ModifyGraph mrkThick=0.25,rgb=(0,0,0)
	
	//? Ugly
	ModifyGraph userticks(left)={figTicValue,figTicLabel}
	ModifyGraph tick(left)=3,fSize(left)=9
	ModifyGraph noLabel(left)=2,axThick(left)=0
	
	ResizeWindow(600,350)
	
	// Add controls
	ControlBar/T 20
	CheckBox checkColorizeROIs title="Color",proc=CheckProcColorizeROIs
	
	// Add new controls for the silent cells
	PopupMenu popupColorSilent disable=1,popColor=(0,0,0)
	PopupMenu popupColorSilent proc=PopMenuProcColorChanged,value="*COLORPOP*"
	PopupMenu popupColorSilent bodyWidth=45,pos={50-5,0}	// when bodyWidth is 45, position shifts to the right by about 5
	
	TitleBox title4 title="= 0 <",disable=1,pos={100,2},frame=0
	
	PopupMenu popupColorLow disable=1,popColor=(1,16019,65535)
	PopupMenu popupColorLow proc=PopMenuProcColorChanged,value="*COLORPOP*"
	PopupMenu popupColorLow bodyWidth=45,pos={131-5,0}
	
	TitleBox title0 title="<",pos={182,2},disable=1,frame=0
	
	SetVariable setvarLowCutoff size={45,15},pos={195,2}
	SetVariable setvarLowCutoff disable=1,proc=SetVarProcLowCutoff
	SetVariable setvarLowCutoff value= _NUM:kROILowCutoffFreq,limits={0.01,kROIHighCutoffFreq,0.05},live=1
	SetVariable setvarLowCutoff userData=num2str(kROILowCutoffFreq)
	
	TitleBox title1 title="<=",pos={242,2},disable=1,frame=0
	
	PopupMenu popupColorMedium disable=1,popColor=(65535,54607,32768)
	PopupMenu popupColorMedium proc=PopMenuProcColorChanged,value="*COLORPOP*"
	PopupMenu popupColorMedium bodyWidth=45,pos={260-5,0}
	
	TitleBox title2 title="<",pos={311,2},disable=1,frame=0
	
	SetVariable setvarHighCutoff size={45,15},pos={323,2}
	SetVariable setvarHighCutoff disable=1,proc=SetVarProcHighCutoff
	SetVariable setvarHighCutoff value= _NUM:kROIHighCutoffFreq,limits={kROILowCutoffFreq,inf,0.05},live=1
	SetVariable setvarHighCutoff userData=num2str(kROIHighCutoffFreq)
	
	TitleBox title3 title="<=",pos={367,2},disable=1,frame=0
	
	PopupMenu popupColorHigh disable=1,popColor=(65535,16385,16385)
	PopupMenu popupColorHigh proc=PopMenuProcColorChanged,value="*COLORPOP*"
	PopupMenu popupColorHigh bodyWidth=45,pos={383-5,0}
	
	Button buttonFeatures title="Peak stats",pos={440,0},proc=ButtonProcFeatures
	Button buttonFeatures size={75,20}
	
	Button buttonMeasurements title="ROI stats",pos={520,0},proc=ButtonProcMeasurements
	Button buttonMeasurements size={75,20}
	
	CheckBox checkThickRasters title="Thick",pos={1,20},proc=CheckProcThickRasters
	
	// Show ROI map if loaded
	if (loadedROImap)
		hiroShowROIMap()
		
		// Add controls
		//ControlBar/L 200
	
		//hiroColorizeROI(kROILowCutoffFreq,kROIHighCutoffFreq)
		//ModifyGraph hideTrace(wOrig)=1,hideTrace(wIncluded)=1
	else
		// Load a blank map with a button in the middle
		hiroNewEmptyROIMap()
		Button buttonLoadROIs title="Load ROI positions",size={150,20},pos={100,165}	// button location conforms to 350x350 window
		Button buttonLoadROIs proc=ButtonProcLoadROIs
	endif
	
	DoWindow/F GraphStep3
	DoUpdate
	
	// Concatenate the result--each row is an ROI
	// The waves contain all ROIs.  Reduce to just the selected
	Extract/O wNumPeaks,wNumPeaks,selROI==1
	Extract/O wPointsBetwPeaks_avg,wPointsBetwPeaks_avg,selROI==1
	Extract/O wPointsBetwPeaks_sd,wPointsBetwPeaks_sd,selROI==1
	Extract/O wFreqPeaks,wFreqPeaks,selROI==1
	Extract/O wIPI_avg,wIPI_avg,selROI==1
	Extract/O wIPI_sd,wIPI_sd,selROI==1
	wINDX+=1	// make ROI number 1-based
	
	// Make the first source wave 64-bit (otherwise the concatenate will be set to I32)
	Redimension/D wINDX
	
	Concatenate/D/KILL {wINDX,wNumPeaks,wPointsBetwPeaks_avg,wPointsBetwPeaks_sd,wFreqPeaks,wIPI_avg,wIPI_sd}, M_measurements
	WAVE M_measurements
	
	SetDimLabel 1,0,ROI,M_measurements
	SetDimLabel 1,1,NumPeaks,M_measurements
	SetDimLabel 1,2,PntsBtwPeaksAvg,M_measurements
	SetDimLabel 1,3,PntsBtwPeaksSD,M_measurements
	SetDimLabel 1,4,FreqPeaks_min,M_measurements
	SetDimLabel 1,5,IPI_Avg_s,M_measurements
	SetDimLabel 1,6,IPI_SD_s,M_measurements
	
	// Add a button to go to Step 4
	ModifyGraph margin(top)=30
	Button buttonToStep4 title="Step 4: Pearson's >>",pos={400,20},size={200,20}
	Button buttonToStep4 proc=ButtonProcToStep4,fColor=(0,0,65535)
	Button buttonToStep4 valueColor=(65535,65535,65535)
	Button buttonToStep4 help={"Click to do Pearson's"}
	
End


Function ButtonProcMeasurements(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE M_measurements
			Edit/K=1 M_measurements.ld
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcFeatures(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE M=:features:M_features
			Edit/K=1 M.ld
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcColorizeROIs(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			ControlInfo/W=GraphStep3 setvarLowCutoff
			Variable f1=V_Value
			
			ControlInfo/W=GraphStep3 setvarHighCutoff
			Variable f2=V_Value
			
			if (checked)
				PopupMenu popupColorSilent disable=0
				PopupMenu popupColorLow disable=0
				PopupMenu popupColorMedium disable=0
				PopupMenu popupColorHigh disable=0
				SetVariable setvarLowCutoff disable=0
				SetVariable setvarHighCutoff disable=0
				TitleBox title0 disable=0
				TitleBox title1 disable=0
				TitleBox title2 disable=0
				TitleBox title3 disable=0
				TitleBox title4 disable=0
				
				hiroColorizeRasters(f1,f2)
				
				//hiroColorizeROI(str2num(GetUserData("","setvarLowCutoff","")),str2num(GetUserData("","setvarHighCutoff","")))
				hiroColorizeROI(f1,f2)
				
			else
				PopupMenu popupColorSilent disable=1
				PopupMenu popupColorLow disable=1
				PopupMenu popupColorMedium disable=1
				PopupMenu popupColorHigh disable=1
				SetVariable setvarLowCutoff disable=1
				SetVariable setvarHighCutoff disable=1
				TitleBox title0 disable=1
				TitleBox title1 disable=1
				TitleBox title2 disable=1
				TitleBox title3 disable=1
				TitleBox title4 disable=1
				
				ModifyGraph/W=GraphStep3 rgb=(0,0,0)
				
				//hiroColorizeROI(str2num(GetUserData("","setvarLowCutoff","")),str2num(GetUserData("","setvarHighCutoff","")))
				//hiroColorizeROI(f1,f2)
				
				if (DataFolderExists(":map"))
					DoWindow GraphROIs
					if (V_flag)
						ModifyGraph/W=GraphROIs hidetrace(wHyper)=1,hidetrace(wMedium)=1,hidetrace(wLow)=1,hidetrace(wSilent)=1
						ModifyGraph/W=GraphROIs hidetrace(wOrig)=0,hidetrace(wIncluded)=0
					endif
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcThickRasters(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if (checked)
				ModifyGraph/W=GraphStep3 mrkThick=2
			else
				ModifyGraph/W=GraphStep3 mrkThick=0.25
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProcColorChanged(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			ControlInfo/W=GraphStep3 setvarLowCutoff
			Variable f1=V_Value
			
			ControlInfo/W=GraphStep3 setvarHighCutoff
			Variable f2=V_Value
			
			//hiroColorizeROI(str2num(GetUserData("","setvarLowCutoff","")),str2num(GetUserData("","setvarHighCutoff","")))
			hiroColorizeROI(f1,f2)
			hiroColorizeRasters(f1,f2)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcLowCutoff(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo/W=GraphStep3 setvarHighCutoff
			Variable f2=V_Value
			
			hiroColorizeRasters(dval,f2)
			
			//hiroColorizeROI(dval,str2num(GetUserData("","setvarHighCutoff","")))
			hiroColorizeROI(dval,f2)
			
			hiroCategorizeROIpairsByFreq(dval,f2)
			
			hiroUpdateMeanPlot()
			
			SetVariable setvarHighCutoff limits={dval,inf,0.05}
			
			SetVariable setvarLowCutoff userData=num2str(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcHighCutoff(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo/W=GraphStep3 setvarLowCutoff
			Variable f1=V_Value
			
			hiroColorizeRasters(f1,dval)
			
			//hiroColorizeROI(str2num(GetUserData("","setvarLowCutoff","")),dval)
			hiroColorizeROI(f1,dval)
			
			hiroCategorizeROIpairsByFreq(f1,dval)
			
			hiroUpdateMeanPlot()
			
			SetVariable setvarLowCutoff limits={0.01,dval,0.05}
			
			SetVariable setvarHighCutoff userData=num2str(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroDefineFreqCode()
	
	// make a pair of waves that defines the freq code as follows
	// yields unique combo (the freq code)
	// S-S		1+1=2
	// S-L		1+2=3
	// S-M		1+4=5
	// S-H		1+8=9
	// L-L		2+2=4
	// L-M		2+4=6
	// L-H		2+8=10
	// M-M	4+4=8
	// M-H		4+8=12
	// H-H		8+8=16
	
	Make/N=10 wFreqCodeGroup_P
	Make/T/N=10 wFreqCodeGroup_T
	
	WAVE wP=wFreqCodeGroup_P
	WAVE/T wT=wFreqCodeGroup_T
	
	// S-S
	wP[0]=2
	wT[0]="SS"
	
	// S-L
	wP[1]=3
	wT[1]="SL"
	
	// S-M
	wP[2]=5
	wT[2]="SM"
	
	// S-H
	wP[3]=9
	wT[3]="SH"
	
	// L-L
	wP[4]=4
	wT[4]="LL"
	
	// L-M
	wP[5]=6
	wT[5]="LM"
	
	// L-H
	wP[6]=10
	wT[6]="LH"
	
	// M-M
	wP[7]=8
	wT[7]="MM"
	
	// M-H
	wP[8]=12
	wT[8]="MH"
	
	// H-H
	wP[9]=16
	wT[9]="HH"
	
End


Function hiroCategorizeROIpairsByFreq(f1,f2)
	
	// bitwise categorization
	// Silent (S)	2^0 = 1
	// Low (L)		2^1 = 2
	// Med (M)		2^2 = 4
	// High (H)		2^3 = 8
	
	// yields unique combo (the freq code)
	// S-S		1+1=2
	// S-L		1+2=3
	// S-M		1+4=5
	// S-H		1+8=9
	// L-L		2+2=4
	// L-M		2+4=6
	// L-H		2+8=10
	// M-M	4+4=8
	// M-H		4+8=12
	// H-H		8+8=16
	
	Variable f1	// low cutoff (e.g., 0.3 for less active cells)
	Variable f2	// high cutoff (e.g., 3 for hyperactive cells)
	
	if (!DataFolderExists(":map"))
		return 0
	endif
	
	WAVE/Z M=M_ROI_Freq_code
	if (!WaveExists(M))
		return 0
	endif
	
	// init
	M=0
	
	WAVE M_measurements
	Make/FREE/N=(DimSize(M_measurements,0)) wFreqPeaks,wROI
	//WAVE wFreqPeaks	// this contains selected ROIs only
	wFreqPeaks=M_measurements[p][4]
	
	// a ref to the actual ROI (can't assume row number is ROI number)
	wROI=M_measurements[p][0]
	
	wROI-=1	// zero-based
	
	NVAR nRegions
	
	Variable i,k
	Variable iFreq,kFreq
	Variable iCode,kCode
	for(i=0;i<nRegions;i+=1)
		for(k=0;k<i;k+=1)
			// init
			iCode=0
			kCode=0
			
			FindValue/V=(i) wROI
			iFreq=V_value	// row number in freq data for i-th ROI
			if (iFreq>=0)	// -1 means this ROI is excluded
				iCode=hiroFreqCode(f1,f2,wFreqPeaks[iFreq])
			endif
			
			if (iCode)
				FindValue/V=(k) wROI
				kFreq=V_value	// row number in freq data for k-th ROI
				if (kFreq>=0)	// -1 means this ROI is excluded
					kCode=hiroFreqCode(f1,f2,wFreqPeaks[kFreq])
				endif
				
				if (kCode)
					// Save the sum
					M[k][i]=iCode+kCode
				endif
			endif
		endfor
	endfor
	
	// Regroup according to this new freq code
	WAVE M_Pearson
	hiroUpdateGroupsByFreqCode(M_Pearson,"Pearson")
	
	WAVE M_ROI_Distances
	hiroUpdateGroupsByFreqCode(M_ROI_Distances,"Distance")
	
End


Function hiroFreqCode(f1,f2,freq)
	// See hiroCategorizeROIpairsByFreq()
	
	Variable f1
	Variable f2
	Variable freq
	Variable code
	
	if (freq>=f2)
		// High
		code=8
	elseif (f1<=freq && freq<f2)
		// Med
		code=4
	elseif (freq<f1 && 0<freq)
		// Low
		code=2
	elseif (freq==0)
		// Silent
		code=1
	else
		print "problem reading the freq code for a cell"
	endif
	
	return code
	
End


Function hiroUpdateGroupsByFreqCode(M,nameDF)
	
	WAVE M
	String nameDF
	
	WAVE wP=wFreqCodeGroup_P
	WAVE/T wT=wFreqCodeGroup_T
	
	Variable i
	for(i=0;i<numpnts(wP);i+=1)
		hiroGroupByFreqCode(M,wP[i],wT[i],nameDF)
	endfor
	
	//PlotMeanMono("LL;LM;MM","*",0)
	
End


Function hiroGroupByFreqCode(Mat,code,nameM,nameDF)
	// Read the frequency code, find ROI pairs and assign data from other matrix
	
	WAVE Mat		// e.g., M_Pearson or M_ROI_Distances (a half-filled square matrix)
	Variable code	// e.g., 8 for M-M (see hiroCategorizeROIpairsByFreq)
	String nameM
	String nameDF
	
	WAVE M=M_ROI_Freq_code
	// this matrix lacks NaN, so I can use with Extract as is
	
	Variable n=DimSize(M,0)
	
	Duplicate/FREE M,w1D
	Redimension/N=(n^2) w1D
	
	Extract/FREE/INDX w1D,wINDX,w1D==code
	
	Variable nINDX=numpnts(wINDX)
	//Make/N=(nINDX) $nameM
	//WAVE w=$nameM
	Make/FREE/N=(nINDX) w
	Make/T/FREE/N=(nINDX) wT
	
	Variable row,col
	Variable i
	for(i=0;i<nINDX;i+=1)
		col=floor(wINDX[i]/n)
		row=wINDX[i]-n*col
		w[i]=Mat[row][col]
		wT[i]=num2str(row+1)+","+num2str(col+1)	// 1-based ROI number?// check selROI?
	endfor
	
	NewDataFolder/O $nameDF
	DFREF dfr=:$nameDF
	
	Duplicate/O w,dfr:$nameM
	
	nameM=nameM+"_ROIs"
	Duplicate/O wT,dfr:$nameM
	
End


Function hiroColorizeROI(f1,f2)
	// Based on wFreqPeaks, colorize ROI
	
	Variable f1	// low cutoff (e.g., 0.3 for less active cells)
	Variable f2	// high cutoff (e.g., 3 for hyperactive cells)
	
	// check if the ROI data exists
	if (!DataFolderExists(":map"))
		return -1
	endif
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	WAVE M_measurements
	Make/FREE/N=(DimSize(M_measurements,0)) wFreqPeaks
	//WAVE wFreqPeaks	// this contains selected ROIs only
	wFreqPeaks=M_measurements[p][4]
	
	SetDataFolder :map
	
	WAVE wIncluded		// so does this
	WAVE wIncludedX
	
	// find ROIs that are hyperactive (3/min)
	Extract wIncluded,wHyper,wFreqPeaks>=f2
	Extract wIncludedX,wHyperX,wFreqPeaks>=f2
	
	// between 0.3 and 3 / min
	Extract wIncluded,wMedium,f1<=wFreqPeaks && wFreqPeaks<f2
	Extract wIncludedX,wMediumX,f1<=wFreqPeaks && wFreqPeaks<f2
	
	// below 0.3 / min but not silent
	Extract wIncluded,wLow,wFreqPeaks<f1 && 0<wFreqPeaks
	Extract wIncludedX,wLowX,wFreqPeaks<f1 && 0<wFreqPeaks
	
	// silent cells
	Extract wIncluded,wSilent,wFreqPeaks==0
	Extract wIncludedX,wSilentX,wFreqPeaks==0
	
	ControlInfo/W=GraphStep3 popupColorSilent
	ModifyGraph/W=GraphROIs rgb(wSilent)=(V_Red,V_Green,V_Blue)
	
	ControlInfo/W=GraphStep3 popupColorLow
	ModifyGraph/W=GraphROIs rgb(wLow)=(V_Red,V_Green,V_Blue)
	
	ControlInfo/W=GraphStep3 popupColorMedium
	ModifyGraph/W=GraphROIs rgb(wMedium)=(V_Red,V_Green,V_Blue)
	
	ControlInfo/W=GraphStep3 popupColorHigh
	ModifyGraph/W=GraphROIs rgb(wHyper)=(V_Red,V_Green,V_Blue)
	
	ControlInfo/W=GraphStep3 checkColorizeROIs
	if (V_Value)
		// Colorize is on
		ModifyGraph/W=GraphROIs hidetrace(wHyper)=0,hidetrace(wMedium)=0,hidetrace(wLow)=0,hidetrace(wSilent)=0
		ModifyGraph/W=GraphROIs hidetrace(wOrig)=1,hidetrace(wIncluded)=1
	endif
	
	SetDataFolder dfrSaved
	
End


Function hiroColorizeRasters(f1,f2)
	
	Variable f1
	Variable f2
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	WAVE M_measurements
	
	Make/FREE/N=(DimSize(M_measurements,0)) wROIs,wFreqPeaks
	//WAVE wFreqPeaks
	wFreqPeaks=M_measurements[p][4]	// includes selected ROIs only
	//WAVE selROI
	wROIs=M_measurements[p][0]
	
	String nameW
	Variable n,j
	
	// Hyper
	Extract/FREE wROIs,wSelROIs,wFreqPeaks>=f2
	n=numpnts(wSelROIs)
	//Print n
	ControlInfo/W=GraphStep3 popupColorHigh
	for(j=0;j<n;j+=1)
		nameW="Raster_"+num2str(wSelROIs[j])		// 1-based
		// Check if the trace exists on the graph
		//WAVE/Z w=TraceNameToWaveRef("",nameW)
		//if(WaveExists(w))
			ModifyGraph/W=GraphStep3 rgb($nameW)=(V_Red,V_Green,V_Blue)
		//endif
	endfor
	
	WAVEClear wSelROIs
	
	// Medium
	Extract/FREE wROIs,wSelROIs,f1<=wFreqPeaks && wFreqPeaks<f2
	n=numpnts(wSelROIs)
	
	ControlInfo/W=GraphStep3 popupColorMedium
	for(j=0;j<n;j+=1)
		nameW="Raster_"+num2str(wSelROIs[j])		// 1-based
		//WAVE/Z w=TraceNameToWaveRef("",nameW)
		//if(WaveExists(w))
			ModifyGraph/W=GraphStep3 rgb($nameW)=(V_Red,V_Green,V_Blue)
		//endif
	endfor
	
	WAVEClear wSelROIs
	
	// Low
	Extract/FREE wROIs,wSelROIs,wFreqPeaks<f1 && 0<wFreqPeaks
	n=numpnts(wSelROIs)
	
	ControlInfo/W=GraphStep3 popupColorLow
	for(j=0;j<n;j+=1)
		nameW="Raster_"+num2str(wSelROIs[j])		// 1-based
		//WAVE/Z w=TraceNameToWaveRef("",nameW)
		//if(WaveExists(w))
			ModifyGraph/W=GraphStep3 rgb($nameW)=(V_Red,V_Green,V_Blue)
		//endif
	endfor
	
	SetDataFolder dfrSaved
	
End


Function hiroLoadROIMap()
	// This imports ROI coordinates from a text file--it doesn't do anything with selROI yet
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	// Load ROI as tab delimited text
	Variable type	// 3 for txt
	
	type = GetFileInfo(3)	// Creates a global variables for file name and path in root:temp
	
	//String nameDF
	
	if (type==3)
		LoadDataAsGeneralText(0)	// 1 loads as Matrix
	else
		//Abort
		return 0	// file not loaded
	endif
	
	// Check if the user opened the correct file: it should have three numerical waves
	SVAR folderPath
	SVAR fileName
	
	DFREF dfr=GetDataFolderDFR()
	Variable nWaves=CountObjectsDFR(dfr,1)
	if (nWaves!=3)
		String strErr
		strErr="Cannot find the position of the ROIs in this file:\r\r"+folderPath+fileName+"\r\rTry again: ask Hiro if you need help"
		DoAlert/T="Wrong file" 0,strErr
		//KillDataFolder root:temp
		SetDataFolder dfrSaved
		return 0
	endif
	
	WAVE R2
	WAVE R1
	WAVE R0
	
	Duplicate/O R2, wOrig
	Duplicate/O R1, wOrigX
	KillWaves R0,R1,R2
	
	KillVariables nRegions
	
	// Ask image size
	Variable pxWidth=512
	Variable pxHeight=512
	Variable umWidth
	do
		Prompt umWidth, "Width (µm) for pixel-to-µm conversion"
		Prompt pxWidth, "Width (pixels)"
		Prompt pxHeight, "Height (pixels)"
		DoPrompt/HELP="Enter a positive number. Hit a tab-key to toggle between the two fields." "Image size?",umWidth,pxWidth,pxHeight
		if (V_flag == 1)
			Print "User Canceled Procedure"
			Abort	//quit if cancel button was clicked
		endif
	while(pxWidth<=0 || pxHeight<=0 || umWidth<=0)
	
	Variable/G imageScaleFactor=pxWidth/umWidth		// pixels/µm
	Variable/G imageWidth=pxWidth/imageScaleFactor
	Variable/G imageHeight=pxHeight/imageScaleFactor
	
	// convert pixels to µm
	wOrig/=imageScaleFactor
	wOrigX/=imageScaleFactor
	SetScale d 0,0,"µm", wOrig,wOrigX
	
	Print folderPath+fileName
	Print "-Loaded ROI positions"
	Print "-Image size",imageWidth,"x",imageHeight,"µm"
	Print "-Scale factor",imageScaleFactor,"pixels/µm"
	
	// rename and move the DF
	DuplicateDataFolder root:temp,dfrSaved:map
	KillDataFolder root:temp
	
	SetDataFolder dfrSaved
	
	// Calculate ROI distances
	hiroCalculateROIDistances()
	
	return type
	
End


Function hiroShowROIMap()
	// Show imported ROI map--sets selROI rule in a new layer
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	WAVE selROI
	
	SetDataFolder :map
	
	WAVE wOrig
	WAVE wOrigX
	
	// Make a new ROI dataset based on selROI rule
	Extract wOrig,wIncluded,selROI==1
	Extract wOrigX,wIncludedX,selROI==1
	
	WAVE wIncluded
	WAVE wIncludedX
	
	hiroNewEmptyROIMap()
	
	AppendToGraph/W=GraphROIs wOrig vs wOrigX
	AppendToGraph/W=GraphROIs wIncluded vs wIncludedX
	ModifyGraph/W=GraphROIs mode=3,marker(wOrig)=8,marker(wIncluded)=19
	ModifyGraph/W=GraphROIs rgb=(34952,34952,34952)
	
	WipeAllAxes()
	
	NVAR imageWidth
	NVAR imageHeight
	
	SetAxis/W=GraphROIs bottom 0,imageWidth
	SetAxis/W=GraphROIs/R left imageHeight,0	// this axis must be reversed
	
	// Rescale window proportionally so that the height stays 350
	Variable widthFactor=imageWidth/imageHeight
	ResizeWindow(widthFactor*kROIMapWindowSize,kROIMapWindowSize)
	
	// Initialize ROIs for dynamic color coding
	Make/O/N=0 wHyper,wMedium,wLow,wSilent
	Make/O/N=0 wHyperX,wMediumX,wLowX,wSilentX
	WAVE wHyper
	WAVE wMedium
	WAVE wLow
	WAVE wSilent
	WAVE wHyperX
	WAVE wMediumX
	WAVE wLowX
	WAVE wSilentX
	
	DoWindow GraphROIs
	if (V_flag)
		AppendToGraph/W=GraphROIs wSilent vs wSilentX
		AppendToGraph/W=GraphROIs wLow vs wLowX
		AppendToGraph/W=GraphROIs wMedium vs wMediumX
		AppendToGraph/W=GraphROIs wHyper vs wHyperX
		
		ModifyGraph/W=GraphROIs mode=3
		ModifyGraph/W=GraphROIs marker(wSilent)=19,rgb(wSilent)=(0,0,0)
		ModifyGraph/W=GraphROIs marker(wLow)=19,rgb(wLow)=(49151,53155,65535)
		ModifyGraph/W=GraphROIs marker(wMedium)=19,rgb(wMedium)=(32769,65535,32768)
		ModifyGraph/W=GraphROIs marker(wHyper)=19,rgb(wHyper)=(65535,49157,16385)
	endif
	
	SetDataFolder dfrSaved
	
	// Add two more markers A and B (for Step 4)
	hiroNewEmptyROIMarkersAB()
	
	// If already in Step 4, recalculate everything so that rho vs distance is available
	ControlInfo/W=GraphROIPairs setvarBinSize
	if (V_flag!=0)
		hiroAutoPearsons(V_Value)
		hiroShowPearsonVsDistance()
	endif
	
	// Colorize if the checkbox is on
	ControlInfo/W=GraphStep3 checkColorizeROIs
	if (V_Value)
		ControlInfo/W=GraphStep3 setvarLowCutoff
		Variable f1=V_Value
		
		ControlInfo/W=GraphStep3 setvarHighCutoff
		Variable f2=V_Value
		
		hiroColorizeROI(f1,f2)
	endif
	
End


Function hiroNewEmptyROIMap()
	
	DoWindow/F GraphStep3
	
	DoWindow GraphROIs
	if (V_flag)
		KillWindow GraphROIs
	endif
	Display/K=2/N=GraphROIs as "Map"
	
	WipeAllAxes()
	ModifyGraph margin=1
	
	ResizeWindow(kROIMapWindowSize,kROIMapWindowSize)
	
	// position to the right of the rasters
	AutoPositionWindow/E/M=0
	
End


Function ButtonProcLoadROIs(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Variable loadedROIs=hiroLoadROIMap()
			
			if (loadedROIs)
				hiroShowROIMap()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//Function hiroPutMarkersOnPeaks()
//	
//	// Location info (x-scaled) comes from Mult-peak Fit
//	
//	WAVE xLoc
//	
//	// Make a wave that contains amplitude info
//	Duplicate xLoc,yLoc
//	WAVE yLoc
//	WAVE filtered_smth
//	yLoc=filtered_smth(xLoc)
//	
//	// Display the markers and the filtered trace
//	Display yLoc vs xLoc
//	AppendToGraph filtered_smth
//	
//	ModifyGraph mode(yLoc)=3,marker(yLoc)=8,opaque(yLoc)=1,rgb(yLoc)=(0,0,0)
//	
//	ReorderTraces yLoc,{filtered_smth}
//	
//End


//Function testStraightenBaseline()
//	
//	WAVE M_smooth
//	Duplicate/O/R=[][0] M_smooth,w0,w1,w2,w3,w4,w5
//	
//	Display
//	
//	WAVE w0
//	WAVE w1
//	WAVE w2
//	WAVE w3
//	WAVE w4
//	WAVE w5
//	
//	Redimension/N=(10000) w0,w1,w2,w3,w4,w5
//	
//	AppendToGraph w0,w1,w2,w3,w4,w5
//	
//	ModifyGraph offset(w0)={0,0}
//	ModifyGraph offset(w1)={0,-40}
//	ModifyGraph offset(w2)={0,-80}
//	ModifyGraph offset(w3)={0,-120}
//	ModifyGraph offset(w4)={0,-160}
//	ModifyGraph offset(w5)={0,-200}
//	
//	ResizeWindow(600,600)
//	
//	FilterFIR/HI={0.015,0.02,101} w1	// too much
//	FilterFIR/HI={0.01,0.02,101} w2		// like if fs=15?  f1=0.15/15, f2=0.3/15
//	FilterFIR/HI={0.005,0.01,101} w3	// like if fs=30?  f1=0.15/30, f2=0.3/30
//	FilterFIR/HI={0.002,0.01,101} w4	// not enough
//	FilterFIR/HI={0.0005,0.005,101} w5	// nope
//	
//	Print "0",WaveMax(w0),"max",sqrt(Variance(w0)),"SD",WaveMax(w0)/sqrt(Variance(w0))
//	Print "1",WaveMax(w1),"max",sqrt(Variance(w1)),"SD",WaveMax(w1)/sqrt(Variance(w1))
//	Print "2",WaveMax(w2),"max",sqrt(Variance(w2)),"SD",WaveMax(w2)/sqrt(Variance(w2))
//	Print "3",WaveMax(w3),"max",sqrt(Variance(w3)),"SD",WaveMax(w3)/sqrt(Variance(w3))
//	Print "4",WaveMax(w4),"max",sqrt(Variance(w4)),"SD",WaveMax(w4)/sqrt(Variance(w4))
//	Print "5",WaveMax(w5),"max",sqrt(Variance(w5)),"SD",WaveMax(w5)/sqrt(Variance(w5))
//	
//	// based on preliminary results,
//	// f1=0.15/fs
//	// f2=0.3/fs
//	// is optimal because the peak-to-SD ratio is highest
//	
//End


Function hiroShowROIsAsContours(mode)
	
	Variable mode	// 0 for pixels, otherwise scaled to µm
	
	if (DataFolderExists(":Contours"))
		return 0
	endif
	
	String nameDF
	String strTitle
	
	if (mode)
		nameDF=":ROIs_scaled"	// µm
		strTitle="ROIs (Scaled)"
	else
		nameDF=":ROIs"		// pixels
		strTitle="ROIs (pixels)"
	endif
	
	if (!DataFolderExists(nameDF))
		return 0
	endif
	
	NewDataFolder/O :Contours
	
	//DFREF dfr=:ROIs_scaled
	DFREF dfr=$nameDF
	DFREF dfrM=:map
	DFREF dfrC=:Contours
	
	DoWindow GraphROIScaled
	if (V_flag)
		KillWindow GraphROIScaled
	endif
	Display/N=GraphROIScaled/K=2 as strTitle
	
	String nameROI
	Variable nROIs=CountObjectsDFR(dfr,1)
	Variable nRows
	Variable i
	for(i=0;i<nROIs;i+=1)
		nameROI=GetIndexedObjNameDFR(dfr,1,i)
		WAVE M_ROI=dfr:$nameROI
		nRows=DimSize(M_ROI,0)
		
		// make a duplicate with one extra row to "close" the contour
		Duplicate/FREE M_ROI,M_ROIPlus
		Redimension/N=(nRows+1,2) M_ROIPlus
		
		// fill in the first point as the last
		M_ROIPlus[nRows][0]=M_ROIPlus[0][0]
		M_ROIPlus[nRows][1]=M_ROIPlus[0][1]
		
		Make/FREE/N=(nRows+1) wZ
		// add the third dimension and store in Contours DF
		Concatenate/O {M_ROIPlus,wZ},dfrC:$nameROI
		WAVE M_Contour=dfrC:$nameROI
		AppendXYZContour M_Contour
		ModifyContour $nameROI rgbLines=(65535,0,0),xymarkers=1
	endfor
	
	ModifyGraph/W=GraphROIScaled mode=0,margin=1
	
	NVAR imageHeight=dfrM:imageHeight
	NVAR imageWidth=dfrM:imageWidth
	SetAxis/W=GraphROIScaled left imageHeight,0	// reversed
	SetAxis/W=GraphROIScaled bottom 0,imageWidth
	
	// Append wOrig
	WAVE wOrig=dfrM:wOrig
	WAVE wOrigX=dfrM:wOrigX
	AppendToGraph/W=GraphROIScaled wOrig vs wOrigX
	
	// Make a text wave to label ROIs
	Make/T/N=(nROIs) dfrM:wROILabels
	WAVE/T wT=dfrM:wROILabels
	wT=num2str(x+1)
	
	ModifyGraph/W=GraphROIScaled mode(wOrig)=3
	ModifyGraph/W=GraphROIScaled textMarker(wOrig)={dfrM:wROILabels,"default",0,0,5,0.00,0.00}
	
	// gray color
	ModifyGraph/W=GraphROIScaled rgb=(34952,34952,34952)
	
	ResizeWindow(350,350*imageHeight/imageWidth)
	
	WipeAllAxes()	// hides units
	
End


// Step 4: Pearson's r
Function ButtonProcToStep4(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			if (!DataFolderExists(":map"))
				DoAlert/T="Missing ROI data" 0,"Please load the ROI position and try again."
				break
			endif
			
			hiroPreStep4Prompt()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroStep4()
	
	NVAR/Z step
	if (NVAR_Exists(step))
		step=4
	endif
	
	DoWindow/F GraphStep3
	
	// Hide and Disable controls
	Button buttonToStep4 disable=3
	ModifyGraph/W=GraphStep3 margin=0
	
	// Label for the ROI pairs
	Make/T/O/N=2 :Controls:wT_ROIPair
	Make/O/N=2 :Controls:wP_ROIPair
	WAVE/T wT=:Controls:wT_ROIPair
	WAVE wP=:Controls:wP_ROIPair
	wP=kOffsetWaveBHistogram*x
	
	// Optionally create new markers on ROI map
	hiroNewEmptyROIMarkersAB()
	
	// If missing, calculate ROI distances
	WAVE/Z M_ROI_Distances
	if (!WaveExists(M_ROI_Distances))
		hiroCalculateROIDistances()
		WAVE M_ROI_Distances
	endif
	
	// Automatically make histogram, do Pearson's, then rank the result, etc.
	hiroAutoPearsons(kmsDefaultBinSize)
	WAVE/T M_Pearson_pairs_t
	
	DoWindow/F GraphStep3
	DoWindow GraphROIPairs
	if (V_flag)
		KillWindow GraphROIPairs
	endif
	Display/K=2/N=GraphROIPairs as "Step 4: Pearson's Correlation Coefficient"
	
	ResizeWindow(550,300)
	
	AutoPositionWindow/E/M=1
	
	ControlBar/L/W=GraphROIPairs 150
	ListBox listROIPairsPearson mode=1,proc=ListBoxProcROIPairsPearson
	ListBox listROIPairsPearson size={150,300},frame=0,listWave=M_Pearson_pairs_t
	
	// Show a histogram of ROI pair
	WAVE waveA
	WAVE waveB
	AppendToGraph/W=GraphROIPairs waveA,waveB
	
	ModifyGraph/W=GraphROIPairs mode=6,offset(waveB)={0,kOffsetWaveBHistogram}
	ModifyGraph/W=GraphROIPairs userticks(left)={wP,wT}
	
	// Add a setvar to adjust bin size
	ControlBar/T 20
	WAVE M_Peaks
	Variable msDuration=1000*rightx(M_Peaks)-leftx(M_Peaks)
	SetVariable setvarBinSize title="bin (ms)",size={100,20},proc=SetVarProcBinSize
	SetVariable setvarBinSize value=_NUM:kmsDefaultBinSize,limits={0,msDuration,10}
	
	PopupMenu popupShowAs title="Show as",pos={275,0},proc=PopMenuProcShowAs,mode=1
	PopupMenu popupShowAs value="Histogram;Raster;Trace"
	
	Button buttonPearson title="Pearson's",pos={470,0},proc=ButtonProcPearson
	Button buttonPearson size={75,20}
	
	if (WaveExists(M_ROI_Distances))
		// show graph
		hiroShowPearsonVsDistance()
	endif
	
	hiroShowColorCorrelationMap()
	
	// Frequency categorization of cells
	NVAR nRegions
	Make/O/N=(nRegions,nRegions) M_ROI_Freq_code
	
	hiroDefineFreqCode()	// create a wave containing the definition of the freq code
	
	hiroCategorizeROIpairsByFreq(kROILowCutoffFreq,kROIHighCutoffFreq)
	
	// graph the result
	hiroUpdateMeanPlot()
	
	// position the graphs
	DoWindow/F GraphROIs
	DoWindow/F GraphMeanDistance
	AutoPositionWindow/E
	DoWindow/F GraphMeanPearson
	AutoPositionWindow/E/M=1
	
End


Function hiroUpdateMeanPlot()
	
	if (!DataFolderExists(":Distance"))
		// do nothing
		return 0
	endif
	
	DFREF dfr=:Distance
	String listW="SS;SL;SM;SH;LL;LM;LH;MM;MH;HH"
	
	hiroPlotMeanDynamic(dfr,listW)
	
	DFREF dfr=:Pearson
	listW="LL;LM;LH;MM;MH;HH"
	
	hiroPlotMeanDynamic(dfr,listW)
	
End


Function hiroPlotMeanDynamic(dfr,listW)
	// updates content of an existing mean plot
	// modeled after PlotMeanMono, but no stats will be done
	// new structure:
	// dfr is a ref to the DF that contains vectorized data of each group
	// a sub DF called "graph" contains wAvg, wStem, etc.
	
	DFREF dfr		// DF containing the waves
	String listW	// list of waves in the DF to plot (in the order it is listed)
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	Variable n=ItemsInList(listW)
	
	// Has this DF been analyzed before?
	String nameGraphDF=GetIndexedObjNameDFR(dfr,4,0)
	if (!strlen(nameGraphDF))
		// no. plot a new graph
		hiroPlotMeanDynamicInit(dfr,listW)
		nameGraphDF="graph"
	endif
	
	DFREF dfrGraph=dfr:graph
	
	// Define wVertHolder after finding the largest numpnts in the waves inside the specified DF
	Variable nVert=hiroFindLargestNumPnts(dfr,listW)
	Make/O/N=(nVert) dfrGraph:wVertHolder
	
	WAVE wAvg=dfrGraph:wAvg
	WAVE wStem=dfrGraph:wStem
	
	String nameW
	Variable i
	for(i=0;i<n;i+=1)
		nameW=StringFromList(i,listW)
		WAVE w=dfr:$nameW
		wAvg[i]=mean(w)
		//wStem[i]=sqrt(Variance(w))/sqrt(numpnts(w))
		wStem[i]=sqrt(Variance(w)/numpnts(w))
		//Print nameW,wAvg[i],"±",wStem[i]
	endfor
	
	SetDataFolder dfrSaved
	
End


Function hiroTabulateDataInAllGroups(mode)
	
	Variable mode	// 0 for distance, 1 for pearson
	
	// Order from SS->HH, ROI included
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	String nameGraph,strTitle
	if (!mode)
		SetDataFolder :Distance
		nameGraph="TableDistanceGroups"
		strTitle="Distance Groups: All"
	else
		SetDataFolder :Pearson
		nameGraph="TablePearsonGroups"
		strTitle="Pearson Groups: All"
	endif
	
	// Get a list of groups without "_ROIs"
	String list= WaveList("!*_ROIs",";","")
	
	if (mode)
		list=RemoveFromList("SS",list)
		list=RemoveFromList("SL",list)
		list=RemoveFromList("SM",list)
		list=RemoveFromList("SH",list)
	endif
	
	String nameW,nameW2
	
	Variable i
	
	for (i=0;i<ItemsInList(list);i+=1)
		nameW=StringFromList(i,list)
		nameW2=nameW+"_ROIs"
		if (i)
			AppendToTable/W=$nameGraph $nameW2,$nameW
		else
			DoWindow $nameGraph
			if (V_Flag)
				KillWindow $nameGraph
			endif
			Edit/K=1/N=$nameGraph $nameW2,$nameW as strTitle
		endif
	endfor
	
	SetDataFolder dfrSaved
	
End


Function PopMenuProcDataDistanceGroup(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			//Edit :Distance:$popStr
			
			String strROIpair=popStr+"_ROIs"
			
			String strTitle="Distance: "+popStr
			
			Edit/K=1 :Distance:$strROIpair,:Distance:$popStr as strTitle
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProcDataPearsonGroup(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			//Edit :Pearson:$popStr
			
			String strROIpair=popStr+"_ROIs"
			
			String strTitle="Pearson: "+popStr
			
			Edit/K=1 :Pearson:$strROIpair,:Pearson:$popStr as strTitle
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroFindLargestNumPnts(dfr,listW)
	
	DFREF dfr
	String listW
	
	String nameW
	Variable nThis,nVert
	Variable i
	for(i=0;i<ItemsInList(listW);i+=1)
		nameW=StringFromList(i,listW)
		WAVE w=dfr:$nameW
		nThis=numpnts(w)
		if (nThis>nVert)
			nVert=nThis
		endif
	endfor
	
	return nVert
	
End


Function hiroPlotMeanDynamicInit(dfr,listW)
	
	DFREF dfr		// DF that contains vectorized data of each group
	String listW
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	Variable n=ItemsInList(listW)
	
	NewDataFolder/S dfr:graph
	
	Make/N=(n) wAvg,wStem,wXloc=x
	Make/T/N=(n) labels
	
	String/G yLabel
	
	String nameDF=GetDataFolder(0,dfr)
	nameDF=ReplaceString("'",nameDF,"")		// remove single quotes
	
	yLabel=nameDF
	
	String nameGraph="GraphMean"+nameDF
	
	Display/K=1/N=$nameGraph wAvg as nameDF
	
	ResizeWindow(350,162)
	
	ErrorBars wAvg Y,wave=(wStem,wStem)
	
	Label left yLabel
	
	ModifyGraph mode=3,marker=19,lowTrip(left)=0.01
	ModifyGraph zero(left)=3
	
	Make wVertHolder	// default is 128 points but it will be resized in hiroPlotMeanDynamic()
	
	// make a label on x-axis
	WAVE/T labels
	String nameW
	Variable i
	for(i=0;i<n;i+=1)
		nameW=StringFromList(i,listW)
		labels[i]=nameW
		
		// Append datapoints
		AppendToGraph dfr:$nameW vs wVertHolder
		ModifyGraph mode=3,marker($nameW)=1,offset($nameW)={i,0}
		ModifyGraph hideTrace($nameW)=1
	endfor
	
	ModifyGraph userticks(bottom)={wXloc,labels}
	
	// add controls
	ControlBar/T 20
	
	PopupMenu popupModeGroup title="Show"
	PopupMenu popupModeGroup value="Mean ± SEM;Data points"
	PopupMenu popupModeGroup pos={1,0}
	
	String quote = "\""
	String list=quote+listW+quote		// menu items must be modified with escape quotes and # (weird)
	
	PopupMenu popupDataGroup title="Data >",pos={220,0},mode=0
	Button buttonShowAllGroups title="Show All",pos={286,0}
	
	if (ItemsInList(listW)==10)
		PopupMenu popupDataGroup proc=PopMenuProcDataDistanceGroup
		PopupMenu popupModeGroup proc=PopMenuProcModeDistanceGroup
		Button buttonShowAllGroups proc=ButtonProcAllDistanceGroups
	else
		PopupMenu popupDataGroup proc=PopMenuProcDataPearsonGroup
		PopupMenu popupModeGroup proc=PopMenuProcModePearsonGroup
		Button buttonShowAllGroups proc=ButtonProcAllPearsonGroups
	endif
	PopupMenu popupDataGroup value=#list
	
	SetDataFolder dfrSaved
	
End


Function ButtonProcAllDistanceGroups(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroTabulateDataInAllGroups(0)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcAllPearsonGroups(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroTabulateDataInAllGroups(1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProcModeDistanceGroup(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			switch(popNum)
				case 1:	// Mean ± SEM
					ModifyGraph hideTrace(wAvg)=0
					ModifyGraph hideTrace(SS)=1,hideTrace(SL)=1,hideTrace(SM)=1,hideTrace(SH)=1
					ModifyGraph hideTrace(LL)=1,hideTrace(LM)=1,hideTrace(LH)=1,hideTrace(MM)=1
					ModifyGraph hideTrace(MH)=1,hideTrace(HH)=1
					break
				case 2:	// Data points
					ModifyGraph hideTrace(wAvg)=1
					ModifyGraph hideTrace(SS)=0,hideTrace(SL)=0,hideTrace(SM)=0,hideTrace(SH)=0
					ModifyGraph hideTrace(LL)=0,hideTrace(LM)=0,hideTrace(LH)=0,hideTrace(MM)=0
					ModifyGraph hideTrace(MH)=0,hideTrace(HH)=0
					break
				default:
			endswitch
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProcModePearsonGroup(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			switch(popNum)
				case 1:	// Mean ± SEM
					ModifyGraph hideTrace(wAvg)=0
					ModifyGraph hideTrace(LL)=1,hideTrace(LM)=1,hideTrace(LH)=1,hideTrace(MM)=1
					ModifyGraph hideTrace(MH)=1,hideTrace(HH)=1
					break
				case 2:	// Data points
					ModifyGraph hideTrace(wAvg)=1
					ModifyGraph hideTrace(LL)=0,hideTrace(LM)=0,hideTrace(LH)=0,hideTrace(MM)=0
					ModifyGraph hideTrace(MH)=0,hideTrace(HH)=0
					break
				default:
			endswitch
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroShowColorCorrelationMap()
	
	WAVE M_Pearson
	WAVE M_Pearson_full=hiroMirrorMatrix(M_Pearson)
	
	DoWindow GraphColorCorr
	if (V_flag)
		KillWindow GraphColorCorr
	endif
	NewImage/N=GraphColorCorr M_Pearson_full
	
	DoWindow/T GraphColorCorr,"Pearson's r"
	
	ModifyImage M_Pearson_full ctab= {-1,1,Rainbow256,1}
	
	ResizeWindow(350,300)
	
	// default margin is 14 points.  add 50 to the right
	ModifyGraph/W=GraphColorCorr margin(right)=64
	
	ColorScale/C/N=text0/F=0/A=MC image=M_Pearson_full
	ColorScale/C/N=text0/X=61.50/Y=14.80
	ColorScale/C/N=text0/Z=1
	
	AutoPositionWindow/E
	
End


Function CheckProcShowSelectedROIs(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			ControlInfo/W=GraphStep3 setvarLowCutoff
			Variable f1=V_Value
			
			ControlInfo/W=GraphStep3 setvarHighCutoff
			Variable f2=V_Value
			
			if (checked)
				ModifyGraph/W=GraphROIs hideTrace(wSelA)=0,hideTrace(wSelB)=0
				ModifyGraph/W=GraphPearsonVsDistance hideTrace(wSelPearson)=0
			else
				ModifyGraph/W=GraphROIs hideTrace(wSelA)=1,hideTrace(wSelB)=1
				ModifyGraph/W=GraphPearsonVsDistance hideTrace(wSelPearson)=1
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProcShowAs(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			hiroShowAsPopMenu(popNum)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroShowAsPopMenu(popNum)
	
	Variable popNum
	
	// The graph may not exist the first time this is run. check
	DoWindow GraphROIPairs
	if (V_flag)
		
		WAVE wP=:Controls:wP_ROIPair
		
		switch(popNum)
			case 1:
				// histogram
				WAVE M=M_Peaks_bin
				ModifyGraph/W=GraphROIPairs mode=6
				ModifyGraph/W=GraphROIPairs offset(waveB)={0,kOffsetWaveBHistogram}
				SetAxis/W=GraphROIPairs/A left
				wP[1]=kOffsetWaveBHistogram
				break
			case 2:
				// raster
				WAVE M=M_Rasters
				ModifyGraph/W=GraphROIPairs mode=3,marker=10
				ModifyGraph/W=GraphROIPairs offset(waveB)={0,kOffsetWaveBRaster}
				SetAxis/W=GraphROIPairs left -0.15,0.05		// manually optimize y-axis
				wP[1]=kOffsetWaveBRaster
				break
			case 3:
				// trace
				WAVE M=M_smoothSel
				ModifyGraph/W=GraphROIPairs mode=0
				SetAxis/W=GraphROIPairs/A left
				// padding will be dynamically adjusted in hiroShowPeaksBetw()
				break
			default:
				WAVE M=M_Peaks_bin
				ModifyGraph/W=GraphROIPairs mode=6
				ModifyGraph/W=GraphROIPairs offset(waveB)={0,kOffsetWaveBHistogram}
				SetAxis/W=GraphROIPairs/A left
				wP[1]=kOffsetWaveBHistogram
		endswitch
	
	else
		// init
		WAVE M=M_Peaks_bin
	endif
		
	ControlInfo/W=GraphROIPairs listROIPairsPearson
	Variable selRow=V_Value
	WAVE M_Pearson_pairs
	Variable roiA=M_Pearson_pairs[selRow][0]-1		// zero-based
	Variable roiB=M_Pearson_pairs[selRow][1]-1
	
	hiroShowPeaksBetw(roiA,roiB,M)
	
End


Function ButtonProcPearson(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE M_Pearson
			//Edit/K=1 M_Pearson
			Edit/K=1 M_Pearson.ld
			
			//DoUpdate
			//DoAlert/T="In this table..." 0,"The ROIs are zero-based.\r\rThis means column 1 refers to ROI #2."
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcDistance(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE M_ROI_Distances
			//Edit/K=1 M_ROI_Distances
			String str
			Variable i
			for(i=0;i<DimSize(M_ROI_Distances,0);i+=1)
				str="ROI"+num2str(i+1)
				SetDimLabel 0,i,$str,M_ROI_Distances
				SetDimLabel 1,i,$str,M_ROI_Distances
			endfor
			Edit/K=1 M_ROI_Distances.ld
			
			//DoUpdate
			//DoAlert/T="In this table..." 0,"The ROIs are zero-based.\r\rThis means column 1 refers to ROI #2."
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcPearsonVsDistance(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE M_Pearson_pairs
			Edit/K=1 M_Pearson_pairs.ld
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroShowPearsonVsDistance()
	
	DoWindow/F GraphROIPairs
	ControlInfo/W=GraphROIPairs listROIPairsPearson
	Variable selRow=V_Value
	if (selRow<0)
		selRow=0
	endif
	
	DoWindow GraphPearsonVsDistance
	if (V_flag)
		KillWindow GraphPearsonVsDistance
	endif
	Display/K=2/N=GraphPearsonVsDistance as "Pearson's r vs Distance"
	
	ResizeWindow(400,300)
	
	AutoPositionWindow/E
	
	WAVE M=M_Pearson_pairs
	
	AppendToGraph/W=GraphPearsonVsDistance M[][%rho] vs M[][%distance]
	ModifyGraph mode=2,lsize=2,rgb=(34952,34952,34952)
	
	Label left "Pearson's correlation coefficient"
	NVAR/Z imageScaleFactor=:map:imageScaleFactor
	if (NVAR_Exists(imageScaleFactor))
		Label bottom "Distance (µm)"
	else
		Label bottom "Distance (pixels)"
	endif
	
	Make/O/N=1 wSelPearson=M[selRow][%rho]
	Make/O/N=1 wSelDistance=M[selRow][%distance]
	
	AppendToGraph/W=GraphPearsonVsDistance wSelPearson vs wSelDistance
	ModifyGraph mode(wSelPearson)=3,marker(wSelPearson)=8
	
	// Add controls
	ControlBar/T 20
	
	CheckBox checkShowSelectedROIs title="Show selected",value=1,proc=CheckProcShowSelectedROIs
	
	Button buttonDistance title="Distance",pos={240,0},proc=ButtonProcDistance
	Button buttonDistance size={75,20}
	
	Button buttonPearsonVsDistance title="Pair stats",pos={320,0},proc=ButtonProcPearsonVsDistance
	Button buttonPearsonVsDistance size={75,20}
	
End


Function hiroNewEmptyROIMarkersAB()
	
	if (DataFolderExists(":map"))
		DFREF dfrSaved=GetDataFolderDFR()
		
		SetDataFolder :map
		WAVE/Z w=wSelA
		if (!WaveExists(w))
			Make/D/O/N=1 wSelA,wSelAX,wSelB,wSelBX
			AppendToGraph/W=GraphROIs wSelA vs wSelAX
			AppendToGraph/W=GraphROIs wSelB vs wSelBX
			
			ModifyGraph/W=GraphROIs hideTrace(wSelA)=1,hideTrace(wSelB)=1
			ModifyGraph/W=GraphROIs mode=3,marker(wSelA)=8,marker(wSelB)=8
		endif
		SetDataFolder dfrSaved
	endif
	
End


Function ListBoxProcROIPairsPearson(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
			
			// Read ROI numbers
			Variable roiA,roiB
			WAVE M=M_Peaks_bin
			
			roiA=str2num(listWave[row][0])-1	// zero-based
			roiB=str2num(listWave[row][1])-1
			
			// Update graph
			//hiroShowPeaksBetw(roiA,roiB,M)
			ControlInfo/W=GraphROIPairs popupShowAs
			hiroShowAsPopMenu(V_Value)
			
			// Optionally update ROI map
			hiroUpdateROISelect(roiA,roiB)
			
			// Optionally update selection in Pearson vs Distance graph
			hiroUpdatePearsonVsDistance(row)
			
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End


Function hiroUpdatePearsonVsDistance(row)
	
	Variable row	// zero-based
	
	DoWindow GraphPearsonVsDistance
	if (V_flag)
		WAVE M=M_Pearson_pairs
		WAVE wSelPearson
		WAVE wSelDistance
		wSelPearson=M[row][%rho]
		wSelDistance=M[row][%distance]
	endif
	
End


Function SetVarProcBinSize(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// auto update
			hiroAutoPearsons(dval)
			WAVE M_Pearson
			hiroMirrorMatrix(M_Pearson)
			
			// Reassign freq group according to the new Pearson values
			hiroUpdateGroupsByFreqCode(M_Pearson,"Pearson")
			
			hiroUpdateMeanPlot()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroAutoPearsons(msBin)
	
	Variable msBin
	
	// Bin size is expressed in terms of number of datapoints.  Convert from ms to datapoints (round to an integer)
	WAVE M_Peaks
	Variable delta=deltax(M_Peaks)
	Variable bin=round(0.001*msBin/delta)	// this is an integer
	
	if (bin)
		// Create a histogram version of M_Peaks
		hiroHistBinnedMT(bin)		// outputs M_Peaks_bin
	else
		// don't make the histogram. M_Peaks will be analyzed directly
		//Duplicate/O M,M_Peaks_bin
		Duplicate/O/R=[*][*][3] M_Peaks,M_Peaks_bin
	endif
	
	WAVE M=M_Peaks_bin
	
	//Variable t=tic()
	//hiroPearsonr(M)	// outputs M_Pearson
	hiroPearsonrMultiThread(M)	// 1.35 x faster with 222 ROIs. 2008 MBP 6GB SSD
	//toc(t)
	
	WAVE M_Pearson
	String str
	Variable i
	for(i=0;i<DimSize(M_Pearson,0);i+=1)
		str="ROI"+num2str(i+1)
		SetDimLabel 0,i,$str,M_Pearson
		SetDimLabel 1,i,$str,M_Pearson
	endfor
	
	//Edit/K=1 M_Pearson
	
	// Rank the ROI pairs in the order of Pearson's correlation coeffient
	hiroListROIPairsPostPearsons(M_Pearson)
	//WAVE/T M_Pearson_pairs_t
	WAVE M_Pearson_pairs
	
	Variable roiA,roiB
	
	//WAVE/T wT=:Controls:wT_ROIPair
	
	// Read row number of currently selected ListBox
	ControlInfo/W=GraphROIPairs listROIPairsPearson
	Variable selRow=V_Value
	if (selRow==-1)
		selRow=0	// force to be the first
	endif
	
	//wT[0]=M_Pearson_pairs_t[selRow][0]	// 1-based (=ROI number)
	//wT[1]=M_Pearson_pairs_t[selRow][1]
	
	//roiA=str2num(wT[0])-1		// zero-based
	//roiB=str2num(wT[1])-1
	
	roiA=M_Pearson_pairs[selRow][0]-1		// zero-based
	roiB=M_Pearson_pairs[selRow][1]-1
	
	// Update graph
	//hiroShowPeaksBetw(roiA,roiB,M)	// outputs waveA, waveB
	ControlInfo/W=GraphROIPairs popupShowAs
	hiroShowAsPopMenu(V_Value)
	
	// Optionally update ROI map
	hiroUpdateROISelect(roiA,roiB)
	
	// Optionally update selected Pearson vs Distance Graph
	hiroUpdatePearsonVsDistance(selRow)
	
End


Function hiroUpdateROISelect(roiA,roiB)
	// update ROI map with markers A and B
	
	Variable roiA	// zero-based
	Variable roiB
	
	if (DataFolderExists(":map"))
		DFREF dfrSaved=GetDataFolderDFR()
		
		SetDataFolder :map
		WAVE wOrig
		WAVE wOrigX
		Duplicate/O/R=[roiA] wOrig,wSelA
		Duplicate/O/R=[roiA] wOrigX,wSelAX
		Duplicate/O/R=[roiB] wOrig,wSelB
		Duplicate/O/R=[roiB] wOrigX,wSelBX
		
		SetDataFolder dfrSaved
		
		// Show or hide depending on the user control
		ModifyGraph/W=GraphROIs hideTrace(wSelA)=0,hideTrace(wSelB)=0
	endif
	
End


Function hiroHistBinnedMT(bin)
	// Version 2 of hiroHistBinned() (slightly faster).  Requires splitColumn() and hiroHist()
	// Because peak location is in high temporal resolution, a peak that is delayed by a datapoint in one ROI relative
	// will give meaningless information with this analysis.  Thus, convert raster into a histogram with user-
	// defined bin size.  This is multithreaded to support a dynamic UI.
	
	// Multithreaded histogram (modeled after HiroCluster test5a)
	// Supports dynamic bin size
	// works on current DF
	
	Variable bin	// bin size expressed in number of datapoints; must be an integer greater than zero
	
	WAVE M_Peaks
	
	Variable npnts=DimSize(M_Peaks,0)
	Variable nROIs=DimSize(M_Peaks,1)
	
	Variable delta=deltax(M_Peaks)
	Variable sStart=leftx(M_Peaks)
	
	// M_Peaks is 3D.  Reduce to 2D matrix
	Duplicate/FREE/R=[*][*][3] M_Peaks,M2D
	
	Make/FREE/WAVE/N=(nROIs) wref
	
	DFREF dfrFree=NewFreeDataFolder()	// this DF gets killed automatically after use
	
	Make/T/FREE/N=(nROIs) wList="wFree"+num2str(x)
	
	//MultiThread wref=splitColumn(M2D,dfrFree,wList[p],p)	// works with 2D matrix
	
	// basic for-loop is better until the known issue in the multithread above is solved
	Variable i
	for (i=0;i<nROIs;i+=1)
		Duplicate/R=[][i] M2D, dfrFree:$wList[i] /WAVE=w
		wref[i]=w
	endfor
	
	// Wave ref waves to temporarily hold the results of histogram
	Make/FREE/WAVE/N=(nROIs) theResult
	
	MultiThread theResult=hiroHist(wref[p],npnts,sStart,bin)
	
	WAVE oneResult=theResult[0]

	Make/O/N=(numpnts(oneResult),nROIs) M_Peaks_bin
	
	Make/FREE/N=(nROIs) dummy
	
	MultiThread dummy=setColumn(M_Peaks_bin,theResult[p],p)
	
	SetScale/P x sStart,delta*bin,"s",M_Peaks_bin
	
End


Function hiroHistBinned(bin)
	// Because peak location is in high temporal resolution, a peak that is delayed by a datapoint in one ROI relative
	// will give meaningless information with this analysis.  Thus, convert raster into a histogram with user-
	// defined bin size.  This is multithreaded to support a dynamic UI.
	
	// Multithreaded histogram (modeled after HiroCluster test5a)
	// Supports dynamic bin size
	// works on current DF
	
	Variable bin	// bin size expressed in number of datapoints; must be an integer greater than zero
	
	WAVE M_Peaks
	Variable delta=deltax(M_Peaks)
	Variable npnts=DimSize(M_Peaks,0)
	Variable nROIs=DimSize(M_Peaks,1)
	
	// Just get the relevant layer of the M_Peaks
//	MatrixOp/O M=M_Peaks[][][3]		// M is now 2D
	
	// Make a physical copy of the rasters as each wave--seems dumb but it works
	NewDataFolder/O :rasters
	String nameW
	Variable i
	for(i=0;i<nROIs;i+=1)
		nameW="wPeak"+num2str(i)
		Duplicate/O/R=[][i][3] M_Peaks,:rasters:$nameW
	endfor
	
	// Assign each raster into a wave reference.
	//Make/FREE/WAVE/N=(nROIs) wref
	
	// This method compiles, but fills every column with the last ROI (because w is refreshed with each iteration)
//	Make/FREE/N=(DimSize(M_Peaks,0)) w
//	
//	// wref=M_Peaks[][p][3] doesn't work.  Loop.
//	Variable i
//	for(i=0;i<nROIs;i+=1)
//		// wref[i]=M_Peaks[p][i][3] doesn't work. Assign it to a dummy wave w first (weird)
//		w=M_Peaks[p][i][3]
//		wref[i]=w[p][i]
//	endfor
//	
//	Variable sStart=leftx(w)
	
	Variable sStart=leftx(M_Peaks)
	
	// List of wPeak as a text wave
	Make/FREE/T/N=(nROIs) wList=":rasters:wPeak"+num2str(x)
	
	// Wave ref waves to temporarily hold the results of histogram
	Make/FREE/WAVE/N=(nROIs) wref=$wList[p]
	
	// Wave ref waves to temporarily hold the results of histogram
	Make/FREE/WAVE/N=(nROIs) theResult
	
	MultiThread theResult=hiroHist(wref[p],npnts,sStart,bin)
	
	WAVE oneResult=theResult[0]
	
	Make/O/N=(numpnts(oneResult),numpnts(theResult)) M_Peaks_bin
	
	Make/FREE/N=(numpnts(theResult)) dummy
	
	MultiThread dummy=setColumn(M_Peaks_bin,theResult[p],p)
	
	SetScale/P x sStart,delta*bin,"s",M_Peaks_bin
	
	KillDataFolder :rasters
	
End


//Function hiroBin(bin)
//	
//	Variable bin
//	
//	WAVE w=waveA
//	
//	Variable sStart=leftx(w)
//	
//	Extract/INDX w,wINDX,w==1
//	WAVE ts=wINDX
//	
//	Variable n=ceil(numpnts(w)/bin)
//	
//	Make/O/N=1 trial_Hist
//		
//	Histogram/B={sStart,bin,n}/C ts,trial_Hist
//	
//	//trial_Hist /= bin
//
//	SetScale/P x sStart,deltax(w)*bin,"", trial_Hist
//	
//End


ThreadSafe Function/WAVE hiroHist(w,npnts,sStart,bin)
	
	WAVE w				// gets a peak raster as a wave
	Variable npnts		// =numpnts(w)
	Variable sStart		// =leftx(w)
	Variable bin
	
	Extract/FREE/INDX w,wINDX,w==1		// gets tsTrial0, etc. as a wave
	
	Variable n=ceil(npnts/bin)
	
	if (numpnts(wINDX))
		
		Make/FREE/N=1 one_Hist
		
		Histogram/B={sStart,bin,n}/C wINDX,one_Hist
		
		//one_Hist /= bin
	
	else
		Make/FREE/N=(n) one_Hist
	endif
	
	return one_Hist
	
End


Function hiroPearsonr(M)
	
	WAVE M	// M_Peaks_bin (2D)
	Variable n=DimSize(M,1)
	
	Make/O/N=(n,n) M_Pearson
	WAVE M_Pearson
	
	//Variable t=tic()
	
	M_Pearson=NaN
	
	Variable i,j
	for (i=0;i<n;i+=1)
		//Duplicate/FREE/R=[][i][3] M,waveA
		Duplicate/FREE/R=[][i] M,waveA
		for (j=0;j<i;j+=1)
			//Duplicate/FREE/R=[][j][3] M,waveB
			Duplicate/FREE/R=[][j] M,waveB
			
			M_Pearson[j][i]=StatsCorrelation(waveA,waveB)
			//Print i,j,StatsCorrelation(waveA,waveB)
		endfor
	endfor
	
	//toc(t)
	
End


Function hiroPearsonrMultiThread(M)
	// Multi-threaded version of hiroPearsonr()
	// requires hiroPearsonrMT(), splitColumn() and setColumn()
	
	WAVE M	// M_Peaks_bin (2D)
	Variable n=DimSize(M,1)
	
	Make/O/N=(n,n) M_Pearson
	WAVE M_Pearson
	
	//M_Pearson=NaN
	
	//Variable t=tic()
	
//	Variable i,j
//	for (i=0;i<n;i+=1)
//		Duplicate/FREE/R=[][i][3] M,waveA
//		for (j=0;j<i;j+=1)
//			Duplicate/FREE/R=[][j][3] M,waveB
//			
//			M_Pearson[j][i]=StatsCorrelation(waveA,waveB)
//			//Print i,j,StatsCorrelation(waveA,waveB)
//		endfor
//	endfor
	
	// holds wave refs for every possible "waveA"
	Make/FREE/WAVE/N=(n) wref
	
	DFREF dfrFree=NewFreeDataFolder()	// this DF gets killed automatically after use
	
	Make/T/FREE/N=(n) wList="wFree"+num2str(x)
	//MultiThread wref=splitColumn(M,dfrFree,wList[p],p)	// designed to work with 2D matrix, faster, but the first wave is missing
	//wref=splitColumn(M,dfrFree,wList[p],p)	// The problem is solved if multi-thread is disabled; however, this is slightly slower compared to the for loop below
	
	// basic for-loop is better until errors in the multithread is solved
	Variable i
	for (i=0;i<n;i+=1)
		Duplicate/R=[][i] M, dfrFree:$wList[i] /WAVE=w
		wref[i]=w
	endfor
	
	//toc(t)
	
	// Wave ref waves to temporarily hold the results of Pearson per column
	Make/FREE/WAVE/N=(n) theResult
	
	MultiThread theResult=hiroPearsonrMT(wref[p],dfrFree,n,p)
	
	Make/FREE/N=(n) dummy
	
	MultiThread dummy=setColumn(M_Pearson,theResult[p],p)
	
End


ThreadSafe Function/WAVE hiroPearsonrMT(waveA,dfr,n,i)
	
	WAVE waveA
	DFREF dfr
	Variable n		// =numpnts(waveA)
	Variable i
	
	Make/FREE/N=(n) oneResult	// a column of M_Pearson
	oneResult=NaN
	
	String nameW
	Variable j
	for(j=0;j<i;j+=1)
		nameW="wFree"+num2str(j)
		WAVE waveB=dfr:$nameW
		
		oneResult[j]=StatsCorrelation(waveA,waveB)
	endfor
	
	return oneResult
	
End


Function/WAVE hiroMirrorMatrix(Mat)
	// input triangle matrix: add identity matrix and transposed
	// this method is up to 50 times faster than to filling each row and column using for-loops
	// however, MatrixOp cannot work with a matrix with NaNs in it.
	// thus this function will extract and refill NaN at the beginning and end
	
	WAVE Mat
	
	String nameW=NameOfWave(Mat)+"_full"
	
	//Variable t=tic()
	
	Variable n=DimSize(Mat,0)
	if (n!=DimSize(Mat,1))
		// not square matrix
		Print "not a square matrix"
		Abort
	endif
	
	// find a non-used integer as the temporary placeholder for NaNs
	Variable maxValue=ceil(WaveMax(Mat))+1
	//print maxValue
	
	// Fill in NaN as a number (otherwise matrix addition won't work)
	MatrixOp/FREE M_Filled=ReplaceNaNs(Mat,maxValue)
	
	// Duplicate this and transpose to get the other half
	Duplicate/FREE M_Filled,M_Filled2
	//MatrixTranspose M_Filled2
	
	// M_Filled2^t is faster than MatrixTranspose
	MatrixOp/FREE M_Sum=M_Filled+Identity(n)+M_Filled2^t
	
	// Reduce all values by maxValue
	M_Sum-=maxValue
	
	// Refill NaNs
	MatrixOp/FREE M_NaN=Replace(M_Sum,maxValue,NaN)
	
	// Identity should be 1
	MatrixOp/O $nameW=Replace(M_NaN,maxValue+1,1)
	
	return $nameW
	
	//toc(t)
	
End


Function hiroPearsonMatrixWOSilent()
	// Make a full matrix of M_Pearson without the silent cells
	
	// load half matrix
	WAVE M_Pearson
	
	Variable nIncluded,nSilent,n
	
	WAVE wIncluded=:map:wIncluded
	WAVE wSilent=:map:wSilent
	
	// get the number of included and silent cells
	nIncluded=numpnts(wIncluded)
	nSilent=numpnts(wSilent)
	n=nIncluded-nSilent	// the number of rows and columns in the new matrix
	
	// remove silent cells (the result will be a 1D vector)
	Extract/FREE M_Pearson,M_PearsonFree,numtype(M_Pearson)==0
	
	// make a new matrix
	Make/O/N=(n,n) M_Pearson_noSilent
	
	WAVE M_Pearson_noSilent
	M_Pearson_noSilent=NaN
	
	// convert 1D matrix into half matrix
	Variable i,j,k
	for(j=1;j<n;j+=1)
		for(k=0;k<j;k+=1)
			M_Pearson_noSilent[k][j]=M_PearsonFree[i]
			i+=1
		endfor
	endfor
	
	// full matrix with identity matrix
	WAVE M=hiroMirrorMatrix(M_Pearson_noSilent)
	
	// save original full matrix as backup
	WAVE/Z M_Pearson_Orig_full
	if (!WaveExists(M_Pearson_Orig_full))
		WAVE M_Pearson_full
		Duplicate/O M_Pearson_full,M_Pearson_Orig_full
	endif
	
	// replace full matrix with the new
	Duplicate/O M,M_Pearson_full
	
	// Adjust range on the graph
	ModifyImage/W=GraphColorCorr M_Pearson_full ctab= {*,*,Rainbow256,1}
	
	// hide axes since the ticks does not match ROI number anymore
	DoWindow/F GraphColorCorr
	WipeAllAxes()
	
End


//Function testRowColFromSort()
//	// what is the row number and column number of a matrix after it was sorted?
//	// a demo
//	
//	// the dimension size is essential: here the row is 32 and column is 4
//	Make/O/N=(32,4) M
//	
//	WAVE M
//	M=gnoise(2)
//	
//	// Inject NaN here and there-this simulates the dataset to be analyzed
//	M[12][1]=NaN
//	M[4][2]=NaN
//	
//	// Important to vectorize here: if you perform Extract on a Matrix with NaNs in it,
//	// it'll erroneously insert zeros in place of it
//	Duplicate/O M,w1D
//	Redimension/N=(32*4) w1D
//	
//	// get a set of data comprising only of normal numbers (because NaN messes up the sorting)
//	Extract w1D,w,numtype(w1D)==0
//	Extract/INDX w1D,wINDX,numtype(w1D)==0
//	
//	WAVE w
//	WAVE wINDX
//	
//	// Sort from large to small
//	Sort/R w,w,wINDX
//	
//	// What row and column did the largest number come from?
//	Variable col=floor(wINDX[0]/32)	// this is the column number
//	Variable row=wINDX[0]-32*col	// this is the row number
//	
//	Print "largest (row,col):",row,col
//	
//End


Function hiroListROIPairsPostPearsons(M)
	// sorts a 2D matrix containing NaNs and lists pairs of row and column in the order of higher coefficient values
	
	WAVE M	// e.g., M_Pearsons
	
	Variable nRows=DimSize(M,0)
	Variable nCols=DimSize(M,1)
	
	// Important to vectorize here: if you perform Extract on a Matrix with NaNs in it,
	// it'll erroneously insert zeros in place of it
	Duplicate/FREE M,w1D
	Redimension/N=(nRows*nCols) w1D
	
	// get a set of data comprising only of normal numbers (because NaN messes up the sorting)
	Extract/FREE w1D,w,numtype(w1D)==0
	Extract/FREE/INDX w1D,wINDX,numtype(w1D)==0
	
	// Sort from large to small
	Sort/R w,w,wINDX
	
	// Make a list of row-column pairs in the order it was sorted
	Variable nPairs=numpnts(wINDX)
	Make/O/N=(nPairs,4) M_Pearson_pairs
	WAVE M_Pearson_pairs
	SetDimLabel 1,0,ROI_A,M_Pearson_pairs
	SetDimLabel 1,1,ROI_B,M_Pearson_pairs
	SetDimLabel 1,2,rho,M_Pearson_pairs
	SetDimLabel 1,3,distance,M_Pearson_pairs
	
	// Optionally fill in ROI distance between the pairs
	Variable doDistance
	if (DataFolderExists(":map"))
		WAVE M_ROI_Distances
		doDistance=1
	endif
	
	Variable row, col
	Variable i
	for(i=0;i<numpnts(wINDX);i+=1)
		// What row and column did the largest number come from?
		col=floor(wINDX[i]/nRows)	// this is the column number
		row=wINDX[i]-nRows*col	// this is the row number
		
		//Print row,col,M[row][col]
		M_Pearson_pairs[i][0]=row+1		// make 1-based (=ROI number)
		M_Pearson_pairs[i][1]=col+1
		M_Pearson_pairs[i][2]=M[row][col]
		if (doDistance)
			M_Pearson_pairs[i][3]=M_ROI_Distances[row][col]
		endif
	endfor
	
	// Make a text wave version for ListBox: convert from numeric wave to text
	Make/T/O/N=(nPairs,3) M_Pearson_pairs_t=num2str(M_Pearson_pairs)
	SetDimLabel 1,0,ROI_A,M_Pearson_pairs_t
	SetDimLabel 1,1,ROI_B,M_Pearson_pairs_t
	SetDimLabel 1,2,rho,M_Pearson_pairs_t
	
End


Function hiroCalculateROIDistances()
	// Calculates the ROI distances
	// if x, y coordinates of the ROIs exist
	
	if (DataFolderExists(":map"))
		
		WAVE wOrig=:map:wOrig
		WAVE wOrigX=:map:wOrigX
		Variable n=numpnts(wOrig)
		
		Make/O/N=(n,n) M_ROI_Distances
		WAVE M_ROI_Distances
		M_ROI_Distances=NaN
		
		Variable i,j
		for(i=0;i<n;i+=1)
			for(j=0;j<i;j+=1)
				M_ROI_Distances[j][i]=sqrt((wOrigX[i]-wOrigX[j])^2+(wOrig[i]-wOrig[j])^2)
			endfor
		endfor
		
//		NVAR imageScaleFactor=:map:imageScaleFactor
//		if (NVAR_Exists(imageScaleFactor))
//			// express in terms of µm
//			M_ROI_Distances/=imageScaleFactor
//		endif
	endif
	
End


Function hiroShowPeaksBetw(roiA,roiB,M)
	// Visualize rasters of two ROIs
	
	Variable roiA	// zero-based
	Variable roiB
	WAVE M
	
	Duplicate/O/R=[][roiA] M,waveA
	Duplicate/O/R=[][roiB] M,waveB
	
	// Update labels
	WAVE/T wT=:Controls:wT_ROIPair
	wT[0]=num2str(roiA+1)		// 1-based (=ROI number)
	wT[1]=num2str(roiB+1)
	
	ControlInfo/W=GraphROIPairs popupShowAs
	if (V_Value==3)
		// trace: dynamically adjust offset and custom label
		WAVE waveA
		WAVE waveB
		WAVE wP=:Controls:wP_ROIPair
		Variable minA=WaveMin(waveA)
		Variable maxA=WaveMax(waveB)
		Variable offset=abs(maxA)+abs(minA)
		wP[1]=-offset
		ModifyGraph/W=GraphROIPairs offset(waveB)={0,-offset}
	endif
	
End


//-- Randomize section
// 1. Duplicate DF
// 2. Reassign Freq ID to cells randomly
// 3. Shuffle existing rasters according to the new ID--keep the total number of spikes the same
// 4. Calculate Pearson and plot the results
Function hiroPreStep4Prompt()
	
	Variable x0,y0,width=300,height=150
	
	CenterObjScreen(x0,y0,width,height)
	
	NewPanel/K=2/N=PanelStep4/W=(x0,y0,x0+width,y0+height) as "Continue?"
	
	TitleBox titleWarning1 title="Click Continue to proceed with real data.\r\rYou may optionally randomize data first."
	TitleBox titleWarning1 frame=0,pos={5,20}
	
	TitleBox titleWarning2 title="If you randomize, however, the data will be permanently altered.\rYou cannot undo this."
	TitleBox titleWarning2 frame=0,pos={5,65}
	
	Variable topPos=125
	
	Button buttonStep4Real title="Continue",proc=ButtonProcStep4Real
	Button buttonStep4Real pos={10,topPos},size={75,20}
	
	Button buttonStep4Random title="Randomize",proc=ButtonProcStep4Random
	Button buttonStep4Random pos={110,topPos},size={100,20}
	
	Button buttonStep4Cancel title="Cancel",proc=ButtonProcStep4Cancel
	Button buttonStep4Cancel pos={235,topPos}
	
End


Function ButtonProcStep4Real(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			KillWindow PanelStep4
			
			hiroStep4()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcStep4Random(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			KillWindow PanelStep4
			
			hiroRandStep4()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcStep4Cancel(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			KillWindow PanelStep4
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroRandStep4()
	
	hiroRandDuplicateDF()
	hiroRandROIShuffle2()
	
	// Update GraphStep3 with the randomized rasters
	DoWindow GraphStep3
	if (!V_flag)
		Abort "The raster graph is missing.  Abort."
	endif
	
	Print "The raster data is randomized by the user."
	
	// Disable controls
	Button buttonFeatures win=GraphStep3, disable=2
	
	WAVE selROI
	Extract/FREE/INDX selROI,wINDX,selROI==1
	Variable n=numpnts(wINDX)
	
	WAVE/T figTicLabel=:Controls:figTicLabel
	//WAVE figTicValue=:Controls:figTicValue
	
	WAVE M_Rasters	// this raster is randomized
	
	String nameTrace
	Variable j,ii
	for(ii=0;ii<n;ii+=1)
		nameTrace="Raster_"+figTicLabel(ii)	// name is 1-based
		j=str2num(figTicLabel(ii))-1			// 0-based for point number
		ReplaceWave/W=GraphStep3 trace=$nameTrace,M_Rasters[][j]
	endfor
	
	// Recolorize rasters if needed
	ControlInfo/W=GraphStep3 checkColorizeROIs
	if (V_value)
		ControlInfo/W=GraphStep3 setvarLowCutoff
		Variable f1=V_value
		ControlInfo/W=GraphStep3 setvarHighCutoff
		Variable f2=V_value
		hiroColorizeRasters(f1,f2)
	endif
	
	// Remake ROI map
	DFREF dfr=:map
	KillWaves dfr:wSelA,dfr:wSelAX,dfr:wSelB,dfr:wSelBX
	hiroShowROIMap()		// redraw ROI map
	
	// Run step 4
	hiroStep4()
	
	// Disable controls
	PopupMenu popupShowAs win=GraphROIPairs, value="Histogram;Raster"
	
End


Function hiroRandDuplicateDF()
	// Duplicate existing DF and append "_rand" at the end.
	// Allow overwrite, but execute only when the focus is on the "real" DF
	
	String nameDF,nameDF2,strPath
	
	nameDF=ReplaceString("'",GetDataFolder(0),"")
	
	Variable len=strlen(nameDF)
	
	if (len+5>=31)
		nameDF2=nameDF
		nameDF2[26,31]=""
		nameDF2+="_rand"
	else
		nameDF2=nameDF+"_rand"		// doesn't work if the DF name is already maxed at 31 characters
	endif
	
	strPath="root:"+PossiblyQuoteName(nameDF2)
	
	if (DataFolderExists(strPath))
		KillDataFolder $strPath
	endif
	
	DuplicateDataFolder root:$nameDF,$strPath
	
	SetDataFolder $strPath
	
	String/G strParentDF="root:"+PossiblyQuoteName(nameDF)
	
	//SetDataFolder $strParentDF
	
End


//Function hiroRandROIShuffleBeta()
//	// vers 0 incomplete, obsolete
//	
//	WAVE M_Rasters
//	
//	Duplicate/FREE/R=[*][0] M_Rasters, wFree
//	
//	// init
//	M_Rasters=NaN
//	
//	NVAR nRegions
//	
//	Variable nRows=numpnts(wFree)
//	Variable numPeaks
//	
//	Variable i,k
//	for(i=0;i<nRegions;i+=1)
//		numPeaks=2	//? get this programmatically
//		for(k=0;k<numPeaks;k+=1)
//			M_Rasters[abs(floor(enoise(nRows,2)))][i]=0		// need a refractory period
//		endfor
//	endfor
//	
//	WAVE selROI
//	Extract/FREE/INDX selROI,wINDX,selROI==1
//	
//	Variable n=numpnts(wINDX)
//	
//	WAVE/T figTicLabel=:Controls:figTicLabel
//	
//	WAVE figTicValue=:Controls:figTicValue
//	
//	String nameTrace
//	Variable ii,j
//	for(ii=0;ii<n;ii+=1)
//		nameTrace="Raster_"+figTicLabel(ii)	// name is 1-based
//		j=str2num(figTicLabel(ii))-1			// 0-based for point number
//		RemoveFromGraph $nameTrace
//		AppendToGraph M_Rasters[][j]/TN=$nameTrace	// TN flag Requires Igor Pro 6.20
//		ModifyGraph offset($nameTrace)={0,figTicValue[ii]}
//	endfor
//	
//	ModifyGraph mode=3,marker=10
//	ModifyGraph mrkThick=0.25,rgb=(0,0,0)
//	
//End
//
//
//Function hiroRandROIShuffle(showGraph)
//	// Shuffles ROIs randomly--proof of principle, slow and incomplete (never used)
//	
//	Variable showGraph
//	
//	// get the index of just the selected ROIs
//	WAVE selROI
//	Extract/FREE/INDX selROI,wINDX,selROI==1
//	
//	Variable n=numpnts(wINDX)
//	
//	// Random generator
//	Make/FREE/N=(n) random=enoise(1)
//	
//	// Shuffle the index in the randomized order
//	Sort random, wINDX
//	
//	// Rasters will be reorganized row-wise according to the shuffled wINDX
//	// The excluded ROIs will remain untouched
//	WAVE M_Rasters
//	Duplicate/O M_Rasters, R_Rasters
//	WAVE R_Rasters
//	R_Rasters=NaN
//	
//	// Shuffle M_measurements as well
//	WAVE M_measurements
//	Duplicate/O M_measurements, R_measurements
//	WAVE R_measurements
//	
//	Variable nPnts=DimSize(M_Rasters,0)
//	
//	Variable i
//	for(i=0;i<n;i+=1)
//		Duplicate/FREE/R=[*][wINDX[i]] M_Rasters,wFree
//		
//		// Randomize peak locations (slow because it shuffles many points including NaNs)
//		Make/FREE/N=(nPnts) random2=enoise(1)
//		Sort random2, wFree
//		WAVEClear random2
//		
//		R_Rasters[][i]=wFree[p]
//		WAVEClear wFree
//		Duplicate/FREE/R=[wINDX[i]][*] M_measurements,wFree
//		R_measurements[i][]=wFree[q]
//		WAVEClear wFree
//	endfor
//	
//	WAVE/T figTicLabel=:Controls:figTicLabel
//	WAVE figTicValue=:Controls:figTicValue
//	
//	// Show graph
//	if (showGraph)
//		Display/K=1 as "Rasters on Randomized ROIs"
//		
//		String nameTrace
//		Variable j,ii
//		for(ii=0;ii<n;ii+=1)
//			nameTrace="Raster_"+figTicLabel(ii)	// name is 1-based
//			j=str2num(figTicLabel(ii))-1			// 0-based for point number
//			AppendToGraph R_Rasters[][j]/TN=$nameTrace	// TN flag Requires Igor Pro 6.20
//			ModifyGraph offset($nameTrace)={0,figTicValue[ii]}
//		endfor
//		
//		ModifyGraph mode=3,marker=10
//		ModifyGraph mrkThick=0.25,rgb=(0,0,0)
//		
//		//? Ugly
//		ModifyGraph userticks(left)={figTicValue,figTicLabel}
//		ModifyGraph tick(left)=3,fSize(left)=9
//		ModifyGraph noLabel(left)=2,axThick(left)=0
//		
//		ResizeWindow(600,350)
//		
//		ControlBar/T 20
//		ModifyGraph margin(top)=30
//	endif
//	
//End


Function hiroRandROIShuffle2()
	// Vers 2: a different method (faster)
	// should execute on the other DF
	
	// get the index of just the selected ROIs
	WAVE selROI
	Extract/FREE/INDX selROI,wINDX,selROI==1
	
	Variable n=numpnts(wINDX)
	
	// Make a copy of the wINDX before randomizing
	Duplicate/FREE wINDX,wINDXOrig
	
	// Random generator
	Make/FREE/N=(n) random=enoise(1)
	
	// Shuffle the index in the randomized order
	Sort random, wINDX
	
	// Rasters will be reorganized row-wise according to the shuffled wINDX
	// The excluded ROIs will remain untouched
	WAVE M_Rasters
	Duplicate/FREE M_Rasters, R_Rasters
	R_Rasters=NaN
	
	// Update M_Peaks (just the 4th dimension)
	WAVE M_Peaks
	M_Peaks=0
	
	// Shuffle M_measurements as well (Warning: M_measurements already lack excluded cells)
	WAVE M_measurements
	Duplicate/FREE M_measurements, R_measurements
	
	Variable nPnts=DimSize(M_Rasters,0)
	
	// Make a vector that will contain fake raster
	Duplicate/FREE/R=[*][0] M_Rasters,w1D
	
	// and the same for M_Peaks
	// raster and peaks have different precision so you must make a vector for each
	Duplicate/FREE/R=[*][0][3] M_Peaks,w1DPeaks
	
	Variable fs=1/deltax(w1D)
	ControlInfo/W=GraphStep2 setvarSetRefractoryPeriod
	Variable pntRefractPeriod=fs*V_Value
	Variable nPeaks
	
	// M_measurements already lack excluded cells.  M_Peaks and M_Rasters do not.
	// To keep track of the "matching" index, iSel will be used to convert wINDX into a corresponding
	// index in M_measurements
	Variable iSel
	Variable jROI		// 1-based ROI number
	Duplicate/FREE/R=[*][0] M_measurements,wROI_selected
	
	Variable i,k,flag
	for(i=0;i<n;i+=1)
		//Duplicate/FREE/R=[wINDX[i]][*] M_measurements,wFree
		//? This is a bug: M_measurements can't use wINDX
		
			// Solution: Find the corresponding index for M_measurements
			// To do this, read the ROI number on the M_measurements and get the index for that.
			jROI=wINDX[i]+1
			
			FindValue/V=(jROI) wROI_selected		// V_value stores index for the ROI number in M_measurements
			iSel=V_value
			if (iSel==-1)
				// no match found
				DoAlert/T="Error" 0, "Error during shuffling: randomization failed\r\rThe program cannot continue"
				Print  "Error during shuffling: randomization failed"
				Abort
			endif
		
		Duplicate/FREE/R=[iSel][*] M_measurements,wFree		// This fixes the bug above
		
		nPeaks=wFree[1]
		
		// init
		w1D=NaN
		w1DPeaks=0
		
		// Randomize peak locations
		do
			flag=0
			Make/FREE/N=(nPeaks) wINDX2=abs(floor(enoise(nPnts-1)))
			
			// Sort the indeces in ascending order
			Sort wINDX2,wINDX2
			
			// Check refractory period (as number of points)
			if (nPeaks>1)
				for(k=0;k<nPeaks-1;k+=1)
					// calculate the difference between two neighboring peaks
					if (wINDX2[k+1]-wINDX2[k]<pntRefractPeriod)
						flag=1	// two peaks are too close together. Redo randomization.
					endif
				endfor
				if (flag==0)
					break
				endif
			else
				break
			endif
		while(1)
		
		for(k=0;k<nPeaks;k+=1)
			w1D[wINDX2[k]]=0
			w1DPeaks[wINDX2[k]]=1
		endfor
		
		// Update IPIs
		Make/FREE/N=(nPeaks-1) wIPI
		for(k=0;k<nPeaks-1;k+=1)
			wIPI[k]=wINDX2[k+1]-wINDX2[k]
		endfor
		
		if (nPeaks>1)
			wFree[][2]=mean(wIPI)				// points betw peaks avg
			wFree[][3]=sqrt(Variance(wIPI))		// points betw peaks sd
			wFree[][5]=wFree[0][2]/fs			// IPI avg (s)
			wFree[][6]=wFree[0][3]/fs			// IPI sd (s)
		endif
		WAVEClear wIPI
		WAVEClear wINDX2
		
		R_measurements[i][]=wFree[q]
		R_Rasters[][wINDXOrig[i]]=w1D[p]	// wINDXOrig will save only in the included ROIs
		M_Peaks[][wINDXOrig[i]][3]=w1DPeaks[p]
		
		WAVEClear wFree
	endfor
	
	// Overwrite the selected ROI number in ascending order
	R_measurements[][0]=M_measurements[p][0]
	
	// Overwrite the M_measurements and M_Rasters with the new data
	Duplicate/O R_measurements,M_measurements
	Duplicate/O R_Rasters,M_Rasters
	
End
//-- End Randomize section


//Function patchTimeMachineStep4to3()
//	
//	// works for HiroImaging 0.55 only (specially coded for Isa on a one off basis)
//	
//	// Kill Windows
//	DoWindow GraphPearsonVsDistance
//	if (V_flag)
//		KillWindow GraphPearsonVsDistance
//	endif
//	
//	DoWindow GraphROIPairs
//	if (V_flag)
//		KillWindow GraphROIPairs
//	endif
//	
//	DoWindow GraphROIs
//	if (V_flag)
//		KillWindow GraphROIs
//	endif
//	
//	// Make sure all tables are killed
//	String listTables=WinList("*",";","WIN:2")
//	Variable i
//	for (i=0;i<ItemsInList(listTables);i+=1)
//		KillWindow $StringFromList(i,listTables,";")
//	endfor
//	
//	// Delete waves and DFs
//	WAVE/Z M_Peaks_bin
//	if (WaveExists(M_Peaks_bin))
//		KillWaves M_Peaks_bin
//	endif
//	
//	WAVE/Z M_Pearson
//	if (WaveExists(M_Pearson))
//		KillWaves M_Pearson
//	endif
//	
//	WAVE/Z M_Pearson_pairs
//	if (WaveExists(M_Pearson_pairs))
//		KillWaves M_Pearson_pairs
//	endif
//	
//	WAVE/Z M_Pearson_pairs_t
//	if (WaveExists(M_Pearson_pairs_t))
//		KillWaves M_Pearson_pairs_t
//	endif
//	
//	WAVE/Z M_ROI_Distances
//	if (WaveExists(M_ROI_Distances))
//		KillWaves M_ROI_Distances
//	endif
//	
//	WAVE/Z waveA
//	if (WaveExists(waveA))
//		KillWaves waveA
//	endif
//	
//	WAVE/Z waveB
//	if (WaveExists(waveB))
//		KillWaves waveB
//	endif
//	
//	WAVE/Z wSelDistance
//	if (WaveExists(wSelDistance))
//		KillWaves wSelDistance
//	endif
//	
//	WAVE/Z wSelPearson
//	if (WaveExists(wSelPearson))
//		KillWaves wSelPearson
//	endif
//	
//	WAVE/Z w=:Controls:wP_ROIPair
//	if (WaveExists(w))
//		KillWaves w
//	endif
//	
//	WAVE/Z w=:Controls:wT_ROIPair
//	if (WaveExists(w))
//		KillWaves w
//	endif
//	
//	if (DataFolderExists(":map"))
//		KillDataFolder :map
//	endif
//	
//	hiroNewEmptyROIMap()
//	Button buttonLoadROIs title="Load ROI positions",size={150,20},pos={100,165}	// button location conforms to 350x350 window
//	Button buttonLoadROIs proc=ButtonProcLoadROIs
//	
//	DoWindow/F GraphStep3
//	
//	// Add a button to go to Step 4
//	ModifyGraph margin(top)=30
//	Button buttonToStep4 title="Step 4: Pearson's >>",pos={400,20},size={200,20}
//	Button buttonToStep4 proc=ButtonProcToStep4,fColor=(0,0,65535)
//	Button buttonToStep4 valueColor=(65535,65535,65535)
//	Button buttonToStep4 help={"Click to do Pearson's"}
//	
//	Button buttonToStep4 disable=0
//	
//	// Resize GraphStep3
//	ResizeWindow(600,350)
//	
//	// Rearrange buttons on GraphStep3
//	PopupMenu popupColorLow pos={131-5,0}	// oddly the position gets shifted to the right by about 5 (when bodyWidth is 45); subtract 5 to correct
//	PopupMenu popupColorMedium pos={260-5,0}
//	PopupMenu popupColorHigh pos={383-5,0}
//	
//	// New color
//	PopupMenu popupColorLow popColor=(1,16019,65535)
//	PopupMenu popupColorMedium popColor=(65535,54607,32768)
//	
//	PopupMenu popupColorLow bodyWidth=45
//	PopupMenu popupColorMedium bodyWidth=45
//	PopupMenu popupColorHigh bodyWidth=45
//	
//	SetVariable setvarLowCutoff size={45,15},pos={195,2}
//	SetVariable setvarHighCutoff size={45,15},pos={323,2}
//	
//	TitleBox title0 pos={182,2}
//	TitleBox title1 pos={242,2}
//	TitleBox title2 pos={311,2}
//	TitleBox title3 pos={367,2}
//	
//	// Add new controls for the silent cells
//	PopupMenu popupColorSilent bodyWidth=45,proc=PopMenuProcColorChanged
//	PopupMenu popupColorSilent popColor=(0,0,0),value="*COLORPOP*"
//	PopupMenu popupColorSilent pos={50-5,0}
//	
//	TitleBox title4 title="= 0 <",frame=0,pos={100,2}
//	
//	ControlInfo checkColorizeROIs
//	if (!V_value)
//		PopupMenu popupColorSilent disable=1
//		TitleBox title4 disable=1
//	endif
//	
//	CheckBox checkThickRasters title="Thick",pos={1,20},proc=CheckProcThickRasters
//	
//End


//Function hiroSpeedTestOnSplitMatrix()
//	
//	// Duplicate vs ImageTransform vs MatrixOp to extract a column out of matrix
//	
//	WAVE M0
//	
//	Variable t
//	
//	// Method 1: First is 140 µs, but subsequently 98 µs
//	// Pros: Preserves wave scaling; simple and fast
//	// Cons: outputs a matrix with 1 column; some function requires that you convert to a vector
//	t=tic()
//	Duplicate/O/R=[*][0] M0,M_dup
//	Redimension/N=-1 M_dup
//	toc(t)
//	
//	// Method 2: First is 136 µs, subsequently 94 µs
//	// Pros: Fast, similar to method 1
//	// Cons: can't name the output wave, thus additional lines of code will be needed
//	t=tic()
//	ImageTransform/G=0 getCol M0
//	WAVE W_ExtractedCol
//	SetScale/P x leftx(M0),deltax(M0),WaveUnits(M0,0), W_ExtractedCol
//	SetScale d 0,0,WaveUnits(M0,-1), W_ExtractedCol
//	toc(t)
//	
//	// Method 3: First is 268 µs, subsequently 246 µs
//	// Pros: you can name the destination wave
//	// Cons: slow. don't use this
//	t=tic()
//	MatrixOp/O M_Op=col(M0,0)
//	SetScale/P x leftx(M0),deltax(M0),WaveUnits(M0,0), M_Op
//	SetScale d 0,0,WaveUnits(M0,-1), M_Op
//	toc(t)
//	
//End