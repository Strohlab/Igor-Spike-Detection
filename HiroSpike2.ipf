#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.65		// version of procedure
#pragma IgorVersion = 6.2	// Requires Igor Pro v6.2

#include "HiroCoreServices"

// Written by Hirofumi Watari, Ph.D. © 2016
// This file imports, visualizes, and analyzes ephys data recorded in Spike2
// Built for Ting, Isa and Miriam

// What's new in HiroSpike2 0.65 (2016-12-11);Supports superimposition of three traces;---
// What's new in HiroSpike2 0.64 (2016-11-15);Supports editing in the Overview after the Average trials was run;---
// What's new in HiroSpike2 0.63 (2016-11-14);Supports repeated Average trials analyses;---
// What's new in HiroSpike2 0.62 (2016-11-13);Fixed a bug that causes an error under certain situation;---
// What's new in HiroSpike2 0.61 (2016-11-12);Adjusted the algorithm for Activity separator;Fixed a bug that can crash when changing values in Activity separator;---
// What's new in HiroSpike2 0.60 (2016-11-08);Adjusted the algorithm for Activity separator;Fixed a bug that incorrectly bins the gap under certain situation;---
// What's new in HiroSpike2 0.59 (2016-11-06);Improved up-down state detection;Supports multithreading in Activity separator;Caches parameters for improved performance in Activity separator;---
// What's new in HiroSpike2 0.58 (2016-11-04);Supports advanced semi-automated baseline detection;Improved UI and error reporting in Activity separator;Fixed a bug that causes an error when the cancel button is clicked during stimulus detection;---
// What's new in HiroSpike2 0.57 (2016-11-03);Improved algorithm for isolating activity from baseline;---
// What's new in HiroSpike2 0.56 (2016-11-02);Supports Hamming bandpass filter for auto-isolation of activity vs baseline;---
// What's new in HiroSpike2 0.55 (2016-11-01);Testing highpass filter;---
// What's new in HiroSpike2 0.54 (2016-10-25);Supports undo normalization;Minor UI updates;---
// What's new in HiroSpike2 0.53 (2016-10-24);Supports selection of baseline for normalization;Fixed a bug that causes an error when smoothing is set to zero;---
// What's new in HiroSpike2 0.52 (2016-10-22);Supports superimposition of two user-selected traces;---
// What's new in HiroSpike2 0.51 (2016-10-20);Auto-predicts peak polarity;Supports six new measurements in Data matrix;---
// What's new in HiroSpike2 0.50 (2016-10-18);Introducing beta version;Supports inverting and smoothing traces in Edit Mode;Supports baseline predicition after manually correcting several traces;---
// What's new in HiroSpike2 0.49 (2016-10-17);Auto-optimizes left marker;Supports analysis of negative peaks;Added a button to show tabulated dataset;---
// What's new in HiroSpike2 0.48 (2016-10-16);Supports measurements using traces with zeroed baseline offset;Supports multithreading on zero-ing;Supports back button;---
// What's new in HiroSpike2 0.47 (2016-10-15);Supports calculation of rise time;Improved error reporting;---
// What's new in HiroSpike2 0.46 (2016-10-14);Supports auto-detection of foot;---
// What's new in HiroSpike2 0.45 (2016-10-11);Supports editing of peak, baseline, half-amplitude duration, etc.;Supports error reporting;Built a framework for data storage;---
// What's new in HiroSpike2 0.44 (2016-10-10);Preemptively checks for problems before cutting the trace;---
// What's new in HiroSpike2 0.43 (2016-10-09);New UI for cutting the trace before and after stimulus;Reduced memory footprint by code refactoring;---
// What's new in HiroSpike2 0.42 (2016-10-08);Supports Gaussian smoothing on individual traces;---
// What's new in HiroSpike2 0.41 (2016-10-07);Added dynamic range control;Auto-detects peak;Allows user-defined baseline adjustment;---
// What's new in HiroSpike2 0.40 (2016-10-06);Added eight new controls for analyzing half-amplitude duration;Code refactoring in preparation of a new feature;---
// What's new in HiroSpike2 0.39 (2016-10-05);Fixed a bug that updates graph incorrectly when trial analysis is run more than once;---
// What's new in HiroSpike2 0.38 (2016-08-23);Fixed a bug that shows a button on a graph for no reason in a rare case;---
// What's new in HiroSpike2 0.37 (2016-08-23);Fixed a bug that plotted gibberish when the open text file dialog is canceled;---
// What's new in HiroSpike2 0.36 (2016-08-22);Fine-tuned range setting in the Edit mode;---
// What's new in HiroSpike2 0.35 (2016-08-19);Supports grouping by Train;---
// What's new in HiroSpike2 0.34 (2016-08-18);Supports detection of a higher number of stimuli;previously it detected up to 128;---
// What's new in HiroSpike2 0.33 (2016-08-17);Added an ability to trim traces on x-axis;Changed color for Miriam;---
// What's new in HiroSpike2 0.32 (2016-04-08);Improved X-axis scrolling;---
// What's new in HiroSpike2 0.31 (2016-04-07);Fixed a minor bug;---
// What's new in HiroSpike2 0.30 (2016-04-06);Properly displays all loaded traces;Improved workflow;Supports X-Axis Scrolling;---
// What's new in HiroSpike2 0.29 (2016-03-31);Fixed a bug where the text file fails to open;---
// What's new in HiroSpike2 0.28 (2016-03-13);Fixed a bug where error happens if there are less than 30 responses;---
// What's new in HiroSpike2 0.27 (2016-03-01);Supports user-defined exclusion of a response;---
// What's new in HiroSpike2 0.26 (2016-02-17);Imports Spike2 text file format;Streamlined trial average functions;---
// What's new in HiroSpike2 0.25 (2016-02-16);Auto-detects stimulus onsets, align, correct offset and average;---

// for trials
static constant ksBefore=0.2
static constant ksAfter=1

// for controls
static constant kCtrlBodyWidth=37
static constant kCtrlWidth=65
static constant kCtrlHeight=16

// for jumper buttons
static constant kLEFT=0
static constant kRIGHT=1
static constant kBOTH=2

// for peak detection
static constant kPntsToAvg=3

// for foot detection
static constant kPercentFoot=0.1	// threshold is 10% from the baseline

// polarity
static constant kPositive=1
static constant kNegative=2

// for best line fit
static constant kR2=0.90

// for jumper buttons
static constant kPnts2Jump=100	// sensitivity of the jump (bigger the value the larger the jump)

menu "Spike2"
	"Open Text File", OpenSpike2Data()
	"-"
	"Average trials",DoTrialAvg()
	"-"
	"-"
	Submenu "Top Graph"
		"Resize Window/7",ResizeWindow(0,0)
		"-"
		"Append stimulus bar to existing graph", Bar(0)
	End
	"-"
	
	Submenu "Axes"
		"X-Axis Scrolling...",XAxisScrolling2(0,0)
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
	
	Submenu "Utilities"
		"Superimpose two traces",hiroSpike2OverlayTwoWaves()
	End
	
	"-"
	"-"
	"About this menu", AboutHiroScript()
End


Function OpenSpike2Data()
// Use if header is still present.  It automatically skips everything
	
	Variable type	// 5 for Spike2
	
	type = GetFileInfo(5)	// Creates a global variables for file name and path
	
	if (type<0)
		// user canceled. abort
		Print "User canceled procedure."
		Abort
	endif
	
	String nameDF
	Variable lastDataPoint
	
	Variable V_flag
	String strLine
	String strMode,strUnits
	Variable fs,sStart
	Variable i
	
	Make/T/FREE wMode
	Make/T/FREE wUnits
	Make/FREE wFs
	Make/FREE wSecStart
	
	if (type == 3)	// Import Spike2 data
		ImportLOGintoNotebook()
		
		V_flag=IsThisSpike2DataFile()
		
		if (V_flag)
			Print "Hiro's Igor Pro Scripts 2010-2016 © Hirofumi Watari, Ph.D."
			do
				Notebook ImageLog selection={startOfNextParagraph,startOfNextParagraph}		// cursor on next paragraph
				Notebook ImageLog selection={startOfParagraph,endOfChars},findText={"",1}		// select the whole line
				GetSelection notebook, ImageLog, 2			// copies the selection in S_selection
				if (strlen(S_selection))
					strLine=ReplaceString("\"",S_selection,"")		// remove quotes
					strMode=StringFromList(2,strLine,"\t")
					strUnits=StringFromList(3,strLine,"\t")
					fs=str2num(StringFromList(4,strLine,"\t"))
					
					// temporarily store the values as waves
					wMode[i]=strMode
					wUnits[i]=strUnits
					wFs[i]=fs
				else
					break
				endif
				
				//Print strMode,strUnits,fs
				i+=1
			while(i<30)	// it's unlikely to have more than 30 channels
			Print i,"waves detected in this Spike2 data file"
		else
			Abort "The file cannot be opened as Spike2 format.  See Hiro if you think this is a bug."
		endif
		
		LoadDataAsGeneralText(0)
		
		NVAR nRegions
		KillVariables nRegions
		
		SVAR fileName
		SVAR folderPath
		nameDF = ReplaceString(".txt",fileName,"")
		
		Print folderPath+fileName
		
		String nameW
		Variable k
		for(k=0;k<i;k+=1)
			// detect the time of first data point for each channel (they can be slightly off)
			Notebook ImageLog selection={startOfNextParagraph,startOfNextParagraph},findText={"\"START\"",1}
			Notebook ImageLog selection={startOfParagraph,endOfChars},findText={"",1}
			GetSelection notebook, ImageLog, 2
			if (strlen(S_selection))
				sStart=str2num(StringFromList(1,S_selection,"\t"))
				wSecStart[k]=sStart
			endif
			nameW="R"+num2str(k)
			Rename $nameW,$wMode[k]
			nameW=wMode[k]
			if (strlen(wUnits[k]))
				SetScale d 0,0,wUnits[k], $nameW
			endif
			SetScale/P x wSecStart[k],1/wFs[k],"s", $nameW
		endfor
		
		CheckDFDuplicates(nameDF)
		
		// optional
		DoWindow/K/Z ImageLog
	endif
	
	String listW=WaveList("*",";","")
	
	DFREF dfr=GetDataFolderDFR()
	
	Display/K=1/N=GraphSpike2Step1 as "Overview: "+nameDF
	
	String axisName
	Variable n=CountObjectsDFR(dfr,1)
	Variable y1,y2
	Variable pad=0.2/n
	for(i=0;i<n;i+=1)
		//WAVE w=WaveRefIndexedDFR(dfr,i)
		WAVE w=$GetIndexedObjNameDFR(dfr,1,i)
		axisName="customLeft"+num2str(i)
		AppendToGraph/L=$axisName w
		y1=1-1/n*(i+1)	// low
		y2=1-1/n*i	// high
		
		// add padding
		if (y1)
			y1+=pad
		endif
		ModifyGraph lblPos($axisName)=70,freePos($axisName)=0,axisEnab($axisName)={y1,y2}
		ModifyGraph lowTrip($axisName)=0.001
		
		Label $axisName GetIndexedObjNameDFR(dfr,1,i)
	endfor
	
	ModifyGraph margin(left)=80
	ModifyGraph rgb=(0,39168,0)
	
//	WAVE wStim=tment
//	WAVE wTrace=CCmode
//	
//	AppendToGraph/L=$axisName wTrace
//	AppendToGraph/L=customLeft2 wStim
//	ModifyGraph lblPos($axisName)=50, freePos($axisName)=0, axisEnab($axisName)={0.55,1}
//	ModifyGraph lblPos(customLeft2)=50, freePos(customLeft2)=0, axisEnab(customLeft2)={0,0.45}
	
	ResizeWindow(1280,400)
	
	ControlBar/L 50
	Button buttonSpike2Edit title="Edit...",proc=ButtonProcSpike2Edit,pos={1,400}
	
End


Function hiroSpike2EditMode()
	
	// force auto-axes
	SetAxis/A
	
	// Allow trim, smooth, etc.
	DoIgorMenu "Edit","Duplicate"
	
	ControlBar/L/W=GraphSpike2Step1_1 110
	
	DoWindow/HIDE=1 GraphSpike2Step1
	
	DoWindow/T GraphSpike2Step1_1,"Edit Mode"
	
	// Remove buttons
	Button buttonSpike2Edit disable=3
	
	// The "real" traces are gray
	ModifyGraph rgb=(47872,47872,47872)
	
	DFREF dfr=GetDataFolderDFR()
	Variable n=CountObjectsDFR(dfr,1)
	
	if (DataFolderExists(":temp"))
		KillDataFolder :temp
	endif
	NewDataFolder dfr:temp
	DFREF dfrT=dfr:temp
	
	if (!DataFolderExists(":EditCache"))
		NewDataFolder dfr:EditCache
		
		// Parameters used for editing
		Make/T/N=(n) :EditCache:wTNameW,:EditCache:wNormBaseUnits=""
		Make/N=(n) :EditCache:wInvert,:EditCache:wSmooth,:EditCache:wNormBase
		Make/N=2 :EditCache:wTrimRange
	endif
	
	if (DataFolderExists(":tempEditCache"))
		KillDataFolder :tempEditCache
	endif
	DuplicateDataFolder :EditCache,:tempEditCache
	DFREF dfrTC=dfr:tempEditCache
	
	// work on cache in the temp DF
	WAVE/T wTNameW=dfrTC:wTNameW
	WAVE wInvert=dfrTC:wInvert
	WAVE wSmooth=dfrTC:wSmooth
	WAVE wNormBase=dfrTC:wNormBase
	WAVE/T wNormBaseUnits=dfrTC:wNormBaseUnits
	WAVE wTrimRange=dfrTC:wTrimRange
	
	String axisName,nameW,nameWBase,nameWSel
	
	String nameCtrl
	Variable padX=10
	Variable padY=75
	
	Variable i,x1,x2
	for (i=0;i<n;i+=1)
		WAVE w=$GetIndexedObjNameDFR(dfr,1,i)
		nameW=NameOfWave(w)		// the source
		
		// Load trace name to temp cache
		wTNameW[i]=nameW
		
		// Copy twice: for base and selected (for trim)
		nameWBase=nameW
		nameWSel=nameW+"_sel"
		
		axisName="customLeft"+num2str(i)
		Duplicate/O w,dfrT:$nameWBase
		
		WAVE wBase=dfrT:$nameWBase
		
		Variable normBase=wNormBase[i]
		
		// Invert, if previously applied
		if (wInvert[i])
			MultiThread wBase*=-1
		endif
		
		// Recreate smoothing, if previously applied
		if (wSmooth[i])
			Smooth wSmooth[i], wBase
		endif
		
		// Recreate normalization, if previously applied
		// Important: normalize after inverting and smoothing
		if (normBase)
			MultiThread wBase/=abs(normBase)
			if (normBase>0)
				MultiThread wBase-=1
			else
				MultiThread wBase+=1
			endif
			
			SetScale d 0,0,wNormBaseUnits[i], wBase	// customize units
		endif
		
		Duplicate/O wBase,dfrT:$nameWSel
		AppendToGraph/L=$axisName dfrT:$nameWSel
		
		// replace the source trace with the new temp
		ReplaceWave trace= $nameW, dfrT:$nameWBase
		
		// add control for each trace
		nameCtrl="titleSpike2Edit"+num2str(i)
		TitleBox $nameCtrl title=nameW+":",frame=0,pos={1,i*padY}
		
		nameCtrl="checkSpike2EditInvert"+num2str(i)
		CheckBox $nameCtrl title="Flip",pos={55,i*padY},value=wInvert[i]
		CheckBox $nameCtrl proc=CheckProcSpike2EditInvert,userData=num2str(i)
		CheckBox $nameCtrl help={"Flip "+nameW}
		
		nameCtrl="setvarSpike2EditSmooth"+num2str(i)
		SetVariable $nameCtrl title="Smooth",size={80,20},pos={padX,i*padY+20}
		SetVariable $nameCtrl proc=SetVarProcSpike2EditSmooth,limits={0,32767,5}
		SetVariable $nameCtrl live=1,userData=num2str(i)
		SetVariable $nameCtrl value= _NUM:wSmooth[i],help={"Smooth "+nameW+" with Gaussian filter"}
		
		nameCtrl="buttonSpike2EditNormBase"+num2str(i)
		String buttonTitle
		if (wNormBase[i])
			buttonTitle="Undo Norm"
		else
			buttonTitle="Normalize..."
		endif
		Button $nameCtrl title=buttonTitle,size={80,20},pos={padX,i*padY+40}
		Button $nameCtrl proc=ButtonProcSpike2EditNormBase,userData=num2str(i)
		Button $nameCtrl help={"Normalize trace by baseline"}
	endfor
	
	x1=leftx(w)
	x2=rightx(w)
	
	TitleBox titleSpike2Trim title="Trim:",frame=0,pos={1,385}
	
	SetVariable setvarSpike2TrimFrom size={50,16},pos={1,400}
	SetVariable setvarSpike2TrimFrom proc=SetVarProcSpike2TrimFrom,value=_NUM:x1
	SetVariable setvarSpike2TrimFrom limits={x1,x2,1},live=1
	SetVariable setvarSpike2TrimFrom help={"Trim all traces from this time point. WARNING: the change will be permanent: it's irreversible."}
	
	TitleBox titleSpike2Hyphen title="-",frame=0,pos={53,401}
	
	SetVariable setvarSpike2TrimTo size={50,16},pos={60,400}
	SetVariable setvarSpike2TrimTo proc=SetVarProcSpike2TrimTo,value=_NUM:x2
	SetVariable setvarSpike2TrimTo limits={x1,x2,1},live=1
	SetVariable setvarSpike2TrimTo help={"Trim all traces to this time point. WARNING: the change will be permanent: it's irreversible."}
	
	Button buttonSpike2EditCancel title="Cancel",proc=ButtonProcSpike2EditCancel
	Button buttonSpike2EditCancel pos={1,420},help={"Cancel and exit Edit Mode"}
	
	Button buttonSpike2EditDone title="Done",proc=ButtonProcSpike2EditDone
	Button buttonSpike2EditDone pos={57,420},help={"Save and exit Edit Mode"}
	
End


Function CheckProcSpike2EditInvert(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			Variable i=str2num(cba.userData)
			
			// work in the temp space
			DFREF dfr=:temp
			DFREF dfrC=:tempEditCache
			
			WAVE/T wTNameW=dfrC:wTNameW
			WAVE wInvert=dfrC:wInvert
			
			String nameW=wTNameW[i]
			String nameWSel=nameW+"_sel"
			
			//Variable t=tic()
			WAVE w=dfr:$nameW
			//WAVE wSel=:temp:$nameWSel
			
			// invert
			MultiThread w*=-1
			//MultiThread wSel*=-1
			
			// Trim selected
			Variable x1,x2
			ControlInfo setvarSpike2TrimFrom
			x1=V_value
			ControlInfo setvarSpike2TrimTo
			x2=V_value
			Duplicate/O/R=(x1,x2) w,dfr:$nameWSel
			
			//toc(t)
			
			// Save parameter
			if (!wInvert[i])
				wInvert[i]=1
			else
				wInvert[i]=0
			endif
			
			// Also, adjust the sign of wNormBase (dependent on wInvert)
			WAVE wNormBase=dfrC:wNormBase
			wNormBase[i]*=-1
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2EditSmooth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable i=str2num(sva.userData)
			
			DFREF dfr=:temp
			DFREF dfrC=:tempEditCache
			
			WAVE/T wTNameW=dfrC:wTNameW
			
			String nameW=wTNameW[i]
			String nameWBase=nameW
			String nameWSel=nameW+"_sel"
			
			// copy the source
			Duplicate/O $nameW,dfr:$nameWBase
			
			WAVE w=dfr:$nameWBase
			
			if (dval)
				Smooth dval, w
			endif
			
			// invert if needed
			WAVE wInvert=:tempEditCache:wInvert
			if (wInvert[i])
				MultiThread w*=-1
			endif
			
			// Normalize if needed
			WAVE wNormBase=:tempEditCache:wNormBase
			WAVE/T wNormBaseUnits=:tempEditCache:wNormBaseUnits
			Variable normValue=wNormBase[i]
			if (normValue)
				MultiThread w/=abs(normValue)
				if (normValue>0)
					MultiThread w-=1
				else
					MultiThread w+=1
				endif
				SetScale d 0,0,wNormBaseUnits[i], w
			endif
			
			// Trim selected
			Variable x1,x2
			ControlInfo setvarSpike2TrimFrom
			x1=V_value
			ControlInfo setvarSpike2TrimTo
			x2=V_value
			Duplicate/O/R=(x1,x2) w,dfr:$nameWSel
			
			// Save parameter
			WAVE wSmooth=dfrC:wSmooth
			wSmooth[i]=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2EditNormBase(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Variable i=str2num(ba.userData)
			
			DFREF dfr=:temp
			DFREF dfrC=:tempEditCache
			
			WAVE/T wTNameW=dfrC:wTNameW
			
			String nameW=wTNameW[i]
			String nameWBase=nameW
			String nameWSel=nameW+"_sel"
			
			String buttonTitle
			WAVE wNormBase=dfrC:wNormBase
			WAVE/T wNormBaseUnits=dfrC:wNormBaseUnits
			if (wNormBase[i])
				// undo normalization
				wNormBase[i]=0
				wNormBaseUnits[i]=""
			else
				// define the baseline in a new graph
				hiroSpike2EditNormBaseMode(i,dfr:$nameW)
			endif
			
			// evaluate and change button accordingly
			if (wNormBase[i])
				buttonTitle="Undo Norm"
			else
				buttonTitle="Normalize..."
			endif
			
			String nameCtrl="buttonSpike2EditNormBase"+num2str(i)
			Button $nameCtrl title=buttonTitle
			
			// copy the source
			Duplicate/O $nameW,dfr:$nameWBase
			
			WAVE w=dfr:$nameWBase
			
			// smooth if needed
			WAVE wSmooth=dfrC:wSmooth
			if (wSmooth[i])
				Smooth wSmooth[i], w
			endif
			
			// invert if needed
			WAVE wInvert=:tempEditCache:wInvert
			if (wInvert[i])
				MultiThread w*=-1
			endif
			
			Variable normValue=wNormBase[i]
			if (normValue)
				// Normalize
				
				MultiThread w/=abs(normValue)
				if (normValue>0)
					MultiThread w-=1
				else
					MultiThread w+=1
				endif
				
				SetScale d 0,0,wNormBaseUnits[i], w
			else
				// user removed normalization
				wNormBaseUnits[i]=""
			endif
			
			// Trim selected
			Variable x1,x2
			ControlInfo setvarSpike2TrimFrom
			x1=V_value
			ControlInfo setvarSpike2TrimTo
			x2=V_value
			Duplicate/O/R=(x1,x2) w,dfr:$nameWSel
			
			//toc(t)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2EditNormBaseMode(i,w)
	
	Variable i
	
	WAVE w
	
	DFREF dfr=:temp
	DFREF dfrC=:tempEditCache
	
	Variable x0,y0
	Variable width=1000
	Variable height=300
	CenterObjScreen(x0,y0,width,height)
	
	Display/K=2/N=GraphNormBaseMode/W=(x0,y0,x0+width,y0+height) as "Select baseline: "+NameOfWave(w)
	
	AppendToGraph/B=customBottom1 w
	AppendToGraph/B=customBottom2 w
	
	ModifyGraph lblPos(customBottom1)=70,freePos(customBottom1)=0,axisEnab(customBottom1)={0,0.75}
	ModifyGraph lblPos(customBottom2)=70,freePos(customBottom2)=0,axisEnab(customBottom2)={0.80,1}
	
	// default position
	Variable xLoc=(rightx(w)-leftx(w))/2	// s
	Variable xWidth=1	// s
	hiroSpike2NormDrawCurtain(xLoc,xWidth)
	
	String xUnits=WaveUnits(w,0)
	
	ControlBar/T 50
	
	TitleBox titleSpike2NormLoc title="Where? ("+xUnits+")",pos={1,5},frame=0
	
	Slider sliderSpike2NormBaseLoc size={525,20},pos={75,2},vert=0
	Slider sliderSpike2NormBaseLoc proc=SliderProcSpike2NormBaseLoc,value=xLoc
	Slider sliderSpike2NormBaseLoc limits={leftx(w),rightx(w),0},help={"Set Baseline location"}
	
	SetVariable setvarSpike2NormWidth title="How long? ("+xUnits+")",size={125,20}
	SetVariable setvarSpike2NormWidth pos={625,5}
	SetVariable setvarSpike2NormWidth proc=SetVarProcSpike2NormWidth,value= _NUM:xWidth
	SetVariable setvarSpike2NormWidth limits={pnt2x(w,1)-pnt2x(w,0),rightx(w)-leftx(w),0.25},live=1
	SetVariable setvarSpike2NormWidth help={"Set width of the baseline to average"}
	
	Button buttonSpike2Normalize title="Normalize",proc=ButtonProcSpike2Normalize
	Button buttonSpike2Normalize pos={775,5},size={70,20},userData=num2str(i)
	Button buttonSpike2Normalize help={"Normalize using the selected baseline"}
	
	CheckBox checkSpike2NormUnits title="Customize units",pos={775,30}
	CheckBox checkSpike2NormUnits proc=CheckProcSpike2NormUnits
	CheckBox checkSpike2NormUnits help={"Check to assign a custom units"}
	
	Button buttonSpike2NormCancel title="Cancel",proc=ButtonProcSpike2NormCancel
	Button buttonSpike2NormCancel pos={850,5},help={"Cancel and exit Normalize Mode"}
	
	PauseForUser GraphNormBaseMode
	
End


Function CheckProcSpike2NormUnits(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SliderProcSpike2NormBaseLoc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				ControlInfo setvarSpike2NormWidth
				hiroSpike2NormDrawCurtain(curval,V_Value)
				
			endif
			break
	endswitch

	return 0
End


Function hiroSpike2NormDrawCurtain(xLoc,xWidth)
	
	Variable xLoc
	Variable xWidth
	
	Variable xPad=3
	
	Variable x1=xLoc-0.5*xWidth
	Variable x2=xLoc+0.5*xWidth
	
	
	Variable xLeftEdge=x1-xPad
	Variable xRightEdge=x2+xPad
	
	SetAxis customBottom2 xLeftEdge,xRightEdge
	
	DrawAction/L=ProgBack delete
	SetDrawLayer ProgBack
	
	// draw a vertical dotted line at the center location
	SetDrawEnv xcoord= customBottom1,linefgc= (13056,13056,13056),dash= 2,linethick= 0.50
	DrawLine xLoc,0,xLoc,1
	
	// draw the left curtain
	SetDrawEnv xcoord= customBottom2,fillfgc= (56576,56576,56576),linethick= 0.00
	DrawRect xLeftEdge,0,x1,1
	
	// Set the right curtain
	SetDrawEnv xcoord= customBottom2,fillfgc= (56576,56576,56576),linethick= 0.00
	DrawRect x2,0,xRightEdge,1
	
	// Default
	SetDrawLayer UserFront
	
End


Function SetVarProcSpike2NormWidth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo sliderSpike2NormBaseLoc
			hiroSpike2NormDrawCurtain(V_Value,dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2Normalize(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Variable i=str2num(ba.userData)
			
			DFREF dfrC=:tempEditCache
			
			WAVE/T wT=dfrC:wTNameW
			
			String nameW=wT[i]
			WAVE w=TraceNameToWaveRef("GraphNormBaseMode",nameW)
			
			ControlInfo sliderSpike2NormBaseLoc
			Variable xLoc=V_Value
			
			ControlInfo setvarSpike2NormWidth
			Variable xWidth=V_Value
			
			Variable x1=xLoc-0.5*xWidth
			Variable x2=xLoc+0.5*xWidth
			
			// Calculate average baseline.
			Variable avgBase=mean(w,x1,x2)
			WAVE wNormBase=dfrC:wNormBase
			
			// Save as signed value. Depending on the sign, the formula for normalization changes
			// if positive, norm=(w/abs(avgBase))-1
			// if negative, norm=(w/abs(avgBase))+1
			wNormBase[i]=avgBase
			
			// Check if the user wants to modify units
			ControlInfo checkSpike2NormUnits
			Variable assignUnits=V_Value
			
			KillWindow $WinName(0,1)	// normalization will happen after PauseForUser is deactivated
			
			// Get units if needed. Do this after PauseForUser is deactivated
			WAVE/T wUnits=dfrC:wNormBaseUnits
			
			String strUnits=wUnits[i]
			
			if (assignUnits)
				
				Prompt strUnits,"Units: "
				DoPrompt "Enter the units after normalization",strUnits
				if (V_Flag)
					wUnits[i]=""
				else
					wUnits[i]=strUnits
				endif
				
			else
				wUnits[i]=""
			endif
			
			// patch
			String nameAxis="customLeft"+num2str(i)
			ModifyGraph lowtrip($nameAxis)=0.001
			
			// Print formula
			if (avgBase>0)
				printf "Normalize %s = %s / %g - 1\r",wUnits[i],nameW,avgBase
			else
				printf "Normalize %s = %s / abs(%g) + 1\r",wUnits[i],nameW,avgBase
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2NormCancel(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			KillWindow $WinName(0,1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2EditCancel(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			KillWindow $WinName(0,1)
			DoWindow/HIDE=0/F GraphSpike2Step1
			
			KillDataFolder :temp
			KillDataFolder :tempEditCache
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2EditDone(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2EditDone()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2EditDone()
	
	// Save edited parameters
	if (DataFolderExists(":EditCache"))
		KillDataFolder :EditCache
	endif
	DuplicateDataFolder :tempEditCache,:EditCache
	KillDataFolder :tempEditCache
	
	// Save edited traces
	if (!DataFolderExists(":Edited"))
		NewDataFolder :Edited
	endif
	
	ControlInfo setvarSpike2TrimFrom
	Variable x1=V_value
	
	ControlInfo setvarSpike2TrimTo
	Variable x2=V_value
	
	hiroSpike2TrimX(x1,x2,0)
	
	KillWindow $WinName(0,1)
	DoWindow/HIDE=0/F GraphSpike2Step1
	
	// If the originals are shown on the graph, replace with Edited
	hiroSpike2EditCheckOverview("GraphSpike2Step1")
	
	KillDataFolder :temp
	
End


Function hiroSpike2EditCheckOverview(nameGraph)
	// After editing, replace traces with the Edited if the originals are still shown on the overview graph
	
	String nameGraph
	
	DFREF dfr=GetDataFolderDFR()
	DFREF dfrE=:Edited
	DFREF dfrC=:EditCache
	
	String nameW
	
	WAVE/T wT=dfrC:wTNameW
	
	Variable n=numpnts(wT)
	Variable i
	String nameAxis
	for (i=0;i<n;i+=1)
		nameW=wT[i]
		
		WAVE wTraceOnGraph=TraceNameToWaveRef("",nameW)	// get wave ref of the trace on the graph
//		WAVE wOrig=$nameW		// wave ref of the original trace
//		
//		// compare against the original
//		if (WaveRefsEqual(wTraceOnGraph,wOrig))
//			ReplaceWave trace= $nameW, dfrE:$nameW
//		endif
		
		WAVE wEditedTrace=dfrE:$nameW
		
		// compare against the edited trace (even in a potentially new DF)
		if (!WaveRefsEqual(wTraceOnGraph,wEditedTrace))
			ReplaceWave trace= $nameW, dfrE:$nameW
		endif
		
		nameAxis="customLeft"+num2str(i)
		ModifyGraph lowtrip($nameAxis)=0.001
	endfor
	
End


Function SetVarProcSpike2TrimFrom(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			WAVE w=WaveRefIndexed("",0,1)
			
			Variable x1,x2
			x1=leftx(w)
			
			ControlInfo setvarSpike2TrimTo
			x2=V_value
			hiroSpike2TrimX(dval,x2,1)
			
			// Adjust limits
			SetVariable setvarSpike2TrimFrom limits={x1,x2,1}
			
			// Save parameter
			WAVE wTrimRange=:tempEditCache:wTrimRange
			wTrimRange[0]=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2TrimTo(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			WAVE w=WaveRefIndexed("",0,1)
			
			Variable x1,x2
			x2=rightx(w)
			
			ControlInfo setvarSpike2TrimFrom
			x1=V_value
			hiroSpike2TrimX(x1,dval,1)
			
			// Adjust limits
			SetVariable setvarSpike2TrimTo limits={x1,x2,1}
			
			// Save parameter
			WAVE wTrimRange=:tempEditCache:wTrimRange
			wTrimRange[1]=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2TrimX(x1,x2,mode)
	
	// Trim all selected traces from x1 to x2
	
	Variable x1,x2
	Variable mode	// 0 for original, 1 for selected only (for visual feedback)
	
	String nameW,nameWBase,nameWSel
	
	DFREF dfr=GetDataFolderDFR()
	DFREF dfrT=dfr:temp
	
	Variable n=CountObjectsDFR(dfr,1)
	Variable i
	for (i=0;i<n;i+=1)
		WAVE w=$GetIndexedObjNameDFR(dfr,1,i)
		nameW=NameOfWave(w)
		nameWBase=nameW
		nameWSel=nameWBase+"_sel"
		if (mode)
			WAVE wBase=dfrT:$nameWBase
			Duplicate/O/R=(x1,x2) wBase,dfrT:$nameWSel
		else
			DFREF dfrE=dfr:Edited
			// trim both the original and the traces in the Edited DF
			//Duplicate/O/R=(x1,x2) w,dfrE:$nameW	// temporarily hold trimmed original in the Edited DF
			
			Duplicate/FREE/R=(x1,x2) w,wFree
			Duplicate/O wFree,$nameW
			
//			WAVE w2=dfrE:$NameOfWave(w)
//			Duplicate/O w2,dfr:$NameOfWave(w)	// replace the original
//			
			Duplicate/O dfrT:$nameWSel,dfrE:$NameOfWave(w)	// replace the edited
		endif
	endfor
	
End


Function ButtonProcSpike2Edit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			if (DataFolderExists(":IO"))
				hiroSpike2Step2CleanSlate()
			endif
			
			hiroSpike2EditMode()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function IsThisSpike2DataFile()
	
	Notebook ImageLog selection={startOfFile,startOfFile},findText={"\"INFORMATION\"", 3}
	if (V_flag)
		Notebook ImageLog selection={startOfFile,startOfFile},findText={"\"SUMMARY\"", 3}
		if (V_flag)
			return 1
		else
			return 0
		endif
	else
		return 0
	endif
	
End


Function hiroSpike2SaveBeforeStep2()
	// Save the contents of the DF before doing DoTrialAvg()
	// This will allow multiple execution of the function later.
	
//	if (DataFolderExists(":Orig"))
//		return 0
//	endif
//	
//	DFREF dfr=GetDataFolderDFR()
//	
//	NewDataFolder :Orig
//	DFREF dfrOrig=:Orig
//	
//	Variable n=CountObjectsDFR(dfr,1)
//	
//	Variable i
//	for(i=0;i<n;i+=1)
//		WAVE w=$GetIndexedObjNameDFR(dfr,1,i)
//		
//		Duplicate w,dfrOrig:$NameOfWave(w)
//	endfor
	
	if (DataFolderExists(":CoreCache"))
		return 0
	endif
	
	// Make Cache DF and CoreCache DF
	// the former will be filled with stuff later and only has a lifetime of each DoAvgTrials
	// the latter will be passed on through generations
	NewDataFolder/O :Cache
	
	NewDataFolder :CoreCache
	DFREF dfrCache=:CoreCache
	
	String/G dfrCache:gOrigWaveList=WaveList("*",";","")
	
	Make/T/N=2 dfrCache:wTStimResPair
	Make/N=2 dfrCache:wBeforeAfter
	
	return 1
	
End


Function hiroSpike2Step2CleanSlate()
	// Make a new DF with the original waves in it before running Step 2.
	// This is required if DoTrialAvg() is already executed before
	
	DFREF dfr=GetDataFolderDFR()
	
	// Copy contents of the original
	//DuplicateDataFolder dfr:Orig,root:temp
	//DuplicateDataFolder dfr:Orig,root:temp:Orig
	
	// Copy original set of waves to a new temp DF
	if (DataFolderExists("root:temp"))
		KillDataFolder root:temp
	endif
	NewDataFolder root:temp
	SVAR/Z gOrigWaveList=:CoreCache:gOrigWaveList
	if (SVAR_Exists(gOrigWaveList))
		Variable n=ItemsInList(gOrigWaveList)
		String nameW
		Variable i
		for (i=0;i<n;i+=1)
			nameW=StringFromList(i,gOrigWaveList)
			Duplicate $nameW,root:temp:$nameW
		endfor
	endif
	
	// Copy caches
	//Duplicate dfr:Cache:wTCacheStimResPair,root:temp:Cache:wTCacheStimResPair
	
	//SVAR/Z gOrigWaveList=:CoreCache:gOrigWaveList
	//if (SVAR_Exists(gOrigWaveList))
	//	String/G root:temp:CoreCache:gOrigWaveList=gOrigWaveList
	//endif
	
	DuplicateDataFolder dfr:CoreCache,root:temp:CoreCache
	
//	DuplicateDataFolder dfr:Cache,root:temp:Cache
//	// Reset select cache
//	NVAR iStim=temp:Cache:iStim
//	iStim=0
//	NVAR iStimprev=temp:Cache:iStimprev
//	iStimprev=0
//	NVAR isZeroed=temp:Cache:isZeroed
//	isZeroed=0
//	NVAR optimizeLeft=temp:Cache:optimizeLeft
//	optimizeLeft=1
//	SVAR gWarning=temp:Cache:gWarning
//	gWarning=""
	
	NewDataFolder root:temp:Cache
	
	if (DataFolderExists(":EditCache"))
		DuplicateDataFolder dfr:EditCache,root:temp:EditCache
	endif
	
	if (DataFolderExists(":Edited"))
		DuplicateDataFolder dfr:Edited,root:temp:Edited
	endif
	
	// copy the original file name to the new DF. Will be used to generate a new DF name
	SVAR/Z fileName
	if (SVAR_Exists(fileName))
		String/G root:temp:fileName=fileName
	endif
	
	// assign a unique name
	String nameDF=CheckDFDuplicates(GetDataFolder(0))	// returns a DF name with single quotes, if needed
	
	String namePath="root:"+nameDF
	
	SetDataFolder $namePath	
	
End


Function hiroSpike2BeforeAfterRefine(sBefore,sAfter,sStimDuration)
	
	Variable sBefore
	Variable sAfter
//	WAVE w
//	WAVE wStim
	Variable sStimDuration
	
	// Load from cache, if available
	Variable flag
	WAVE wBeforeAfter=:CoreCache:wBeforeAfter
	if (wBeforeAfter[0])
		sBefore=wBeforeAfter[0]
		flag+=1
	endif
	if (wBeforeAfter[1])
		sAfter=wBeforeAfter[1]
		flag+=1
	endif
	
	if (!flag)
		// Find stimulus duration (should do this on every single one, but assume it's the same for all)
		WAVE wOnLoc
		WAVE wOffLoc
		
		// estimate stim interval
		sAfter=wOnLoc[1]-wOnLoc[0]
	endif
	
	// Adjust sAfter if grouping by train
	NVAR groupByTrain
	if (groupByTrain)
		WAVE wPulseOnLoc
		// duration of the train plus an interval between two consecutive pulses
		sAfter=round(sStimDuration+(wPulseOnLoc[1]-wPulseOnLoc[0]))
	endif
	
//	do
//		Prompt sBefore, "Before stimulus onset (s)"
//		Prompt sAfter, "After sitmulus onset (s)"
//		DoPrompt/HELP="Enter a positive number. Hit a tab-key to toggle between the two fields." "How much data to show?",sBefore,sAfter
//		if (V_flag == 1)
//			Print "User Canceled Procedure"
//			Abort	//quit if cancel button was clicked
//		endif
//	while(sBefore<=0 || sAfter<=0)
	
	// Visualize and adjust (save occurs in the "Cut" button)
	hiroSpike2BeforeAfterEdit(sBefore,sAfter)
	
End


Function SetVarProcSpike2EditBefore(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable sBefore=-dval
			
			ControlInfo setvarSpike2RangeTo
			Variable sAfter=V_Value
			
			ControlInfo setvarStimNumber
			Variable i=V_Value-1
			
			WAVE wOnLoc
			
			SetAxis bottom wOnLoc[i]-sBefore,wOnLoc[i]+sAfter
			
			// Check for problems
			hiroSpike2BeforeAfterCheck(sBefore,sAfter)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2EditAfter(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo setvarSpike2RangeFrom
			Variable sBefore=-V_Value
			
			Variable sAfter=dval
			
			ControlInfo setvarStimNumber
			Variable i=V_Value-1
			
			WAVE wOnLoc
			
			SetAxis bottom wOnLoc[i]-sBefore,wOnLoc[i]+sAfter
			
			// Check for problems
			hiroSpike2BeforeAfterCheck(sBefore,sAfter)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2BeforeAfterQuit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2EditButtonEnable()
			
			KillWindow graphBeforeAfter
			Print "User canceled procedure"
			Abort
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2BeforeAfterCut(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE wBeforeAfter=:CoreCache:wBeforeAfter
			
			ControlInfo setvarSpike2RangeFrom
			wBeforeAfter[0]=abs(V_Value)
			
			ControlInfo setvarSpike2RangeTo
			wBeforeAfter[1]=V_Value
			
			KillWindow graphBeforeAfter
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2BeforeAfterStim(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable i=dval-1
			
			WAVE wOnLoc
			
			ControlInfo setvarSpike2RangeFrom
			Variable sBefore=abs(V_Value)
			
			ControlInfo setvarSpike2RangeTo
			Variable sAfter=V_Value
			
			SetAxis bottom wOnLoc[i]-sBefore,wOnLoc[i]+sAfter
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2BeforeAfterCheck(sBefore,sAfter)
	// Check if the selected sBefore and sAfter is valid (e.g., won't truncate at the end)
	
	Variable sBefore
	Variable sAfter
	
	WAVE/T wT=:CoreCache:wTStimResPair
	
	WAVE w=$wT[1]
	
	WAVE wOnLoc
	
	Variable nStim=numpnts(wOnLoc)
	Variable nPnts=numpnts(w)
	
	Make/FREE/N=(nStim) wBeforeOK,wAfterOK	// make it free
	
	// init (must do because this will be called multiple times)
	wBeforeOK=0
	wAfterOK=0
	
	Variable p1,p2
	
	Variable i
	for (i=0;i<nStim;i+=1)
		p1=x2pnt(w,wOnLoc[i]-sBefore)
		p2=x2pnt(w,wOnLoc[i]+sAfter)
		
		// verify
		if (p1>=0)
			wBeforeOK[i]=1
		endif
		if (p2<nPnts)
			wAfterOK[i]=1
		endif
	endfor
	
	// warn problems to the user, if any
	Variable nBadBefore=nStim-sum(wBeforeOK)
	Variable nBadAfter=nStim-sum(wAfterOK)
	
	// Get index of the problematic trace
	Extract/O/INDX wBeforeOK,:Cache:wBeforeINDX,wBeforeOK==0
	Extract/O/INDX wAfterOK,:Cache:wAfterINDX,wAfterOK==0
	
	WAVE wBeforeINDX=:Cache:wBeforeINDX
	WAVE wAfterINDX=:Cache:wAfterINDX
	
	String strErr
	String strErrStim=""
	
	Variable nProblems=nBadBefore+nBadAfter
	
	WAVE/Z wStimProblem
	if (WaveExists(wStimProblem))
		KillWaves wStimProblem
	endif
	
	// reset warning
	hiroSpike2Warning("")
	
	if (nProblems)
		if (nProblems==1)
			strErr="At least one trace may truncate"
		else
			strErr="At least "+num2str(nProblems)+" traces may truncate"
		endif
		
		// combine problem indeces
		Concatenate/O/NP {wBeforeINDX,wAfterINDX},wStimProblem
		
		WAVE wStimProblem
		if (numpnts(wStimProblem))
			wStimProblem+=1
			
			Variable k
			for (k=0;k<numpnts(wStimProblem);k+=1)
				strErrStim+=" "+num2str(wStimProblem[k])+","
			endfor
			
			strErrStim=RemoveEnding(strErrStim,",")
			
			// finalize warning message
			strErr+=" (stim #"+strErrStim+")"
		endif
		
		// Show warning
		//TitleBox titleWarning title=strErr,disable=0
		hiroSpike2Warning(strErr)
	else
		//TitleBox titleWarning disable=1
		//hiroSpike2Warning("")
	endif
	
End


Function hiroSpike2BeforeAfterEdit(sBefore,sAfter)
	
	Variable sBefore
	Variable sAfter
	
	//WAVE w
	//WAVE wStim
	
	WAVE wOnLoc
	WAVE wOffLoc
	
	Variable x0,y0
	Variable width=350
	Variable height=200
	CenterObjScreen(x0,y0,width,height)
	
	Display/K=2/N=graphBeforeAfter/W=(x0,y0,x0+width,y0+height) as "Cut before and after each stimulus"
	ControlBar/T 22
	ControlBar/L kCtrlWidth
	
	// Load label
	WAVE/T wT=:CoreCache:wTStimResPair
	
	if (DataFolderExists(":Edited"))
		DFREF dfrTrace=:Edited
	else
		DFREF dfrTrace=GetDataFolderDFR()
	endif
	
	String axisName
	Variable n=2		// number of graphs
	Variable pad=0.2/n
	Variable i,y1,y2
	for (i=0;i<n;i+=1)
		axisName="customLeft"+num2str(i)
		
		AppendToGraph/L=$axisName dfrTrace:$wT[i]
		
		// stimuli bottom, trace top
		y1=1/n*i	// low
		y2=1/n*(i+1)	// high
		
		// add padding
		if (y1)
			y1+=pad
		endif
		ModifyGraph lblPos($axisName)=70,freePos($axisName)=0,axisEnab($axisName)={y1,y2}
		ModifyGraph lowtrip($axisName)=0.001
		
		Label $axisName wT[i]
	endfor
	
	WAVE w=dfrTrace:$wT[1]	// trace
	
	ModifyGraph rgb=(0,39168,0)
	
	SetAxis bottom wOnLoc[0]-sBefore,wOnLoc[0]+sAfter
	
	TitleBox titleSpike2BeforeAfterEdit title="Selection will be permanent",pos={1,3}
	TitleBox titleSpike2BeforeAfterEdit frame=0
	
	String ctrlTitle="Range ("+WaveUnits(w,0)+")"
	SetVariable setvarSpike2RangeFrom title=ctrlTitle,pos={150,3},size={85,kCtrlHeight}	// custom width
	SetVariable setvarSpike2RangeFrom proc=SetVarProcSpike2EditBefore
	SetVariable setvarSpike2RangeFrom value=_NUM:-sBefore,limits={-inf,0,0.1},live=1
	SetVariable setvarSpike2RangeFrom help={"Enter a value to adjust the left range"}
	
	SetVariable setvarSpike2RangeTo title="-",pos={237,3},size={47,kCtrlHeight}	// custom width
	SetVariable setvarSpike2RangeTo proc=SetVarProcSpike2EditAfter
	SetVariable setvarSpike2RangeTo value=_NUM:sAfter,limits={0,inf,0.1},live=1
	SetVariable setvarSpike2RangeTo help={"Enter a value to adjust the right range"}
	
	Button buttonSpike2BeforeAfterCut title="Cut",pos={300,0}
	Button buttonSpike2BeforeAfterCut proc=ButtonProcSpike2BeforeAfterCut
	Button buttonSpike2BeforeAfterCut fColor=(0,0,65280)
	Button buttonSpike2BeforeAfterCut valueColor=(65535,65535,65535)
	Button buttonSpike2BeforeAfterCut help={"Cut before and after each stimulus"}
	
	Button buttonSpike2BeforeAfterCancel title="Cancel",pos={350,0}
	Button buttonSpike2BeforeAfterCancel proc=ButtonProcSpike2BeforeAfterQuit
	
	String/G :Cache:gWarning
	SVAR gWarning=:Cache:gWarning
	gWarning=""
	TitleBox titleWarning title="No problemo",pos={200,24},frame=0,disable=1,variable=gWarning
	TitleBox titleWarning fColor=(17408,17408,17408),labelBack=(65280,65280,32768)
	
	SetVariable setvarStimNumber title="Stim",pos={1,129},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarStimNumber bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2BeforeAfterStim
	SetVariable setvarStimNumber value=_NUM:1,limits={1,numpnts(wOnLoc),1},live=1
	SetVariable setvarStimNumber help={"Enter a stimulus number"}
	
	hiroSpike2BeforeAfterCheck(sBefore,sAfter)
	
	PauseForUser graphBeforeAfter
	
End


Function hiroSpike2TrialAvgData()
	// show data in a matrix
	
	// name of the analyzed trace
	WAVE/T wTStimResPair=:CoreCache:wTStimResPair
	String nameTrace=wTStimResPair[1]
	
	// make a title for the table
	String nameDF=GetDataFolder(0)
	nameDF=ReplaceString("'",nameDF,"")	// remove single quotes
	
	String strTitle=nameTrace + ": " + nameDF
	
	Edit/K=1 as strTitle
	
	WAVE w=$nameTrace
	String xUnits=WaveUnits(w,0)	// e.g., "s"
	String yUnits=WaveUnits(w,1)	// e.g., "mV"
	
	NVAR gNormBase=:Cache:gNormBase
	SVAR gNormBaseUnits=:Cache:gNormBaseUnits
	if (gNormBase)
		if (cmpstr(gNormBaseUnits,""))
			yUnits=gNormBaseUnits
		else
			yUnits="a.u."
		endif
	endif
	
	// append columns
	hiroSpike2AddCol("wStim","Stimulus")
	hiroSpike2AddCol("wIncluded","Included")
	//hiroSpike2AddCol("wAnalyzed","Analyzed")
	hiroSpike2AddCol("wRealOnX","Stim On ("+xUnits+")")
	hiroSpike2AddCol("wRealOffX","Stim Off ("+xUnits+")")
	hiroSpike2AddCol("wSmooth","Gaussian filter (n)")
	hiroSpike2AddCol("wBaseY","Baseline ("+yUnits+")")
	hiroSpike2AddCol("wLatency","Latency ("+xUnits+")")
	hiroSpike2AddCol("wRiseTime","Rise time ("+yUnits+"/"+xUnits+")")
	hiroSpike2AddCol("wR2","r^2")
	hiroSpike2AddCol("wLatency2Peak","Time to peak ("+xUnits+")")
	hiroSpike2AddCol("wAmplitudeY","Peak ampl ("+yUnits+")")
	hiroSpike2AddCol("wPercent","%-amplitude")
	hiroSpike2AddCol("wPercentDuration","%-amp duration ("+xUnits+")")
	hiroSpike2AddCol("wRealFootX","Foot ("+xUnits+")")
	hiroSpike2AddCol("wRealLeftX","Left ("+xUnits+")")
	hiroSpike2AddCol("wRealPeakX","Peak ("+xUnits+")")
	hiroSpike2AddCol("wRealRightX","Right ("+xUnits+")")
	
End


Function hiroSpike2AddCol(nameW,str)
	
	String nameW
	String str
	
	DFREF dfrSaved=GetDataFolderDFR()
	
		SetDataFolder :IO
		WAVE wIO=$nameW
		AppendToTable wIO
		ModifyTable title(wIO)=str
	
	SetDataFolder dfrSaved
	
End


Function DoTrialAvg()
	// Auto-detect stimulus onset, then align response and average
	
//	//? version restriction: prevent multiple execution
//	if (DataFolderExists(":IO"))
//		DoAlert/T="Warning!" 2, "You have already analyzed once.\rRepeated analysis is untested and unsupported in this version.\rIt may corrupt data or cause erroneous results.\r\rAre you sure you want to analyze anyways?"
//		if (V_flag>1)
//			Print "User canceled procedure"
//			Abort
//		else
//			Print "User opts to repeat Average trials analysis (unsupported in this version)."
//			Print "User assumes risk of data corruption and/or erroneous results."
//		endif
//	endif
	
	// If this is still in the Edit Mode, click done and return to Overview
	String nameTopGraph=WinName(0,1)
	if (!cmpstr(nameTopGraph,"GraphSpike2Step1_1"))
		// force exit Edit Mode
		hiroSpike2EditDone()
	endif
	
	// Step -1: save the original waves, if needed
	Variable flag=hiroSpike2SaveBeforeStep2()
	
	if (!flag)
		// This function has already been run at least once.
		// Create a new DF with the original waves before proceeding.
		hiroSpike2Step2CleanSlate()
	endif
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	String nameDF=GetDataFolder(0)
	
	// Optional: has the traces been edited in Edit Mode?
	Variable isEdited
	if (DataFolderExists(":EditCache"))
		isEdited=1
	endif
	
	// Step 0: pick 2 waves
	String nameStim="tment"		// default, if available
	String nameTrace="CCmode"	// default, if available
	
	// Optional: recall from cache if available
	WAVE/T wT=:CoreCache:wTStimResPair
	if (WaveExists(wT))
		if (strlen(wT[0])>0)
			nameStim=wT[0]
			nameTrace=wT[1]
		endif
	endif
	
	// Load list of waves
	String list
	SVAR/Z gOrigWaveList=:CoreCache:gOrigWaveList
	if (SVAR_Exists(gOrigWaveList))
		list=gOrigWaveList
	else
		list=WaveList("*",";","")
	endif
	
	//Prompt nameStim, "Stimulus:", popup, WaveList("*",";","")
	//Prompt nameTrace, "Trace:", popup, WaveList("*",";","")
	Prompt nameStim, "Stimulus:", popup, list
	Prompt nameTrace, "Trace:", popup, list
	DoPrompt/HELP="Select a wave for stimulus and response.  Tab-key toggles between the two fields." "Select waves",nameStim,nameTrace
	if (V_flag == 1)
		Print "User Canceled Procedure"
		Abort	//quit if cancel button was clicked
	else
		if (cmpstr(nameStim,"_none_")==0 || cmpstr(nameTrace,"_none_")==0)
			DoAlert/T="Waves not selected" 0, "You need two waves.\rTry again."
			Abort
		endif
	endif
	
	// Save a text wave containing the selected stimulus-trace pair (used as cache when this function is called next)
	wT[0]=nameStim
	wT[1]=nameTrace
	
	// Optional step: Make a library of baseline values by activity isolation
	TrialAvgStep0(nameTrace)
	
	// Step1: Detect stimulus onset
	TrialAvgStep1(nameStim,nameTrace)
	
	// Step1a: Is this a train of stimuli?
	Variable nTrains=TrialAvgStep1a()
	
	String str="Do you want to group by trains?\r\r"+num2str(nTrains)+" trains detected"
	Variable/G groupByTrain=0
	if (nTrains)
		DoAlert/T="This looks like a train of pulses..." 2,str
		if (V_flag==1)
			// yes. align by train
			groupByTrain=1
			hiroSpike2ConvertPulseToTrain()
			Print "Grouped by trains,",num2str(nTrains),"total"
		elseif (V_flag==3)
			// cancel
			Print "User canceled procedure"
			Abort
		endif
	endif
	
	// Find stimulus duration (should do this on every single one, but assume it's the same for all)
	WAVE wOnLoc
	WAVE wOffLoc
	
	Variable nStim=numpnts(wOnLoc)
	Variable sStimDuration=wOffLoc[0]-wOnLoc[0]
	
	Variable sBefore=ksBefore		// init, will be refined below
	Variable sAfter=ksAfter
	
	hiroSpike2BeforeAfterRefine(sBefore,sAfter,sStimDuration)
	
	// Load user-defined before and after
	WAVE wBeforeAfter=:CoreCache:wBeforeAfter
	sBefore=wBeforeAfter[0]
	sAfter=wBeforeAfter[1]
	
	// Step 2: Trim the response based on the location of the stimulus
	TrialAvgStep2(sBefore,sAfter,$nameTrace)
	
	AutoPositionWindow/E/M=1
	
	SetDataFolder dfrSaved
	
	// Step 2a: Save the original Trials DF. It will be used when smoothing
	DuplicateDataFolder :Trials,:Trials_Orig
	
	// Step 2b: Add controls
	ControlBar/L kCtrlWidth
	
	PopupMenu popupSpike2PeakPolarity pos={1,1},size={kCtrlWidth,kCtrlHeight}
	PopupMenu popupSpike2PeakPolarity proc=PopMenuProcSpike2PeakPolarity
	PopupMenu popupSpike2PeakPolarity value="Positive;Negative"
	PopupMenu popupSpike2PeakPolarity help={"Select the polarity for peak-detection"}
	
	WAVE w=:Trials:w0
	Variable x1=leftx(w)
	Variable x2=rightx(w)
	
	String xUnits=WaveUnits(w,0)
	
	String ctrlTitle	// for custom title
	SetVariable setvarSpike2PeakLoc title="Peak",pos={72,3},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarSpike2PeakLoc bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2PeakLoc
	SetVariable setvarSpike2PeakLoc value=_NUM:0,limits={x1,x2,0.01},live=1,userData="NaN"
	SetVariable setvarSpike2PeakLoc help={"Enter a value to adjust peak position in "+xUnits}
	
	SetVariable setvarSpike2FootLoc title="Foot",pos={140,3},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarSpike2FootLoc bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2FootLoc
	SetVariable setvarSpike2FootLoc value=_NUM:0,limits={x1,x2,0.01},live=1
	SetVariable setvarSpike2FootLoc help={"Enter a value to adjust the foot marker position in "+xUnits}
	
	// Alternative left and right (jumpers)
	Button buttonSpike2LeftLoc title="\\W646",pos={217,1},size={20,20},userData="NaN"
	Button buttonSpike2LeftLoc proc=ButtonProcSpike2LeftLoc,valueColor=(16384,28160,65280)
	Button buttonSpike2LeftLoc help={"Jump to other possible positions, if any"}
	
	Button buttonSpike2RightLoc title="\\W649",pos={237,1},size={20,20},userData="NaN"
	Button buttonSpike2RightLoc proc=ButtonProcSpike2RightLoc,valueColor=(16384,28160,65280)
	Button buttonSpike2RIghtLoc help={"Jump to other possible positions, if any"}
	
	ctrlTitle="Range"
	SetVariable setvarSpike2RangeFrom title=ctrlTitle,pos={265,3},size={70,kCtrlHeight}	// custom width
	SetVariable setvarSpike2RangeFrom proc=SetVarProcSpike2RangeFrom
	SetVariable setvarSpike2RangeFrom value=_NUM:0,limits={x1,0,0.1},live=1
	SetVariable setvarSpike2RangeFrom help={"Enter a value to adjust the left range in "+xUnits}
	
	SetVariable setvarSpike2RangeTo title="-",pos={337,3},size={46,kCtrlHeight}	// custom width
	SetVariable setvarSpike2RangeTo proc=SetVarProcSpike2RangeTo
	SetVariable setvarSpike2RangeTo value=_NUM:x2,limits={0,x2,0.1},live=1
	SetVariable setvarSpike2RangeTo help={"Enter a value to adjust the right range in "+xUnits}
	
	Button buttonSpike2Data title="Data",pos={393,1},size={35,20}
	Button buttonSpike2Data proc=ButtonProcSpike2AvgTrialsData,fColor=(0,15872,65280)
	Button buttonSpike2Data valueColor=(65535,65535,65535),help={"Show data"}
	
	SetVariable setvarSpike2Smooth title="Smth",pos={1,26},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarSpike2Smooth bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2Smooth
	SetVariable setvarSpike2Smooth value=_NUM:0,limits={0,32767,5},live=1
	SetVariable setvarSpike2Smooth help={"De-noise this trace using binomial (Gaussian) smoothing"}
	
	// when the y-value is small, the normal increments of 1 would not work for the "limits".
	// So, the baseline will be expressed as a fraction between 0 to 1, which will then
	// be converted to actual baseline value later.
	SetVariable setvarSpike2Baseline title="Base",pos={1,66},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarSpike2Baseline bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2Baseline
	SetVariable setvarSpike2Baseline value=_NUM:0,limits={0,1,0.01},live=1
	SetVariable setvarSpike2Baseline help={"This is the baseline expressed as a fraction between 0 and 1. This will be used for calculating %-amplitude duration"}
	
	SetVariable setvarSpike2Percent title="%",pos={1,86},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarSpike2Percent bodyWidth=kCtrlBodyWidth,proc=SetVarProcSpike2Percent
	SetVariable setvarSpike2Percent value= _NUM:50,limits={0,100,5},live=1
	SetVariable setvarSpike2Percent help={"Enter the desired percentage for %-amplitude duration"}
	
	SetVariable setvarStimNumber title="Stim",pos={1,129},size={kCtrlWidth,kCtrlHeight}
	SetVariable setvarStimNumber bodyWidth=kCtrlBodyWidth,proc=SetVarProcStimNumber
	SetVariable setvarStimNumber value=_NUM:0,limits={0,nStim,1},live=1
	SetVariable setvarStimNumber help={"Enter a stimulus number. Enter 0 to see all the responses superimposed"}
	
	Button buttonSpike2StimBack title="<",pos={1,146},size={32,20},disable=2
	Button buttonSpike2StimBack proc=ButtonProcSpike2StimBack,help={"Previous stimulus"}
	
	Button buttonSpike2StimNext title=">",pos={33,146},size={32,20}
	Button buttonSpike2StimNext proc=ButtonProcSpike2StimNext,help={"Next stimulus"}
	
	CheckBox checkIncludeThisResponse title="Include",pos={1,167},disable=1
	CheckBox checkIncludeThisResponse proc=CheckProcIncludeThisResponse,value=0
	CheckBox checkIncludeThisResponse userData=PossiblyQuoteName(nameDF)		// keep track of DF name to update the right one
	CheckBox checkIncludeThisResponse help={"Check to include this response in the analysis"}
	
	SVAR gWarning=:Cache:gWarning
	gWarning=""
	TitleBox titleWarning title="No problemo",pos={200,24},frame=0,variable=gWarning
	TitleBox titleWarning fColor=(17408,17408,17408),labelBack=(65280,65280,32768)
	
	// Init: Hide select controls for now
	hiroSpike2HideControls(1)
	
	// Step 2b: Add peak markers, etc. to the graph
	SetDataFolder dfrSaved
	
	Duplicate w,wMarkerPeak,wMarkerLeft,wMarkerRight,wMarkerFoot,wMarkerFit
	
	wMarkerPeak=NaN
	wMarkerLeft=NaN
	wMarkerRight=NaN
	wMarkerFoot=NaN
	wMarkerFit=NaN
	
	AppendToGraph wMarkerPeak,wMarkerLeft,wMarkerRight,wMarkerFoot,wMarkerFit
	ModifyGraph mode(wMarkerPeak)=3,marker(wMarkerPeak)=8,msize(wMarkerPeak)=5
	ModifyGraph rgb(wMarkerPeak)=(16384,28160,65280)
	ModifyGraph mode(wMarkerLeft)=3,marker(wMarkerLeft)=46,msize(wMarkerLeft)=5
	ModifyGraph rgb(wMarkerLeft)=(16384,28160,65280)
	ModifyGraph mode(wMarkerRight)=3,marker(wMarkerRight)=49,msize(wMarkerRight)=5
	ModifyGraph rgb(wMarkerRight)=(16384,28160,65280)
	ModifyGraph mode(wMarkerFoot)=3,marker(wMarkerFoot)=21,msize(wMarkerFoot)=5
	ModifyGraph rgb(wMarkerFoot)=(16384,28160,65280)
	ModifyGraph lsize(wMarkerFit)=1.5,lstyle(wMarkerFit)=2
	
	hiroSpike2HideMarkers(1)
	
	// Step 2c: Create IO for data
	hiroSpike2InitIO()
	
	// Step 2d: Create cache
	Variable/G :Cache:iStim=-1		// current stim number (>10x faster than reading off ControlInfo)
	Variable/G :Cache:isZeroed
	Variable/G :Cache:iStimprev=-1	// previous stim number (need for :IO:wAnalyzed feature)
	Variable/G :Cache:optimizeLeft=1
	
	// Step 2e: Create Warning code
	Make/O/N=4 :Cache:wWarningP
	Make/O/T/N=4 :Cache:wWarningT /WAVE=wWarningT
	
	wWarningT[0]="Left marker not found; foot missing."
	wWarningT[1]="Right marker not found."
	wWarningT[2]="Foot not found; rise time missing."
	wWarningT[3]="Line fits poorly; rise time not saved."
	
	// Step 2f: reapply smooth if it was previously used in the Edit Mode
	Variable numSmooth
	
	// save a global variable with the norm factor for quick access.
	// this is simpler method because this value is a constant
	Variable/G :Cache:gNormBase
	String/G :Cache:gNormBaseUnits
	NVAR gNormBase=:Cache:gNormBase
	SVAR gNormBaseUnits=:Cache:gNormBaseUnits
	if (isEdited)
		numSmooth=hiroSpike2CheckEditCache(nameTrace,1)
		
		// get normalization factor, if needed. This will be applied after smoothing.
		gNormBase=hiroSpike2CheckEditCache(nameTrace,2)
		gNormBaseUnits=hiroSpike2CheckEditCacheStr(nameTrace,3)
		
		// if edited, reapply smooth filter to all the traces in Trials DF
		if (numSmooth)
			hiroSpike2SmoothAllTrials(numSmooth)	// this must execute after IO is init
		endif
		
	endif
	
	// Step 3: // Correct baseline offset
	DoUpdate
	
	NVAR isZeroed=:Cache:isZeroed
	
	DoAlert 1, "Do you want the baseline to be zeroed?"
	if (V_flag==1)
		TrialAvgStep3($nameTrace)
		
		isZeroed=1
		Print "Baseline offset corrected"
	endif
	
	// Step 4: Make a matrix version of the traces
	TrialAvgStep4()
	
	// Step 5: Graph the result
	WAVE mean_response
	WAVE ste_response
	TrialAvgStep5(sStimDuration,mean_response,ste_response,nameTrace)
	
	// Step 6: auto-detect polarity by analyzing the mean
	hiroSpike2DetectPolarity(0,mean_response)
	
	AutoPositionWindow/E
	
	hiroSpike2EditButtonEnable()
	
End


Function hiroSpike2EditButtonEnable()
	
	// allow editing in overview
	ControlInfo/W=GraphSpike2Step1 buttonSpike2Edit
	if (V_disable)
		Button buttonSpike2Edit disable=0,win=GraphSpike2Step1
	endif
	
End


Function hiroSpike2DetectPolarity(i,w)
	
	Variable i	// zero-based stim number
	WAVE w
	
	WAVE wBeforeAfter=:CoreCache:wBeforeAfter
	Variable sBefore=wBeforeAfter[0]
	
	Duplicate/FREE/R=(-sBefore,0) w,wFree
	Variable baseY=StatsMedian(wFree)
	Variable minY=WaveMin(w)
	Variable maxY=WaveMax(w)
	
	Variable positiveAmp=abs(maxY-baseY)
	Variable negativeAmp=abs(baseY-minY)
	
	WAVE wPolarity=:IO:wPolarity
	if (positiveAmp>negativeAmp)
		wPolarity[i]=1
	else
		wPolarity[i]=2
	endif
	
End


Function hiroSpike2CheckEditCache(nameTrace,mode)
	// is this trace edited in Edit Mode? If so, return the value
	
	String nameTrace
	Variable mode	// 0 for invert, 1 for smooth, 2 for normalize
	
	Variable value
	
	if (mode==2)
		WAVE wC=:EditCache:wNormBase
	elseif (mode==1)
		WAVE wC=:EditCache:wSmooth
	else
		WAVE wC=:EditCache:wInvert
	endif
	
	WAVE/T wT=:EditCache:wTNameW
	
	Extract/FREE/INDX wT,wINDX,!cmpstr(wT,nameTrace)
	
	value=wC[wINDX[0]]
	
	return value
	
End


Function/S hiroSpike2CheckEditCacheStr(nameTrace,mode)
	// is this trace edited in Edit Mode? If so, return the string
	
	String nameTrace
	Variable mode	// 3 for normalized units
	
	String str
	
	if (mode==3)
		WAVE/T wC=:EditCache:wNormBaseUnits
	endif
	
	WAVE/T wT=:EditCache:wTNameW
	
	Extract/FREE/INDX wT,wINDX,!cmpstr(wT,nameTrace)
	
	str=wC[wINDX[0]]
	
	return str
	
End


Function ButtonProcSpike2AvgTrialsData(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2SwitchDF()
			
			hiroSpike2TrialAvgData()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2InitIO()
	// Create IO for data and controls
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	WAVE wOnLoc
	WAVE wOffLoc
	Variable nStim=numpnts(wOnLoc)
	
	NewDataFolder/S :IO
	
	DFREF dfr=GetDataFolderDFR()
	
	// make waves to store measured data
	Make/N=(nStim) wStim,wIncluded,wAnalyzed,wPolarity,wSmooth
	Make/N=(nStim) wBaseFrac,wBaseY,wPercent,wThreshY
	Make/N=(nStim) wPeakX,wPeakP,wPeakY
	Make/N=(nStim) wFootX,wFootP,wFootY
	Make/N=(nStim) wLeftX,wLeftP,wLeftY
	Make/N=(nStim) wRightX,wRightP,wRightY
	Make/N=(nStim) wRangeFrom,wRangeTo
	
	// Real timeseries values
	Make/N=(nStim) wRealOnX,wRealOffX
	Make/N=(nStim) wRealPeakX,wRealFootX
	Make/N=(nStim) wRealLeftX,wRealRightX
	Make/N=(nStim) wRealRangeFrom,wRealRangeTo
	
	// store calculated data
	Make/N=(nStim) wAmplitudeY,wPercentDuration,wLatency
	Make/N=(nStim) wRiseTime,wR2,wLatency2Peak
	
	// init with NaN
	Variable i
	for(i=0;i<CountObjectsDFR(dfr,1);i+=1)
		WAVE w=WaveRefIndexed("",i,4)
		w=NaN
	endfor
	
	// Special init
	WAVE wStim
	wStim=x+1
	
	WAVE wIncluded
	wIncluded=1
	
	// copy stimulus location (used for calculating real x-position for peaks, etc.)
	WAVE wRealOnX
	WAVE wRealOffX
	wRealOnX=wOnLoc
	wRealOffX=wOffLoc
	
	SetDataFolder dfrSaved
	
End


Function TrialAvgStep1(nameStimW,nameRespW)
	// Find time of stimulus onset (use PulseStats method)
	
	String nameStimW,nameRespW
	
	// Disable Edit button
	ControlInfo/W=GraphSpike2Step1 buttonSpike2Edit
	if (!V_disable)
		Button buttonSpike2Edit disable=2
	endif
	
	WAVE wStim=$nameStimW		// Stimulus
	WAVE wTrace=$nameRespW		// LFP, etc.
	
	Variable off=WaveMin(wStim)
	Variable on=WaveMax(wStim)
	
	// Find time of stimulus onset (use PulseStats method)
	PulseStats/P/L=(off,on)/Q wStim
	
	Variable pntOn,sOn
	Variable pntOff,sOff
	
	Variable nMaxStim=numpnts(wStim)/2	// assume that the number of stimuli is less than half its sampling size
	
	Make/O/N=(nMaxStim) wOnLoc
	Make/O/N=(nMaxStim) wOffLoc
	
	WAVE wOnLoc
	WAVE wOffLoc
	
	// initialize
	wOnLoc=-1
	wOffLoc=-1
	
	Variable i	// counts the number of detected stimuli
	
	do
		if (V_flag!=2)	// a pulse was found
			if (V_PulsePolarity==1)	// pulse is increasing at the onset
				pntOn=round(V_PulseLoc1)		// this is the location of the onset
				pntOff=round(V_PulseLoc2)		// this is the location of the offset
				
				// converting from point numbers is more precise
				sOn=pnt2x(wStim,pntOn)
				sOff=pnt2x(wStim,pntOff)
				
				// Save the values as wave.  Save in sec because traces may have different sampling freq (e.g., VCmode)
				wOnLoc[i]=sOn
				wOffLoc[i]=sOff
				
				i+=1
			else
				// prevent infinite loop
				pntOff+=1	
			endif
			// Find the next stimulus
			PulseStats/P/R=[pntOff]/L=(off,on)/Q wStim
		else
			// stimulus does not exist
			break
		endif
	while(i<nMaxStim)
	
	if (i==nMaxStim)
		String strErr="Only up to "+num2str(nMaxStim)+" can be detected by the program.\rRestart, trim data, then try again."
		DoAlert/T="Error: maximum detectable stimuli reached" 0, strErr
		Print "Only up to",nMaxStim,"stimuli was detected by the program"
		Print "Procedure canceled due to an error"
		Abort
	endif
	
	Extract/O wOnLoc,wOnLoc,wOnLoc>-1
	Extract/O wOffLoc,wOffLoc,wOffLoc>-1
	
	Variable n=numpnts(wOnLoc)
	Print n,"stimli detected!"
	
	// Visually confirm the result
//	Make/O/N=(n) wStimOn
//	WAVE wStimOn
//	
//	AppendToGraph wStimOn vs wOnLoc
//	ModifyGraph mode(wStimOn)=3,marker(wStimOn)=10
//	ModifyGraph rgb(wStimOn)=(0,0,0)
//	ModifyGraph offset(wStimOn)={0,-5}
	
End


Function TrialAvgStep1a()
	// Analyze stimulus pattern and detect trains, if any
	
	WAVE wOnLoc
	
	Variable n=numpnts(wOnLoc)
	Make/FREE/N=(n-1) wOnInter
	//WAVE wOnInter
	Make/O/N=(n-1) wIntervalLoc
	WAVE wIntervalLoc
	
	wIntervalLoc=-1
	
	Variable i
	for (i=0;i<n-1;i+=1)
		wOnInter[i]=round(wOnLoc[i+1]-wOnLoc[i])
	endfor
	
	// there should be peaks in wOnInter if trains exist
	Variable yMin=WaveMin(wOnInter)
	Variable yMax=WaveMax(wOnInter)
	Variable thresh=(yMax-yMin)/2
	
	if (!thresh)
		// no train found
		return 0
	endif
	
	//Print "thresh",thresh
	
	PulseStats/P/L=(yMin,yMax)/Q wOnInter
	
	Variable pntInterval
	
	i=0	// init
	wIntervalLoc[i]=0	// include the first one automatically
	i+=1
	do
		if (V_flag!=2)	// a pulse was found
			if (V_PulsePolarity==1)	// pulse is increasing at the onset
				pntInterval=round(V_PulseLoc2)		// this is the location of the onset
				
				// Save the values as wave.  Save in sec because traces may have different sampling freq (e.g., VCmode)
				wIntervalLoc[i]=pntInterval
				
				i+=1
			else
				// prevent infinite loop
				pntInterval+=1
			endif
			// Find the next stimulus
			PulseStats/P/R=[pntInterval+1]/L=(yMin,yMax)/Q wOnInter
		else
			// stimulus does not exist
			break
		endif
	while(i<n-1)
	
	Extract/O wIntervalLoc,wIntervalLoc,wIntervalLoc>-1
	
	i=numpnts(wIntervalLoc)
	
	//Print i,"trains detected!"
	
	return i
	
End


Function hiroSpike2ConvertPulseToTrain()
	// User requested to align responses to a train of pulses.  Convert wOnLoc based on pnt onset found in wIntervalLoc
	
	WAVE wOnLoc
	WAVE wOffLoc
	WAVE wIntervalLoc
	
	Variable n=numpnts(wIntervalLoc)
	
	Make/O/N=(n) wTrainOnLoc,wTrainOffLoc
	
	WAVE wTrainOnLoc
	WAVE wTrainOffLoc
	
	Variable pnt
	
	Variable i
	for (i=0;i<n;i+=1)
		pnt=wIntervalLoc[i]
		wTrainOnLoc[i]=wOnLoc[pnt]
		
		if (i+1<n)
			pnt=wIntervalLoc[i+1]-1
			wTrainOffLoc[i]=wOffLoc[pnt]
		else
			wTrainOffLoc[i]=wOffLoc[numpnts(wOffLoc)-1]
		endif
	endfor
	
	// Save a copy of the wOnLoc and wOffLoc
	Duplicate/O wOnLoc,wPulseOnLoc
	Duplicate/O wOffLoc,wPulseOffLoc
	
	// Destroy and replace wOnLoc and wOffLoc
	Duplicate/O wTrainOnLoc,wOnLoc
	Duplicate/O wTrainOffLoc,wOffLoc
	
End


Function TrialAvgStep2(sBefore,sAfter,wTrace)
	// Trim the response based on the location of the stimulus
	
	Variable sBefore
	Variable sAfter
	WAVE wTrace
	
	String nameW
	
	WAVE wOnLoc
	
	Variable n=numpnts(wOnLoc)
//	Make/O/N=(n) selROI
//	WAVE selROI
//	selROI=1	// initialize
	
	// Optional: check if the user inverted this trace
	Variable isInverted
	if (DataFolderExists(":EditCache"))
		isInverted=hiroSpike2CheckEditCache(NameOfWave(wTrace),0)
	endif
	
	String nameDF = GetDataFolder(0)
	nameDF=ReplaceString("'",nameDF,"")
	
	NewDataFolder/O/S Trials
	
	Display as NameOfWave(wTrace)+": "+nameDF
	
	Variable sStart
	Variable sEnd
	
	Variable i
	for(i=0;i<n;i+=1)
		nameW="w"+num2str(i)
		
		sStart=wOnLoc[i]-sBefore
		sEnd=wOnLoc[i]+sAfter
		
		Duplicate/O/R=(sStart,sEnd) wTrace,$nameW
		
		WAVE w=$nameW
		
		if (isInverted)
			MultiThread w*=-1
		endif
		
		// force this to start from seconds before onset (onset is 0 s)
		SetScale/P x -sBefore,deltax(wTrace),WaveUnits(wTrace,0), w
		
		AppendToGraph $nameW
		ModifyGraph rgb($nameW)=(34952,34952,34952)
	endfor
	
	ModifyGraph lowTrip(left)=0.001,standoff=0
	
	String listTrace=TraceNameList("", ";", 1)
	Variable/G ::nStim=ItemsInList(listTrace, ";")
	
End


Function TrialAvgStep3(wFull)
	// Correct baseline offset
	
//	Variable sBefore	// same as in Step2
	WAVE wFull		// e.g., CaRec1
	
	NVAR nStim
	
	String nameW
	
	Variable baseline
	
	//SetDataFolder :Trials
	
	Variable i
	for(i=0;i<nStim;i+=1)
		nameW="w"+num2str(i)
		
		WAVE w=:Trials:$nameW
		WAVE wOrig=:Trials_Orig:$nameW
		
		baseline=hiroSpike2DetectBaseline(i,w,wFull)
		
		//baseline=mean(w,-sBefore,0)
		//Duplicate/FREE/R=(-sBefore,0) w,wFree
		//baseline=StatsMedian(wFree)
		
		// Subtract baseline
		MultiThread w-=baseline
		MultiThread wOrig-=baseline
	endfor
	
	//SetDataFolder ::
	
End


Function TrialAvgStep4()
	// Make a matrix version of the traces
	// this function will be called repeatedly with user control
	
	WAVE wIncluded=:IO:wIncluded
	
	SetDataFolder :Trials
	
	String nameW
	
//	NVAR nStim=::nStim
	
	//WAVE selROI=::selROI
	//Extract/FREE/INDX selROI,wINDX,selROI==1
	Extract/FREE/INDX wIncluded,wINDX,wIncluded==1
	Variable n=numpnts(wINDX)
	//Print "n=",n
	
	WAVE w=w0
//	Make/FREE/D/N=(numpnts(w),nStim) M
	Make/FREE/D/N=(numpnts(w),n) M
	
	SetScale/P x leftx(w),deltax(w),WaveUnits(w,0), M
	SetScale d 0,0,WaveUnits(w,-1), M
	
	String listTraces=TraceNameList("",";",1)	// this list may contain other traces such as "mean_response", etc.
	
	// Remove extraneous waves from the list
	String listExtra="wMarkerPeak;wMarkerLeft;wMarkerRight;wMarkerFoot;wMarkerFit;mean_response;"
	
	listTraces=RemoveFromList(listExtra,listTraces)
	
	Variable i
//	for(i=0;i<nStim;i+=1)
	for(i=0;i<n;i+=1)
		//nameW="w"+num2str(i)
		nameW=StringFromList(i,listTraces,";")
		//if (cmpstr(nameW,"mean_response"))
			// skip this wave from being included in the average
			WAVE w=$nameW
			M[][i]=w[p]
		//endif
	endfor
	
	// Average of all traces
	MatrixOp/O ::mean_response=sumRows(M)/numCols(M)
	
	// MatrixOp doesn't have "varRows" so transpose first
	MatrixTranspose M
	
	MatrixOp/S/FREE M_variance=varCols(M)
	
	MatrixTranspose M_variance
	
//	M_variance=sqrt(M_variance)/sqrt(nStim)
	M_variance=sqrt(M_variance)/sqrt(n)
	
	SetDataFolder ::
	
	Duplicate/O M_variance,ste_response
	
	WAVE mean_resp=mean_response
	WAVE ste_resp=ste_response
	SetScale/P x leftx(w),deltax(w),WaveUnits(w,0), mean_resp,ste_resp
	SetScale d 0,0,WaveUnits(w,-1), mean_resp,ste_resp
	
	// Create edges based on the SEM
	Duplicate/O mean_resp, hiEdge,loEdge
	
	WAVE hiEdge
	WAVE loEdge
	
	hiEdge+=ste_resp
	loEdge-=ste_resp
	
End


Function TrialAvgStep5(sDuration,mean_Trace,ste_Trace,nameTrace)
	// Graph the result
	
	Variable sDuration
	WAVE mean_Trace
	WAVE ste_Trace
	String nameTrace
	
	WAVE hiEdge
	WAVE loEdge
	
	// Show mean in superimposed raw traces
	AppendToGraph mean_Trace
	
	String nameDF = GetDataFolder(0)
	nameDF=ReplaceString("'",nameDF,"")
	
	String nameGraph=WinName(0,1)+"_mean"
	
	Display/N=$nameGraph hiEdge,loEdge as nameTrace+": "+nameDF+" (Mean ± SEM)"
	ModifyGraph lsize=0,mode(hiEdge)=7,hbFill(hiEdge)=5,toMode(hiEdge)=1
	ModifyGraph lowTrip(left)=0.001
	AppendToGraph mean_Trace
	
	// Show stimulus onset
	TrialAvgAddStimulusToGraph(sDuration,loEdge)
	
End


Function TrialAvgAddStimulusToGraph(sDuration,w)
	
	Variable sDuration
	
	WAVE w
	
	Variable offsetY=WaveMin(w)
	offsetY+=0.1*offsetY	// move down 10%
	
	NVAR groupByTrain
	if (groupByTrain)
		hiroSpike2DrawTrainOfPulses(offsetY)
	else
		SetDrawEnv xcoord= bottom,ycoord= left,linethick= 3.00
		DrawLine 0,offsetY,sDuration,offsetY
	endif
	
	// Hide bottom axis
	ModifyGraph noLabel(bottom)=2,axThick(bottom)=0
	
End


Function hiroSpike2DrawTrainOfPulses(offsetY)
	
	Variable offsetY
	
	WAVE wTrainOnLoc
	WAVE wTrainOffLoc
	
	WAVE wPulseOnLoc
	WAVE wPulseOffLoc
	
	Variable sTrainStart=wTrainOnLoc[0]
	Variable sTrainEnd=wTrainOffLoc[0]
	
	Variable sPulseStart,sPulseEnd
	
	Variable i
	do
		sPulseStart=wPulseOnLoc[i]-sTrainStart
		sPulseEnd=wPulseOffLoc[i]-sTrainStart
		
		SetDrawEnv xcoord= bottom,ycoord= left,linethick= 3.00
		DrawLine sPulseStart,offsetY,sPulseEnd,offsetY
		
		i+=1
	while(wPulseOffLoc[i-1]<=sTrainEnd)
	
End


Function PopMenuProcSpike2PeakPolarity(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1		// zero-based stim number
			NVAR i=:Cache:iStim
			
			// Save
			WAVE wPolarity=:IO:wPolarity
			wPolarity[i]=popNum
			
			// Modify angle of foot marker depending on polarity
			if (popNum==kPositive)
				ModifyGraph marker(wMarkerFoot)=20
			else
				ModifyGraph marker(wMarkerFoot)=21
			endif
			
			hiroSpike2DetectPeak(i)
			
			hiroSpike2DrawBaseline(i)
			
			// show markers
			hiroSpike2HideMarkers(0)
			
			// show warnings, if any
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2Percent(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// Save
			WAVE wPercent=:IO:wPercent
			wPercent[i]=dval
			
			Variable fraction
			WAVE wBaseFrac=:IO:wBaseFrac
			if (numtype(wBaseFrac[i])==2)
				ControlInfo setvarSpike2Baseline
				fraction=V_Value
				wBaseFrac[i]=fraction
			else
				fraction=wBaseFrac[i]
			endif
			
			hiroSpike2DrawBaseline(i,fraction=fraction)
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2Smooth(i,[num])
	
	Variable i	// zero-based stim number
	Variable num		// number of times to apply binomial smoothing
	
	// If num is not passed, look it up
	if (num)
		// reset control (reload)
		SetVariable setvarSpike2Smooth value=_NUM:num
	else
		// adopt previous setting
		ControlInfo setvarSpike2Smooth
		num=V_Value
	endif
	
	// smooth
	DFREF dfr=:Trials
	DFREF dfrOrig=:Trials_Orig
	
	String nameW="w"+num2str(i)
	
	Duplicate/O dfrOrig:$nameW,dfr:$nameW
	
	WAVE w=dfr:$nameW
	
	if (num)
		Smooth num, w
	endif
	
	// Normalize if needed
	NVAR gNormBase=:Cache:gNormBase	// saved in step 2f of DoAvgTrials 
	SVAR gNormBaseUnits=:Cache:gNormBaseUnits
	
	if (gNormBase)
		MultiThread w/=abs(gNormBase)
		if (gNormBase>0)
			MultiThread w-=1
		else
			MultiThread w+=1
		endif
		SetScale d 0,0,gNormBaseUnits, w
	endif
	
	// Save
	WAVE wSmooth=:IO:wSmooth
	wSmooth[i]=num
	
End


Function SetVarProcSpike2Smooth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			if (i>=0)
				// Save
				WAVE wSmooth=:IO:wSmooth
				wSmooth[i]=dval
				
				hiroSpike2Smooth(i,num=dval)
				
//				ControlInfo setvarSpike2PeakLoc
//				hiroSpike2DetectPeak(i,sPeak=V_Value)
				//WAVE wPeakX=:IO:wPeakX
				//hiroSpike2DetectPeak(i,sPeak=wPeakX[i])
				hiroSpike2DetectPeak(i)
				
//				ControlInfo setvarSpike2Baseline
//				hiroSpike2DrawBaseline(i,fraction=V_Value)
				//WAVE wBaseFrac=:IO:wBaseFrac
				//hiroSpike2DrawBaseline(i,fraction=wBaseFrac[i])
				hiroSpike2DrawBaseline(i)
				
				hiroSpike2WarningCheck(i)
				
			else
				// smooth all the traces
				hiroSpike2SmoothAllTrials(dval)
				
				// Recalculate mean
				TrialAvgStep4()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2SmoothAllTrials(num)
	// Smooth all the traces in Trials DF
	
	Variable num
	
	DFREF dfr=:Trials
	Variable n=CountObjectsDFR(dfr,1)
	Variable k
	for (k=0;k<n;k+=1)
		hiroSpike2Smooth(k,num=num)
	endfor
	
End


Function SetVarProcSpike2Baseline(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
			//ControlInfo setvarStimNumber
			//Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// reset warning
			SVAR gWarning=:Cache:gWarning
			gWarning=""
			
			// Save
			WAVE wBaseFrac=:IO:wBaseFrac
			wBaseFrac[i]=dval
			
			hiroSpike2DrawBaseline(i,fraction=dval)
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2PeakLoc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// Save
			WAVE wPeakX=:IO:wPeakX
			wPeakX[i]=dval
			
			hiroSpike2DetectPeak(i,sPeak=dval)
			
//			ControlInfo setvarSpike2Baseline
//			Variable fraction=V_Value
			WAVE wBaseFrac=:IO:wBaseFrac
			
			hiroSpike2DrawBaseline(i,fraction=wBaseFrac[i])
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2RangeFrom(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// Save
			WAVE wRangeFrom=:IO:wRangeFrom
			wRangeFrom[i]=dval
			
			hiroSpike2DetectPeak(i)
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2RangeTo(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// Save
			WAVE wRangeTo=:IO:wRangeTo
			wRangeTo[i]=dval
			
			hiroSpike2DetectPeak(i)
			
			// Update drawn lines
			Variable fraction
			WAVE wBaseFrac=:IO:wBaseFrac
			if (!numtype(wBaseFrac[i]))
				fraction=wBaseFrac[i]
			else
				ControlInfo setvarSpike2Baseline
				fraction=V_Value
			endif
			
			hiroSpike2DrawBaseline(i,fraction=fraction)
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2LeftLoc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			// prevent auto-optimization of left marker
			NVAR optimizeLeft=:Cache:optimizeLeft
			optimizeLeft=0
			
			hiroSpike2DetectPercentLoc(i,kLEFT)
			
			// reset
			optimizeLeft=1
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2RightLoc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2SwitchDF()
			
//			ControlInfo setvarStimNumber
//			Variable i=V_Value-1
			NVAR i=:Cache:iStim
			
			hiroSpike2DetectPercentLoc(i,kRIGHT)
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2FootLoc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
			NVAR i=:Cache:iStim
			
			hiroSpike2DetectFoot(i,foot=dval)
			
			// Save
			WAVE wFootX=:IO:wFootX
			wFootX[i]=dval
			
			hiroSpike2WarningCheck(i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2StimNext(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2SwitchDF()
			
			ControlInfo setvarStimNumber
			Variable j=V_Value
			
			Variable newj=j+1
			
			NVAR nStim
			if (newj<=nStim)
				SetVariable setvarStimNumber value=_NUM:newj
				
				hiroSpike2GotoStim(newj)
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2StimBack(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2SwitchDF()
			
			ControlInfo setvarStimNumber
			Variable j=V_Value
			
			Variable newj=j-1
			
			NVAR nStim
			if (newj>=0)
				SetVariable setvarStimNumber value=_NUM:newj
				
				hiroSpike2GotoStim(newj)
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2GotoStim(j)
	
	Variable j		// 1-based stim number
	Variable i=j-1		// 0-based stim number
	
	// Adjust back-next buttons
	NVAR nStim
	if (j==0)
		Button buttonSpike2StimBack disable=2
	else
		Button buttonSpike2StimBack disable=0
	endif
	if (j==nStim)
		Button buttonSpike2StimNext disable=2
	else
		Button buttonSpike2StimNext disable=0
	endif
	
	WAVE wAnalyzed=:IO:wAnalyzed
	
	String nameW
	
	// Save
	NVAR iStim=:Cache:iStim
	iStim=i
	
	// reset warning
	//hiroSpike2Warning("")
	
	if (!j)
		// show all
		ModifyGraph hideTrace=0
	else
		nameW="w"+num2str(i)
		ModifyGraph hideTrace=1
		WAVE/Z w=TraceNameToWaveRef("",nameW)
		if(WaveExists(w))
			ModifyGraph hideTrace($nameW)=0
		endif
	endif
	
	//WAVE selROI
	WAVE wIncluded=:IO:wIncluded
	if (!j)
		CheckBox checkIncludeThisResponse disable=1
		
		// hide select controls
		hiroSpike2HideControls(1)
		
		// hide markers
		hiroSpike2HideMarkers(1)
		
		// hide drawn objects
		DrawAction/L=ProgFront delete
		DrawAction/L=ProgBack delete
		
		// clear warning
		SVAR gWarning=:Cache:gWarning
		gWarning=""
	else
		CheckBox checkIncludeThisResponse disable=0
		
		// show select controls
		hiroSpike2HideControls(0)
		
		// Analyze just the "included" response
		//if (selROI[i])
		if (wIncluded[i])
			CheckBox checkIncludeThisResponse value=1
			
			//? Load or reset user data in control (obsolete)
			//SetVariable setvarSpike2PeakLoc userData="NaN"
			//Button buttonSpike2LeftLoc userData="NaN"
			//Button buttonSpike2RightLoc userData="NaN"
			
			WAVE wMarkerFit
			wMarkerFit=NaN
			
			if (!numtype(wAnalyzed[i]))
				// Load data from IO
				
				// turn off auto-optimize Left marker
				NVAR optimizeLeft=:Cache:optimizeLeft
				optimizeLeft=0
				
				WAVE wSmooth=:IO:wSmooth
				hiroSpike2Smooth(i,num=wSmooth[i])
				
				WAVE wPeakX=:IO:wPeakX
				hiroSpike2DetectPeak(i,sPeak=wPeakX[i])
				
				WAVE wBaseFrac=:IO:wBaseFrac
				hiroSpike2DrawBaseline(i,fraction=wBaseFrac[i])
				
				optimizeLeft=1
				
				// turn off "analyzed" until this trace is done
				wAnalyzed[i]=NaN
				
			else
				// Smooth trace
				hiroSpike2Smooth(i)
				
				// auto-detect peak
				hiroSpike2DetectPeak(i)
				
				// Adjust limits of baseline control
				hiroSpike2DrawBaseline(i)
			endif
			
			// show markers
			hiroSpike2HideMarkers(0)
			
			// show warnings, if any
			hiroSpike2WarningCheck(i)
			
		else
			CheckBox checkIncludeThisResponse value=0
			
			// hide markers
			hiroSpike2HideMarkers(0)
			
			// hide drawn objects
			DrawAction/L=ProgFront delete
			DrawAction/L=ProgBack delete
		endif
		
	endif
	
	NVAR iStimprev=:Cache:iStimprev
	if (i!=iStimprev)
		// iStimprev cannot be negative (i.e., ignore if j=0)
		if (iStimprev>-1)
			// mark previous as "analyzed"
			wAnalyzed[iStimprev]=1
		endif
		iStimprev=i
	endif
	
End


Function SetVarProcStimNumber(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroSpike2SwitchDF()
			
			hiroSpike2GotoStim(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2DetectBaseline(i,wTrial,wFull)
	
	Variable i
	WAVE wTrial		// ref to short, "trial" wave
	WAVE wFull		// ref to the original trace (e.g., "CaRec1")
	
	Variable baseY
	Variable flag
	
	if (DataFolderExists(":Baseline"))
		// Read baseline value from the library
		
		WAVE wOnLoc	// this stim is x-based
		WAVE wBaseOnLoc=:Baseline:wBaseOnLoc	// this is p-based
		WAVE wBaseline=:Baseline:wBaseline
		
		// convert stim as p-based
		Variable pStim=x2pnt(wFull,wOnLoc[i])
		Variable pNear
		
		FindLevel/P/Q wBaseOnLoc,pStim
		if (V_flag)
			// not found
			pNear=wBaseOnLoc[numpnts(wBaseOnLoc)-1]
			//Print/D i,pStim,pNear
			
			if (pStim>pNear)
				// this is likely the last trace. Just use the final baseline value
				baseY=wBaseline[numpnts(wBaseOnLoc)-1]
			else
				flag=1
			endif
		else
			pNear=floor(V_LevelX)
			baseY=wBaseline[pNear]
			//Print pNear,pStim,baseY
		endif
	else
		flag=1
	endif
	
	if (flag)
		// this is an unreliable method, but the user chose to skip baseline detection
		Duplicate/FREE/R=(leftx(wTrial),0) wTrial,wFree
		baseY=StatsMedian(wFree)
	endif
	
	return baseY
	
End
		

Function hiroSpike2DrawBaseline(i,[fraction])
	
	Variable i	// zero-based stimulus number
	Variable fraction
	
	NVAR isZeroed=:Cache:isZeroed
	
	WAVE w=hiroSpike2GetWaveRef(i)
	
	Variable minY=WaveMin(w)
	Variable maxY=WaveMax(w)
	//GetAxis/Q left	// somehow this is off; it's not showing the incorrect values
	//Variable minY=V_min
	//Variable maxY=V_max
	Variable rangeY=maxY-minY
	
	Variable baseY
	
	WAVE wBaseFrac=:IO:wBaseFrac
	WAVE wBaseY=:IO:wBaseY
	
	WAVE wPeakX=:IO:wPeakX
	WAVE wPeakY=:IO:wPeakY
	
	// If fraction is not passed, look it up
	if (!fraction)
		// Because the Baseline control is expressed as a fraction, find the
		// zero baseline as a fraction between 0 and 1
		if (isZeroed)
			baseY=0
			//fraction=abs(minY)/rangeY
		else
			WAVE/T wT=:CoreCache:wTStimResPair
			String nameTrace=wT[1]	// e.g., "CaRec1"
			baseY=hiroSpike2DetectBaseline(i,w,$nameTrace)
			
			// If baseline was guessed on the spot, correct based on the history for the last 4 trials
			if (!DataFolderExists(":Baseline"))	
				if (i>3)
					WAVE wBaseY=:IO:wBaseY
					Duplicate/FREE/R=[i-4,i-1] wBaseY,wLocalBaseY
					Variable avgBaseY=mean(wLocalBaseY)
					Variable sdBaseY=sqrt(Variance(wLocalBaseY))
					//Print baseY,baseY-avgBaseY,avgBaseY,"+",sdBaseY
					
					// if the new baseline is more than 2 SD deviated from the mean of recent baselines,
					// auto-suggest baseline
					if (2*sdBaseY<abs(baseY-avgBaseY))
						baseY=avgBaseY
						//Print "Stim",i+1,"baseline auto-suggest"
						
		//				// readjust minY and rangeY if needed
		//				if (avgBaseY<minY)
		//					Variable diff=abs(avgBaseY-minY)
		//					Print minY
		//					minY-=(diff+0.01)
		//					Print minY
		//					rangeY-=(diff+0.01)
		//					SetAxis left minY,maxY
		//				endif
					endif
				endif
			endif
		endif
		
		fraction=(baseY-minY)/rangeY
		
		SetVariable setvarSpike2Baseline value=_NUM:fraction
		
		// Save
		wBaseFrac[i]=fraction
	else
		baseY=rangeY*fraction+minY
		
		if (isZeroed)
			// force baseline to zero
			
			//Variable t=tic()
			MultiThread w-=baseY
			//toc(t)
			
			// adjust wPeakY
			wPeakY[i]-=baseY
			
			// adjust wMarkerPeak
			WAVE wMarkerPeak
			WAVE wPeakP=:IO:wPeakP
			wMarkerPeak[wPeakP[i]]=wPeakY[i]
			
			// subtract baseY from baseY, in other words, force it to zero
			baseY=0
			
			// Update mean plot on the other graph
			TrialAvgStep4()
			
			// remeasure y-range
			minY=WaveMin(w)
			maxY=WaveMax(w)
			//GetAxis/Q left
			//minY=V_min
			//maxY=V_max
			rangeY=maxY-minY
			
			fraction=(baseY-minY)/rangeY
		
			SetVariable setvarSpike2Baseline value=_NUM:fraction
			
			// Save
			wBaseFrac[i]=fraction
		endif
	endif
	
	// Save
	wBaseY[i]=baseY
	
	DrawAction/L=ProgFront delete
	SetDrawLayer ProgFront
	
	// Oddly, 0 is at the top and 1 is at the bottom in DrawLine.
	// This oddity is corrected by subtracting the fraction from 1
	Variable fBaseline=1-fraction
	SetDrawEnv linefgc= (13056,13056,13056),dash= 2,linethick= 0.50
	DrawLine 0,fBaseline,1,fBaseline
	
	// Draw a line from the peak to the baseline
	//ControlInfo setvarSpike2PeakLoc
	//Variable xPeak=V_Value
	//Variable yPeak=str2num(S_UserData)
	Variable xPeak=wPeakX[i]
	Variable yPeak=wPeakY[i]
	
	Variable fPeak=1-(yPeak-minY)/rangeY
	
	SetDrawEnv xcoord= bottom,linefgc= (13056,13056,13056),dash= 2,linethick= 0.50
	DrawLine xPeak,fBaseline,xPeak,fPeak
	
	// Draw a line across the % amplitude
	Variable percent
	WAVE wPercent=:IO:wPercent
	if (numtype(wPercent[i])==2)
		ControlInfo setvarSpike2Percent
		percent=V_Value
		
		// Save
		wPercent[i]=percent
	else
		percent=wPercent[i]
		// reset control (reload)
		SetVariable setvarSpike2Percent value=_NUM:percent
	endif
	
	Variable yAmplitude=yPeak-baseY
	
	Variable yPercentAmplitude=baseY+0.01*percent*yAmplitude
	
	Variable fPercentAmplitude=1-(yPercentAmplitude-minY)/rangeY
	
	SetDrawEnv linefgc= (13056,13056,13056),dash= 2,linethick= 0.50
	DrawLine 0,fPercentAmplitude,1,fPercentAmplitude
	
	// Default
	SetDrawLayer UserFront
	
	// Find % amplitude locations
	hiroSpike2DetectPercentLoc(i,kBOTH)
	
End


Function hiroSpike2DrawRange(i,range1,range2)
	// Draw curtains to limit ranges on the graph (gray rectangles)
	
	Variable i	// zero-based stimulus number
	Variable range1
	Variable range2
	
	WAVE w=hiroSpike2GetWaveRef(i)
	
	DrawAction/L=ProgBack delete
	SetDrawLayer ProgBack
	
	SetDrawEnv xcoord= bottom,fillfgc= (56576,56576,56576),linethick= 0.00
	DrawRect leftx(w),0,range1,1
	
	Variable sBefore=abs(leftx(w))
	Variable sAfter=rightx(w)
	Variable sRightEnd
	
	// Optional: zoom-in horizontally so that each side is padded by at least an equivalent of sBefore
	Variable padLeft=range2+sBefore
	
	sRightEnd=padLeft
	
	GetAxis/Q bottom
	if (range2==sAfter)
		sRightEnd=sAfter
	elseif (V_max>padLeft)
		sRightEnd=padLeft
	elseif (padLeft>sAfter)
		sRightEnd=sAfter
	endif
	
	SetAxis bottom -sBefore,sRightEnd
	
	// Set the right end of the curtain
	SetDrawEnv xcoord= bottom,fillfgc= (56576,56576,56576),linethick= 0.00
	DrawRect range2,0,sRightEnd,1
	
	// Default
	SetDrawLayer UserFront
	
End


Function/WAVE hiroSpike2GetWaveRef(i)
	// return a wave reference of the current response shown in i-th stimulus
	
	Variable i
	
	//DFREF dfr=:Trials
	//WAVE w=WaveRefIndexedDFR(dfr,i)	// can't use this in version earlier than 6.30
	
	// a workaround for version 6.22
	DFREF dfrSaved=GetDataFolderDFR()
	SetDataFolder :Trials
		WAVE w=WaveRefIndexed("",i,4)
		//Print NameOfWave(w)
	SetDataFolder dfrSaved
	
	return w
End


Function hiroSpike2DetectPeak(i,[sPeak])
	
	Variable i	// zero-based stim number
	Variable sPeak
	
	// reset warning
	//hiroSpike2Warning("")
	
	Variable isPassed
	if (sPeak)
		isPassed=1
	endif
	
	WAVE w=hiroSpike2GetWaveRef(i)
	
	// load real stim onset x-value
	WAVE wRealOnX=:IO:wRealOnX
	
	Variable sBefore=abs(leftx(w))
	Variable sAfter=rightx(w)
	
	// Gather the control info
	Variable polarity,range1,range2
	
	WAVE wPolarity=:IO:wPolarity
	WAVE wRangeFrom=:IO:wRangeFrom
	WAVE wRangeTo=:IO:wRangeTo
	WAVE wRealRangeFrom=:IO:wRealRangeFrom
	WAVE wRealRangeTo=:IO:wRealRangeTo
	
	if (!numtype(wPolarity[i]))
		polarity=wPolarity[i]
		// reset control (reload)
		PopupMenu popupSpike2PeakPolarity mode=polarity
	else
		ControlInfo popupSpike2PeakPolarity
		polarity=V_Value		// 1 for positive, 2 for negative
		// Save
		wPolarity[i]=polarity
	endif
	
	if (!numtype(wRangeFrom[i]))
		range1=wRangeFrom[i]
		// reset control (reload)
		SetVariable setvarSpike2RangeFrom value=_NUM:range1
	else
		ControlInfo setvarSpike2RangeFrom
		range1=V_Value
		// Save
		wRangeFrom[i]=range1
		wRealRangeFrom[i]=wRealOnX[i]+range1
	endif
	
	if (!numtype(wRangeTo[i]))
		range2=wRangeTo[i]
		// reset control (reload)
		SetVariable setvarSpike2RangeTo value=_NUM:range2
	else
		ControlInfo setvarSpike2RangeTo
		range2=V_Value
		// Save
		wRangeTo[i]=range2
		wRealRangeFrom[i]=wRealOnX[i]+range2
	endif
	
	// Redraw curtain to show range to analyze
	hiroSpike2DrawRange(i,range1,range2)
	
	Variable yPeak
	
	if (!sPeak)
//	if (polarity==1)
//		FindPeak/M=0.002/P/Q/R=(range1,range2) w
//	elseif (polarity==2)
//		FindPeak/N/M=0.002/P/Q/R=(range1,range2) w
//	else
//		DoAlert 0, "Is the peak direction set?\rIt should either be Positive or Negative"
//		Print "Error: Peak-direction set?"
//		Abort
//	endif
//	
//	if (!V_flag)
//		sPeak=pnt2x(w,V_PeakLoc)
//		yPeak=V_PeakVal
//	else
		WaveStats/Q/R=(range1,range2)/M=1 w
		if (polarity==kPositive)
			sPeak=V_maxloc
			yPeak=V_max
		elseif (polarity==kNegative)
			sPeak=V_minloc
			yPeak=V_min
		else
			DoAlert 0, "Is the peak direction set?\rIt should either be Positive or Negative"
			Print "Error: Peak-direction set?"
			Abort
		endif
	endif
	
	// Refine peak by averaging a few points before and after
	Variable p1=x2pnt(w,sPeak)
	Variable x1=pnt2x(w,p1-kPntsToAvg)
	Variable x2=pnt2x(w,p1+kPntsToAvg)
	yPeak=mean(w,x1,x2)
	
	// Save
	WAVE wPeakP=:IO:wPeakP
	WAVE wPeakX=:IO:wPeakX
	WAVE wPeakY=:IO:wPeakY
	WAVE wRealPeakX=:IO:wRealPeakX
	WAVE wLatency2Peak=:IO:wLatency2Peak
	
	wPeakP[i]=p1
	wPeakX[i]=sPeak
	wPeakY[i]=yPeak
	wRealPeakX[i]=wRealOnX[i]+sPeak
	wLatency2Peak[i]=sPeak
	
	// Save yPeak as user data
	SetVariable setvarSpike2PeakLoc userData=num2str(yPeak)
	
	// Update peak control
	SetVariable setvarSpike2PeakLoc value=_NUM:sPeak,limits={range1,range2,0.01}
	
	// Update foot control
	SetVariable setvarSpike2FootLoc limits={range1,sPeak,0.01}
	
	// Update peak marker on graph
	WAVE wMarkerPeak
	wMarkerPeak=NaN
	wMarkerPeak[x2pnt(w,sPeak)]=yPeak
	
	if (isPassed)
		// Find % amplitude locations
		hiroSpike2DetectPercentLoc(i,kBOTH)
	endif
	
	// Save to M_Data cache
	
End


Function hiroSpike2DetectPercentLoc(i,direction)
	
	Variable i	// zero-based stim number
	
	Variable direction	// 0 for left, 1 for right, 2 for both
	
	WAVE w=hiroSpike2GetWaveRef(i)
	
	WAVE wRealOnX=:IO:wRealOnX
	
	Variable thresh
	
	WAVE wPolarity=:IO:wPolarity
	Variable polarity=wPolarity[i]
	
	Variable minY=WaveMin(w)
	Variable maxY=WaveMax(w)
	//GetAxis/Q left
	//Variable minY=V_min
	//Variable maxY=V_max
	Variable rangeY=maxY-minY
	
	ControlInfo setvarSpike2Baseline
	Variable fraction=V_Value
	
	Variable baseY=rangeY*fraction+minY
	
//	ControlInfo setvarSpike2PeakLoc
//	Variable sPeak=V_Value
//	Variable yPeak=str2num(S_UserData)
	WAVE wPeakX=:IO:wPeakX
	WAVE wPeakY=:IO:wPeakY
	Variable sPeak=wPeakX[i]
	Variable yPeak=wPeakY[i]
	
	Variable amplitudeY=yPeak-baseY
	
	// Save
	WAVE wAmplitudeY=:IO:wAmplitudeY
	wAmplitudeY[i]=amplitudeY
	
	ControlInfo setvarSpike2Percent
	Variable percent=V_Value
	
	thresh=baseY+0.01*percent*amplitudeY
	
	// Save
	WAVE wThreshY=:IO:wThreshY
	wThreshY[i]=thresh
	
	ControlInfo setvarSpike2RangeTo
	Variable range2=V_Value
	
	Variable pLoc,xLoc
	
	WAVE wMarkerLeft
	WAVE wMarkerRight
	
	if (direction==kBOTH)
		wMarkerLeft=NaN
		wMarkerRight=NaN
	elseif (direction==kLEFT)
		wMarkerLeft=NaN
	elseif (direction==kRIGHT)
		wMarkerRight=NaN
	endif
	
	//String strErr=""
	
	WAVE wLeftP=:IO:wLeftP
	WAVE wLeftX=:IO:wLeftX
	WAVE wLeftY=:IO:wLeftY
	WAVE wRealLeftX=:IO:wRealLeftX
	WAVE wRightP=:IO:wRightP
	WAVE wRightX=:IO:wRightX
	WAVE wRightY=:IO:wRightY
	WAVE wRealRightX=:IO:wRealRightX
	
	Variable reload
	WAVE wAnalyzed=:IO:wAnalyzed
	if (!numtype(wAnalyzed[i]))
		reload=1
	endif
	
	Variable edge
	
	// Find left marker location
	pLoc=NaN
	if (direction==kLEFT || direction==kBOTH)
		
		// Load previously remembered location. Default is NaN
//		ControlInfo buttonSpike2LeftLoc
//		pLoc=str2num(S_UserData)
		pLoc=wLeftP[i]
		
		if (reload)
			if (!numtype(pLoc))
				// just update the marker
				wMarkerLeft[pLoc]=w[pLoc]
			endif
		else
			// detect automatically
			if (polarity==kPositive)
				edge=1
			else
				edge=2
			endif
			if (direction==kLEFT && !numtype(pLoc))
				// Left jumper button should start from the current marker position
				xLoc=pnt2x(w,pLoc-kPnts2Jump)		// at least a few data points smaller
				FindLevel/EDGE=(edge)/P/Q/R=(xLoc,0) w,thresh
				
				if (V_flag)
					// Not found: Get the default
					FindLevel/EDGE=(edge)/P/Q/R=(sPeak,0) w,thresh
				endif
			else
				FindLevel/EDGE=(edge)/P/Q/R=(sPeak,0) w,thresh
			endif
			
			if (V_flag)
				// level not found
				//strErr="Level not found for the left marker; missing foot"
				Button buttonSpike2LeftLoc disable=2
				
				// Save
				wLeftP[i]=NaN
				wLeftX[i]=NaN
				wLeftY[i]=NaN
				wRealLeftX[i]=NaN
			else
				pLoc=V_LevelX
				
				wMarkerLeft[pLoc]=w[pLoc]
				
				Button buttonSpike2LeftLoc userData=num2str(pLoc),disable=0
				
				wLeftP[i]=pLoc
				wLeftX[i]=pnt2x(w,pLoc)
				wLeftY[i]=w[pLoc]
				wRealLeftX[i]=wRealOnX[i]+wLeftX[i]
			endif
		endif
	endif
	
	// Find right marker location
	pLoc=NaN	// init
	if (direction==kRIGHT || direction==kBOTH)
		
		// Load previously remembered location, if any. Default is NaN
//		ControlInfo buttonSpike2RightLoc
//		pLoc=str2num(S_UserData)
		pLoc=wRightP[i]
		
		if (reload)
			if (!numtype(pLoc))
				// just update the marker
				wMarkerRight[pLoc]=w[pLoc]
			endif
		else
			// detect automatically
			if (polarity==kPositive)
				edge=2
			else
				edge=1
			endif
			if (direction==kRIGHT && !numtype(pLoc))
				xLoc=pnt2x(w,pLoc+kPnts2Jump)	// at least a few data points larger
				FindLevel/EDGE=(edge)/P/Q/R=(xLoc,range2) w,thresh
				if (V_flag)
					// not found. Get the default
					FindLevel/EDGE=(edge)/P/Q/R=(sPeak,range2) w,thresh
				endif
			else
				FindLevel/EDGE=(edge)/P/Q/R=(sPeak,range2) w,thresh
			endif
			
			if (V_flag)
				// level not found
//				if (strlen(strErr))
//					strErr+="\r"
//				endif
//				strErr+="Level not found for the right marker"
				Button buttonSpike2RightLoc disable=2
				
				// Save
				wRightP[i]=NaN
				wRightX[i]=NaN
				wRightY[i]=NaN
				wRealRightX[i]=NaN
			else
				pLoc=V_LevelX
				
				wMarkerRight[pLoc]=w[pLoc]
				
				Button buttonSpike2RightLoc userData=num2str(pLoc),disable=0
				
				// Save
				wRightP[i]=pLoc
				wRightX[i]=pnt2x(w,pLoc)
				wRightY[i]=w[pLoc]
				wRealRightX[i]=wRealOnX[i]+wRightX[i]
			endif
		endif
	endif
	
	// double-check
	if (!numtype(wLeftP[i]) && !numtype(wRightP[i]))
		// Save %-amplitude duration
		WAVE wPercentDuration=:IO:wPercentDuration
		wPercentDuration[i]=pnt2x(w,wRightP[i])-pnt2x(w,wLeftP[i])
	endif
	
	// Find foot
	if (reload)
		WAVE wFootX=:IO:wFootX
		hiroSpike2DetectFoot(i,foot=wFootX[i])
	else
		hiroSpike2DetectFoot(i)
	endif
	
End


Function hiroSpike2DetectFoot(i,[foot])
	
	Variable i	// zero-based stim number
	Variable foot	// in s
	
	WAVE w=hiroSpike2GetWaveRef(i)
	WAVE wLeftX=:IO:wLeftX
	
	Variable pFoot
	
	if (numtype(wLeftX[i])==2)
		// Left marker does not exist.  Foot cannot be found.
		pFoot=NaN
		
		// Save but do not calculate rise time, etc.
		hiroSpike2UpdateFoot(i,w,pFoot)
		return -1
	endif
	
	WAVE wBaseY=:IO:wBaseY
	WAVE wAmplitudeY=:IO:wAmplitudeY
	WAVE wPolarity=:IO:wPolarity
	
	Variable polarity=wPolarity[i]
	
	Variable xLeft
	xLeft=wLeftX[i]
	
	// threshold is 10% from the baseline
	Variable thresh
	Variable percent=kPercentFoot
	
	thresh=wBaseY[i]+percent*wAmplitudeY[i]
	
	Variable edge
	if (polarity==kPositive)
		edge=1
	else
		edge=2
	endif
	
	if (foot)
		// foot (x value) has been passed. use it to convert to point
		pFoot=x2pnt(w,foot)
	else
		// Detect foot and save
		FindLevel/EDGE=(edge)/P/Q/R=(xLeft,0) w,thresh
		if (V_flag)
			pFoot=NaN
		else
			pFoot=V_LevelX
		endif
	endif
	
	// Save and calculate rise time, etc.
	hiroSpike2UpdateFoot(i,w,pFoot)
	
End


Function hiroSpike2UpdateFoot(i,w,pFoot)
	
	Variable i
	WAVE w
	Variable pFoot
	
	WAVE wRealOnX=:IO:wRealOnX
	
	WAVE wFootP=:IO:wFootP
	WAVE wFootX=:IO:wFootX
	WAVE wFootY=:IO:wFootY
	WAVE wRealFootX=:IO:wRealFootX
	WAVE wLatency=:IO:wLatency
	WAVE wRiseTime=:IO:wRiseTime
	WAVE wR2=:IO:wR2
	
	WAVE wMarkerFoot
	wMarkerFoot=NaN
	
	// Save
	wFootP[i]=pFoot
	if (!numtype(pFoot))
		
		wFootX[i]=pnt2x(w,pFoot)
		wFootY[i]=w[pFoot]
		wRealFootX[i]=wRealOnX[i]+wFootX[i]
		wLatency[i]=wFootX[i]
		
		wMarkerFoot[pFoot]=wFootY[i]
		
		// Turn off warning
		//hiroSpike2Warning("")
		
		// Measure rise time, etc. if pFoot is numeric
		Variable r2,count
		
		NVAR optimizeLeft=:Cache:optimizeLeft
		if (optimizeLeft)
			// optimize left marker (search from the foot to the peak)
			hiroSpike2OptimizeLeft(i,w,pFoot)
		endif
		
		r2=hiroSpike2DetectRiseTime(i,w,pFoot)
		
		wR2[i]=r2
		
		if (!numtype(r2))
			// analyze r^2 for fitness
			if (r2<kR2)
				//TitleBox titleWarning title="Line is poorly fit; rise time not saved.",disable=0
				//hiroSpike2Warning("Line is poorly fit; rise time not saved.")
				wRiseTime[i]=NaN
				ModifyGraph rgb(wMarkerFit)=(65280,0,0)	// red
			else
				// Turn off warning
				//hiroSpike2Warning("")
				WAVE W_coef
				wRiseTime[i]=W_coef[1]
				ModifyGraph rgb(wMarkerFit)=(0,52224,0)	// green
			endif
			
			// Show the resulting line
			//String nameLine="fit_"+NameOfWave(w)		// e.g., "fit_w11"
			ModifyGraph hideTrace(wMarkerFit)=0,lstyle(wMarkerFit)=2,lsize(wMarkerFit)=1.5
		endif
	else
		wFootX[i]=NaN
		wFootY[i]=NaN
		wRealFootX[i]=NaN
		wLatency[i]=NaN
		wRiseTime[i]=NaN
		wR2[i]=NaN
		
		//hiroSpike2Warning("Foot not found.")
		
		// Hide the fitted line, if any
		//String nameLine="fit_"+NameOfWave(w)		// e.g., "fit_w11"
		String nameLine="wMarkerFit"
		// Check if this wave exists
		WAVE/Z wLine=TraceNameToWaveRef("",nameLine)
		if (WaveExists(wLine))
			ModifyGraph hideTrace($nameLine)=1
		endif
	endif
	
	// Update foot control
	SetVariable setvarSpike2FootLoc value=_NUM:wFootX[i]
	
End


Function hiroSpike2OptimizeLeft(i,w,pFoot)
	
	Variable i
	WAVE w
	Variable pFoot
	
	Variable pLoc,sPeak,thresh
	
	WAVE wPeakX=:IO:wPeakX
	sPeak=wPeakX[i]
	
	WAVE wThreshY=:IO:wThreshY
	thresh=wThreshY[i]
	
	WAVE wMarkerLeft
	
	Variable polarity,edge
	WAVE wPolarity=:IO:wPolarity
	polarity=wPolarity[i]
	if (polarity==kPositive)
		edge=1
	else
		edge=2
	endif
	
	// Left jumper button should start from the foot and search towards the peak
	FindLevel/EDGE=(edge)/P/Q/R=(pnt2x(w,pFoot),sPeak) w,thresh
	if (!V_flag)
		pLoc=V_LevelX
		
		wMarkerLeft=NaN
		wMarkerLeft[pLoc]=w[pLoc]
		
		WAVE wLeftP=:IO:wLeftP
		wLeftP[i]=pLoc
	endif
	
End


Function hiroSpike2DetectRiseTime(i,w,pFoot)
	// assumes that pFoot and wLeftP[i] is numeric
	
	Variable i
	WAVE w
	Variable pFoot
	
	WAVE wLeftP=:IO:wLeftP
	Variable pLeft=wLeftP[i]
	
	// fit a line between the two points
	//Duplicate/O w,wMarkerFit
	WAVE wMarkerFit
	wMarkerFit=NaN
	
	// make sure pFoot and pLeft aren't at the same loc
	if (pFoot<pLeft)
		CurveFit/M=2/W=2/Q/N line, w[pFoot,pLeft]/D=wMarkerFit
	else
		return NaN
	endif
	
	return V_r2
	
End


Function hiroSpike2WarningCheck(i)
	
	Variable i
	
	WAVE wP=:Cache:wWarningP
	WAVE/T wT=:Cache:wWarningT
	
	WAVE wLeftP=:IO:wLeftP
	WAVE wRightP=:IO:wRightP
	WAVE wFootP=:IO:wFootP
	WAVE wRiseTime=:IO:wRiseTime
	
	SVAR gWarning=:Cache:gWarning
	gWarning=""
	
	if (!numtype(wLeftP[i]))
		wP[0]=0
	else
		wP[0]=1
	endif
	
	if (!numtype(wRightP[i]))
		wP[1]=0
	else
		wP[1]=1
	endif
	
	if (!numtype(wFootP[i]))
		wP[2]=0
	else
		if (!wP[0])
			// left marker found but foot not found
			wP[2]=1
		else
			wP[2]=0
		endif
	endif
	
	if (!numtype(wRiseTime[i]))
		wP[3]=0
	else
		if (!wP[0] && !wP[2])
			// left marker missing but line fits poorly
			wP[3]=1
		else
			wP[3]=0
		endif
	endif
	
	Extract/FREE/INDX wP,wINDX,wP==1
	
	Variable k
	for(k=0;k<numpnts(wINDX);k+=1)
		if (!k)
			gWarning=wT[wINDX[k]]
		else
			gWarning+="\r"+wT[wINDX[k]]
		endif
	endfor
	
End


Function hiroSpike2Warning(strErr)
	
	String strErr
	
	SVAR gWarning=:Cache:gWarning
	
	if (!strlen(strErr))
		TitleBox titleWarning disable=1
		gWarning=""
		return 0
	endif
	
	// Check if there are already a warning online
	if (!strlen(gWarning))
		gWarning = strErr
	else
		if (cmpstr(gWarning,strErr))
			// Make sure duplicate message is removed.
			gWarning=ReplaceString(strErr,gWarning,"")
			gWarning=ReplaceString("\r",gWarning,"")
			// append new error to the next line
			gWarning += "\r" + strErr
		else
			gWarning = strErr
		endif
	endif
	
	TitleBox titleWarning disable=0
	
End


Function hiroSpike2HideControls(status)
	// Show or hide select controls
	Variable status	// 0 show; 1 hide
	
	PopupMenu popupSpike2PeakPolarity disable=status
	SetVariable setvarSpike2Percent disable=status
	SetVariable setvarSpike2Baseline disable=status
	SetVariable setvarSpike2PeakLoc disable=status
	SetVariable setvarSpike2RangeFrom disable=status
	SetVariable setvarSpike2RangeTo disable=status
	Button buttonSpike2LeftLoc disable=status
	Button buttonSpike2RightLoc disable=status
	SetVariable setvarSpike2FootLoc disable=status
	
	if (status)
		ControlBar/T 0
	else
		ControlBar/T 22
	endif
	
End


Function hiroSpike2HideMarkers(status)
	
	Variable status	// 0 show; 1 hide
	
	ModifyGraph hideTrace(wMarkerPeak)=status,hideTrace(wMarkerLeft)=status
	ModifyGraph hideTrace(wMarkerRight)=status,hideTrace(wMarkerFoot)=status
	ModifyGraph hideTrace(wMarkerFit)=status
	
End


Function hiroSpike2SwitchDF()
	// Checks the graph control and match to the correct DF
	
	// If you have more than one instance of the analyzed graphs,
	// the "Include" checkbox will always act on the current DF. If older graph is being
	// updated, you must first switch DF. Every checkbox contains the DF name
	// in its userData. Read and switch the DF first
	
	ControlInfo checkIncludeThisResponse
	
	String namePath="root:"+S_UserData
	//Print namePath
	SetDataFolder $namePath
	
End


Function CheckProcIncludeThisResponse(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			// If you have more than one instance of the analyzed graphs,
			// the checkbox will always act on the current DF. If older graph is being
			// updated, you must first switch DF. Every checkbox contains the DF name
			// in its userData. Read and switch the DF first
//			String namePath="root:"+cba.userData
//			//Print namePath
//			SetDataFolder $namePath
			hiroSpike2SwitchDF()
			
			DFREF dfrSaved=GetDataFolderDFR()
			
			//WAVE selROI
			WAVE wIncluded=:IO:wIncluded
			
			//ControlInfo setvarStimNumber
			//Variable i=V_Value-1		// convert from 1-based to zero-based
			NVAR i=:Cache:iStim
			
			// Does the trace exist on the graph?
			String nameW="w"+num2str(i)
			WAVE/Z w=TraceNameToWaveRef("",nameW)
			Variable traceExists=WaveExists(w)
			
			SVAR gWarning=:Cache:gWarning
			
			SetDataFolder :Trials
			if (checked)
				if (!traceExists)
					WAVE w=$nameW
					AppendToGraph w
					ModifyGraph rgb($nameW)=(34952,34952,34952)
					ReorderTraces mean_response,{$nameW}
					//selROI[i]=1
					wIncluded[i]=1
				endif
				
			else
				if (traceExists)
					RemoveFromGraph $nameW
					//selROI[i]=0
					wIncluded[i]=0
				endif
				
			endif
			SetDataFolder dfrSaved
			
			// work from parent DF
			if (checked)
				hiroSpike2HideMarkers(0)
				
				// Check warnings
				hiroSpike2WarningCheck(i)
			else
				hiroSpike2HideMarkers(1)
				
				// delete the drawn objects
				DrawAction/L=ProgFront delete
				
				// reset warning
				gWarning=""
			endif
			
			// Recalculate average
			TrialAvgStep4()
			
			SetDataFolder dfrSaved
			
			// the following requires that the DF is the parent (so it is not part of the above)
			if (checked)
				if (!traceExists)
					hiroSpike2DrawBaseline(i)
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


// Utility--dynamically superimpose two user-selected traces
Function hiroSpike2OverlayTwoWaves()
	
	String nameW0,nameW1

	// Load list of waves
	String list
	SVAR/Z gOrigWaveList=:CoreCache:gOrigWaveList
	if (SVAR_Exists(gOrigWaveList))
		list=gOrigWaveList
	else
		list=WaveList("*",";","")
	endif
	
	// third wave is optional
	String nameWOptional="_none_"
	String listOptional="_none_;"+list

	Prompt nameW0, "Trace 1*:", popup, list
	Prompt nameW1, "Trace 2*:", popup, list
	Prompt nameWOptional, "Trace 3 (optional, inseparable):", popup, listOptional
	DoPrompt/HELP="Select two waves.  Tab-key toggles between the two fields." "Select two waves (*Required)",nameW0,nameW1,nameWOptional
	if (V_flag == 1)
		Print "User Canceled Procedure"
		Abort	//quit if cancel button was clicked
	else
		if (cmpstr(nameW0,"_none_")==0 || cmpstr(nameW1,"_none_")==0)
			DoAlert/T="Waves not selected" 0, "You need two waves.\rTry again."
			Abort
		endif
	endif
	
	DFREF dfr=GetDataFolderDFR()
	if (DataFolderExists(":Edited"))
		DFREF dfr=:Edited
	endif
	
	WAVE w0=dfr:$nameW0
	WAVE w1=dfr:$nameW1
	
	hiroSpike2Overlay(w0,w1,nameWOptional=nameWOptional)
	
End


Function hiroSpike2Overlay(w0,w1,[nameWOptional])
	
	WAVE w0
	WAVE w1
	String nameWOptional

	String nameW
	
	String nameDF=GetDataFolder(0)
	nameDF=ReplaceString("'",nameDF,"")
	
	String titleGraph="Superimpose "+NameOfWave(w0)+" and "+NameOfWave(w1)+" ("+nameDF+")"
	Display/K=1/N=GraphSpike2Step1 as titleGraph
	
	Variable i
	String axisName
	Variable n=2
	Variable y1,y2
	Variable pad=0.2/n
	for(i=0;i<n;i+=1)
		if (i==0)
			nameW=NameOfWave(w0)
			axisName="customLeft"
			AppendToGraph/L=$axisName w0
			ModifyGraph rgb($nameW)=(16384,28160,65280)
		else
			nameW=NameOfWave(w1)
			axisName="customRight"
			AppendToGraph/R=$axisName w1
			ModifyGraph rgb($nameW)=(17408,17408,17408)
		endif
		y1=1-1/n*(i+1)	// low
		y2=1-1/n*i	// high
		
		// add padding
		//if (y1)
		//	y1+=pad
		//endif
		
		ModifyGraph lblPos($axisName)=50,freePos($axisName)=0,axisEnab($axisName)={y1,y2}
		
		Label $axisName nameW
	endfor
	
	// Overlay third wave
	if (cmpstr(nameWOptional,"_none_"))
		AppendToGraph/L=customLeft2 $nameWOptional
		ModifyGraph lblPos(customLeft2)=100,freePos(customLeft2)=50
		Label customLeft2 nameWOptional
	endif
	
	ModifyGraph margin(left)=80
	//ModifyGraph rgb=(0,39168,0)
	
	ResizeWindow(1000,350)
	
	ControlBar/L 75
	
	NewDataFolder/O :Utilities
	Make/O/N=3 :Utilities:wPSlider /WAVE=wP
	Make/T/O/N=3 :Utilities:wTSlider /WAVE=wT
	
	wP=(0.5/2)*x
	
	wT[0]="Separate"
	wT[2]="Close"
	
	Slider slider0 size={59,100},pos={1,50}
	Slider slider0 proc=SliderProcSpike2Overlay,limits={0,0.5,0}
	Slider slider0 userTicks={:Utilities:wPSlider,:Utilities:wTSlider}
	Slider slider0 help={"Adjust overlay"}
	
	CheckBox checkSpike2ShowAxes title="Show axes",pos={1,170}
	CheckBox checkSpike2ShowAxes proc=CheckProcSpike2ShowAxes,value=1
	CheckBox checkSpike2ShowAxes help={"Check to show axes"}
	
	DoUpdate
	
	Variable x1,x2
	x1=leftx(w0)
	if (rightx(w0)>x1+20)
		x2=x1+20
	else
		x2=rightx(w0)/2
	endif
	
	XAxisScrolling2(x1,x2)
	
End


Function SliderProcSpike2Overlay(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				Variable n=2
				Variable y1,y2
				Variable i
				for(i=0;i<n;i+=1)
					y1=1-1/n*(i+1)	// low
					y2=1-1/n*i	// high
					
					if (i==0)
						ModifyGraph axisEnab(customLeft)={y1-curval,y2}
					else
						ModifyGraph axisEnab(customRight)={y1,y2+curval}
					endif
				endfor
			
			endif
			
			break
	endswitch

	return 0
End



Function CheckProcSpike2ShowAxes(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if (checked)
				ShowAxes()
			else
				WipeAllAxes()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function TrialAvgStep0(nameTrace)
	// Isolate activity from baseline
	
	String nameTrace
	
	if (DataFolderExists(":Edited"))
		WAVE w=:Edited:$nameTrace
	else
		WAVE w=$nameTrace
	endif
	
	if (DataFolderExists(":Filter"))
		KillDataFolder :Filter
	endif
	NewDataFolder :Filter
	Duplicate/O w,:Filter:wHi,:Filter:wZ
	
	WAVE wHi=:Filter:wHi
	WAVE wZ=:Filter:wZ
	
	// this wave will be used as a line threshold
	Make/O/N=2 :Filter:wThresh
	WAVE wThresh=:Filter:wThresh
	SetScale/I x leftx(wHi),rightx(wHi),"", wThresh
	
	if (DataFolderExists(":FilterCache"))
		DFREF dfrC=:FilterCache
	else
		NewDataFolder :FilterCache
		DFREF dfrC=:FilterCache
		Variable/G dfrC:cutHz1=4
		Variable/G dfrC:cutHz2=4.5
		// 101 is the number of FIR filter coefficients to generate--the larger the better stop-band rejection.
		// Wavemetrics recommends 101 as a start
		Variable/G dfrC:coef=1515		// try 1010
		Variable/G dfrC:sBin=1		// 1 s worth of activity to fill disjointed activity so as to "bin"
		Variable/G dfrC:nSD=0.6		// threshold for activity vs baseline separation
	endif
	
	// load parameters from cache
	NVAR cutHz1=dfrC:cutHz1
	NVAR cutHz2=dfrC:cutHz2
	NVAR coef=dfrC:coef
	NVAR sBin=dfrC:sBin
	NVAR nSD=dfrC:nSD
	
	// For bandpass filtering, 0 < f1 < f2 < 0.5 (the normalized Nyquist frequency)
	Variable dx=deltax(wHi)
	
	// declare global strings and variables before the first run
	String/G :Filter:gError
	SVAR gError=:Filter:gError
	Variable/G :Filter:sd
	
	// filter for the first time
	hiroSpike2Filt(w,cutHz1,cutHz2,coef,sBin,nSD)
	
	Variable x0,y0
	Variable width=1000
	Variable height=300
	CenterObjScreen(x0,y0,width,height)
	
	Display/K=2/N=graphBandPass/W=(x0,y0,x0+width,y0+height) as "Separate activity (blue) from baseline (red)"
	
	AppendToGraph/L=customLeft1 w				// original (edited)
	AppendToGraph/L=customLeft2 wHi			// filtered
	AppendToGraph/L=customLeft2 wThresh
	
	ModifyGraph lblPos(customLeft1)=70,freePos(customLeft1)=0,axisEnab(customLeft1)={0.3,1}
	ModifyGraph lblPos(customLeft2)=70,freePos(customLeft2)=0,axisEnab(customLeft2)={0,0.25}
	Label customLeft2 "Activity (SD)"
	
	// stylize threshold line
	ModifyGraph lstyle(wThresh)=2,lsize(wThresh)=0.25
	ModifyGraph rgb(wThresh)=(17408,17408,17408)
	
	// Display y-axis as a multiple of SD
	NVAR sd=:Filter:sd
	ModifyGraph muloffset(wHi)={0,1/sd}
	ModifyGraph muloffset(wThresh)={0,1/sd}
	
	// fill to zero
	ModifyGraph mode(wHi)=7,hbFill(wHi)=4,lsize(wHi)=0
	ModifyGraph rgb(wHi)=(0,0,65280)	// blue
	
	// set up z wave
	ModifyGraph zColor($nameTrace)={wZ,0,1,RedWhiteBlue,0}
	
	ControlBar/L 85
	
	TitleBox titleSpike2FiltBandPass title="Bandpass (Hz):",pos={1,55},frame=0,disable=1
	
	SetVariable setvarSpike2Filtf1 title="",pos={1,72},size={38,16},disable=1
	SetVariable setvarSpike2Filtf1 proc=SetVarProcSpike2Filtf1,value= _NUM:cutHz1
	SetVariable setvarSpike2Filtf1 limits={0,cutHz2,1},live=1,userData=nameTrace
	SetVariable setvarSpike2Filtf1 help={"A lower cutoff in Hz. Hamming window will be used."}
	
	SetVariable setvarSpike2Filtf2 title="-",pos={41,72},size={45,16},disable=1
	SetVariable setvarSpike2Filtf2 proc=SetVarProcSpike2Filtf2,value= _NUM:cutHz2
	SetVariable setvarSpike2Filtf2 limits={cutHz1,0.5/dx,1},live=1,userData=nameTrace
	SetVariable setvarSpike2Filtf2 help={"Up to "+num2str(0.5/dx)+" Hz."}
	
	SetVariable setvarSpike2Filtcoef title="Coef",pos={1,92},size={85,16},disable=1
	SetVariable setvarSpike2Filtcoef proc=SetVarProcSpike2Filtcoef,value= _NUM:coef
	SetVariable setvarSpike2Filtcoef limits={101,4001,1},live=1,userData=nameTrace
	SetVariable setvarSpike2Filtcoef help={"The larger the better the cutoff, but it will be slower. Please be patient."}
	
	SetVariable setvarSpike2FiltBin title="Bin ("+WaveUnits(wHi,0)+")",pos={1,132},size={85,16}
	SetVariable setvarSpike2FiltBin proc=SetVarProcSpike2FiltBin,value= _NUM:sBin
	SetVariable setvarSpike2FiltBin limits={0,inf,0.1},live=1,disable=1
	SetVariable setvarSpike2FiltBin help={"Fills in gaps to connect disjointed activity. Enter 0 for raw activity vs baseline separation."}
	
	SetVariable setvarSpike2FiltThresh title="Thr (SD)",pos={1,152},size={85,16}
	SetVariable setvarSpike2FiltThresh proc=SetVarProcSpike2FiltThresh,value= _NUM:nSD
	SetVariable setvarSpike2FiltThresh limits={0.01,inf,0.1},live=1
	SetVariable setvarSpike2FiltThresh help={"SD of the bottom trace will be used as the threshold to isolate activity from baseline."}
	
	TitleBox titleSpike2FiltEdit title="Is this OK?",pos={1,193},frame=0
	
	Button buttonSpike2FiltEdit title="No",pos={1,210},size={42,20},proc=ButtonProcSpike2FiltEdit
	Button buttonSpike2FiltEdit help={"Click if you want to edit."}
	
	Button buttonSpike2FiltDone title="OK",pos={43,210},size={42,20},proc=ButtonProcSpike2FiltDone
	Button buttonSpike2FiltDone help={"Click if baseline is separated."}
	
	TitleBox titleSpike2FiltError title="",pos={500,50},frame=0
	TitleBox titleSpike2FiltError fColor=(17408,17408,17408)
	TitleBox titleSpike2FiltError labelBack=(65280,65280,32768)
	TitleBox titleSpike2FiltError variable=gError
	
	// init x-axis scrolling
	Variable x1,x2
	x1=leftx(wHi)
	if (rightx(wHi)>20)
		x2=x1+20	// 20 s
	else
		x2=rightx(wHi)
	endif
	
	XAxisScrolling2(x1,x2)
	
	// enter edit mode if no baseline found.
	if (Variance(wZ))
		hiroSpike2FiltShowError("Scroll and check separation of activity and baseline. Adjusting threshold may help.")
	else
		hiroSpike2FiltEditMode()
	endif
	
	PauseForUser graphBandPass
	
End


Function hiroProgressBar()
	// simple progress bar
	
	Variable x0,y0
	Variable width=378
	Variable height=82
	CenterObjScreen(x0,y0,width,height)
	
	NewPanel/N=ProgressPanel/FLT=2/W=(x0,y0,x0+width,y0+height) as "Please wait..."
	ValDisplay valdisp0,pos={18,32},size={342,18}
	ValDisplay valdisp0,limits={0,100,0},barmisc={0,0}
	ValDisplay valdisp0,value= _NUM:0
	ValDisplay valdisp0,mode= 4 // candy stripe
	
End


Function hiroSpike2Filt(w,cutHz1,cutHz2,coef,sBin,nSD)
	
	WAVE w
	Variable cutHz1
	Variable cutHz2
	Variable coef
	Variable sBin
	Variable nSD
	
	// Wait panel
	hiroProgressBar()
	
	Variable fLoEnd,fHiStart,fLoRej,fHiRej
	
	Duplicate/O w,:Filter:wHi	//,:Filter:wZ
	
	WAVE wHi=:Filter:wHi
	//WAVE wZ=:Filter:wZ
	
	Variable dx=deltax(wHi)
	
	//Variable f1=cutHz1*dx		// recommended init fractional frequency for Miriam's data is f1=2/2000=0.001
	//Variable f2=cutHz2*dx		// init f2=5/2000=0.0025
	
	fHiRej=(cutHz1-0.5*cutHz1)*dx	// 2
	fHiStart=cutHz1*dx	// 4
	
	fLoEnd=cutHz2*dx	// 5
	fLoRej=(cutHz2+0.5*cutHz2)*dx	// 7.5
	
	// remove y-units on wHi because it will be displayed as multiples of SD
	SetScale d 0,0,"", wHi
	
	// prepare coefficient for zero-phase filtering
	//Duplicate/FREE wHi,wHi_coef
	Make/FREE/D/N=0 wHi_coef
	
	// Hamming window
	//FilterFIR/HI={fHiRej,fHiStart,coef}/LO={fLoEnd,fLoRej,coef}/WINF=Hamming/COEF wHi_coef
	FilterFIR/HI={fHiRej,fHiStart,coef}/LO={fLoEnd,fLoRej,coef}/COEF wHi_coef
	//FilterFIR/LO={0.0025,0.00275,1010}/HI={0.000875,0.0015,1010}/WINF=Hamming/COEF wHi_coef
	//FilterFIR/COEF/HI={f1,f2,coef}/LO={f1,f2,coef} wHi_coef		// zero-phase coefficient
	
	FilterFIR/COEF=wHi_coef wHi				// filter applied
	
	// IIR
//	FilterIIR/CASC/LO=(f1)/HI=(f2)/COEF wHi_coef
//	FilterIIR/COEF=wHi_coef wHi
	
//	// using fft
//	Duplicate/O $nameTrace,wFFT
//	Redimension /S wFFT
//	FFT/OUT=1/PAD={2097152} wFFT
//	
//	Duplicate/O wFFT,lowPass
//	WAVE lowPass
//	lowPass=lowPass*cmplx(exp(-(p)^2/5),0)
//	IFFT lowPass
//	
//	Duplicate/O wFFT,hiPass
//	
//	hiPass=hiPass*cmplx(1-1/(1+(p-20)^2/2000),0)
//	IFFT hiPass
	
	SetDataFolder :Filter
		
		CurveFit/M=0/N/W=2/Q line, wHi/D
		
		WAVE W_coef
		WAVE fit_wHi
		
	SetDataFolder ::
	
	//Print "-"
	//Print "Slope:",W_coef[0],",score:",1-W_coef[0]
	String str=""
//?	str="Slope: "+num2str(W_coef[0])
	
	// make wHi absolute around zero, then make it absolute
	Variable med
	
	med=StatsMedian(wHi)
	
	//MultiThread wHi-=med		// 21 ms
	MatrixOp/O/NTHR=0 wHi=wHi-med		// 6 ms
	
	// Optionally find derivative
	Differentiate wHi /D=:Filter:wDeriv
	WAVE wDeriv=:Filter:wDeriv
	
	//MultiThread wDeriv=abs(wDeriv)	// 22 ms
	MatrixOp/O wDeriv=mag(wDeriv)	// 10 ms (multithread 11 ms)
	
	//MultiThread wHi=abs(wHi)	// 22 ms
	MatrixOp/O wHi=mag(wHi)		// 10 ms
	
//	// Normalize
//	Variable m
//	m=WaveMax(wDeriv)
//	//MatrixOp/O wDeriv=clip(wDeriv,0,m)		// similar to greater(wDeriv,0), but it retains original y-values
//	
//	//MultiThread wDeriv/=m					// 21 ms
//	MatrixOp/O/NTHR=0 wDeriv=wDeriv/m		// 12 ms
//	
//	m=WaveMax(wHi)
//	
//	//MultiThread wHi/=m
//	MatrixOp/O/NTHR=0 wHi=wHi/m
//	
//	// sum
//	//MultiThread wHi+=wDeriv					// 30 ms
//	MatrixOp/O/NTHR=0 wHi=wHi+wDeriv		// 6 ms
	
	MatrixOp/O/NTHR=0 wHi=wHi/maxVal(wHi)+wDeriv/maxVal(wDeriv)
	
	// Extreme smoothing
	//Smooth/B 1001, wHi
	
	// adjust the curve fitting also
	fit_wHi=-W_coef[1]
	
	//WaveStats wHi
	//Print "Magnitude:",WaveMax(wHi),",score:",WaveMax(wHi)/(WaveMax(w)-WaveMin(w))
//?	str+=", magnitude: "+num2str(WaveMax(wHi))
	
	hiroSpike2FiltShowError(str)
	
	// find sdev
	NVAR sd=:Filter:sd
	sd=sqrt(Variance(wHi))
	//Print "SD:",sd,", inverted:",1/sd
	
	Variable thresh=nSD*sd
	
	hiroSpike2FiltThresh(wHi,sBin,thresh)
	
	DoWindow ProgressPanel
	if (V_flag)
		KillWindow ProgressPanel
	endif
	
End


Function hiroSpike2FiltThresh(wHi,sBin,thresh)
	
	WAVE wHi
	Variable sBin
	Variable thresh
	
	// Update threshold line on the graph
	WAVE wThresh=:Filter:wThresh
	wThresh=thresh
	
	// create the raw wZ (the padding will be added later)
	MatrixOp/O/NTHR=0 :Filter:wZRaw=greater(wHi,thresh)
	WAVE wZRaw=:Filter:wZRaw
	SetScale/P x leftx(wHi),deltax(wHi),"", wZRaw
	
	Extract/O/INDX wHi,:Filter:wINDX,wHi>thresh
	//WAVE wINDX=:Filter:wINDX
	
	// connects disjointed activity by binning
	hiroSpike2FiltBin(:Filter:wINDX,sBin)
	
End


Function hiroSpike2FiltBin(wINDX,sBin)
	// connects disjointed activity in wZ by padding
	
	WAVE wINDX
	Variable sBin
	
	// init wZ
	//wZ=-1
	Duplicate/O :Filter:wZRaw,:Filter:wZ
	WAVE wZ=:Filter:wZ
	
	Variable pad=sBin/deltax(wZ)	// convert to number of points
	
	Variable n=numpnts(wZ)
	Variable p1,p2
	
	Variable i
	
	// slow, inefficient because it cycles through every points in wINDX (7,012 ms)
//	for (i=0;i<numpnts(wINDX);i+=1)
//		p1=wINDX[i]
//		p2=p1+pad
//		if (p2<n-1)
//			wZ[p1,p2]=1
//		else
//			// prevent out of index by filling to the end of the wHi
//			wZ[p1,n-1]=1
//		endif
//	endfor
	
	// faster, skips contiguous portion and fills just the gaps (82 ms)
	Variable nGaps
	DFREF dfr=:Filter
	nGaps=hiroSpike2FilterINDXGap(wINDX,dfr=dfr,nameWGap="wGaps")
	
	WAVE wGaps=:Filter:wGaps
	// i=797, wGaps[i]=270444, wINDX=883938
	for (i=0;i<nGaps;i+=1)
		// Step1: fill the gap with a "bin"
		p1=wINDX[wGaps[i]]
		p2=p1+pad
		
		// Step 2: fill contiguous portion
//		if (i==0)
//			// the first one is exceptional
//			p1=wINDX[0]
//		else
//			p1=wINDX[wGaps[i-1]+1]
//		endif
		
		if (p2<n-1)
			wZ[p1,p2]=1
		else
			// prevent out-of-index by filling to the end of the wHi
			wZ[p1,n-1]=1
		endif
	endfor
	
	// fill activity all the way to the end, if needed
	p1=wINDX[wGaps[numpnts(wGaps)-1]+1]	// the end of final gap
	p2=wINDX[numpnts(wINDX)-1]				// the end
	if (p1<p2)
		wZ[p1,p2]=1
	endif
	
	// check if any baseline was found
	if (Variance(wZ))
		hiroSpike2FiltShowError("")
	else
		hiroSpike2FiltShowError("No baseline found. Edit manually.")
	endif
	
End


Function hiroSpike2FiltShowError(strErr)
	
	String strErr
	
	SVAR gError=:Filter:gError
	
	gError=strErr
	
End


Function hiroSpike2FilterINDXGap(wINDX,[dfr,nameWGap])
	// Break down wINDX into just the points where gap begins; outputs :Filter:wGaps
	
	WAVE wINDX
	DFREF dfr
	String nameWGap
	
//	// method 1: steps (85 ms)
//	Duplicate/FREE wINDX,wINDX_Steps,wFree
//	wFree=0		// init
//	
//	// convolve--this makes wINDX as steps (to facilitate level detection)
//	MultiThread wINDX_Steps-=x
//	
//	Variable n=numpnts(wINDX_Steps)
//	Variable nMax=WaveMax(wINDX_Steps)
//	
//	Variable i
//	Variable pNext
//	
//	do
//		FindLevel/P/Q/R=[pNext,n] wINDX_Steps,wINDX_Steps[pNext]+1
//		if (V_flag)
//			break
//		else
//			i+=1
//			wFree[i]=floor(V_LevelX)
//		endif
//		pNext=wFree[i]+1
//	while(wINDX_Steps[pNext]<nMax)
//	
//	// trim wSteps
//	Extract/O wFree,:Filter:wGaps,wFree>0
//	
//	//Print i,numpnts(:Filter:wGaps),"gaps"
//	
//	// method 2: old fashioned way (119 ms)
//	Duplicate/FREE wINDX,wFree
//	wFree=0
//	i=0
//	Variable j
//	for(i=0;i<n-1;i+=1)
//		if (wINDX[i]<wINDX[i+1]-1)
//			wFree[j]=i
//			j+=1
//		endif
//	endfor
//	
//	Extract/O wFree,:Filter:wGaps,wFree>0
	
	// method 3: use derivative (38 ms)
	Differentiate wINDX /D=:Filter:wDerivative
	WAVE wDerivative=:Filter:wDerivative
	
	// wINDX has a slope of 1. Extract any instances where the slope is greater or equal.
	Extract/INDX/FREE wDerivative,wFree3,wDerivative>1
	
	// extract just the even points (derivative contains an extra point for every change)
	//Extract wFree3,:Filter:wGaps,mod(p,2)==0
	if (!strlen(nameWGap))
		nameWGap="wGap"
	endif
	if (!DataFolderRefStatus(dfr))
		dfr=GetDataFolderDFR()
	endif
	Extract/O wFree3,dfr:$nameWGap,mod(p,2)==0
	
	// to see where the gap starts, e.g., do pnt=wINDX[wGaps[0]] and use the point on CaRec1
	// note that from CaRec1[0] to CaRec1[wINDX[0]] can be a gap that is not found in wGaps
	
	//return numpnts(:Filter:wGaps)
	return numpnts(dfr:$nameWGap)
	
End


Function SetVarProcSpike2Filtf1(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfrC=:FilterCache
			
			WAVE wHi=:Filter:wHi
			
			Variable dx=deltax(wHi)
			
			SetVariable setvarSpike2Filtf2 limits={dval,0.5/dx,1}
			
//			ControlInfo setvarSpike2Filtf2
//			Variable f2=V_Value*dx
			NVAR cutHz2=dfrC:cutHz2
			
//			ControlInfo setvarSpike2Filtcoef
//			Variable coef=V_Value
			NVAR coef=dfrC:coef
			
//			ControlInfo setvarSpike2FiltBin
//			Variable sBin=V_Value
			NVAR sBin=dfrC:sBin
			
//			ControlInfo setvarSpike2FiltThresh
//			Variable nSD=V_Value
			NVAR nSD=dfrC:nSD
			
			WAVE w=TraceNameToWaveRef("graphBandPass",sva.userData)
			
			hiroSpike2Filt(w,dval,cutHz2,coef,sBin,nSD)
			
			// Save
			NVAR cutHz1=dfrC:cutHz1
			cutHz1=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function SetVarProcSpike2Filtf2(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfrC=:FilterCache
			
//			WAVE wHi=:Filter:wHi
//			
//			Variable dx=deltax(wHi)
			
			SetVariable setvarSpike2Filtf1 limits={0,dval,1}
			
//			ControlInfo setvarSpike2Filtf1
//			Variable f1=V_Value*dx
			NVAR cutHz1=dfrC:cutHz1
			
//			ControlInfo setvarSpike2Filtcoef
//			Variable coef=V_Value
			NVAR coef=dfrC:coef
			
//			ControlInfo setvarSpike2FiltBin
//			Variable sBin=V_Value
			NVAR sBin=dfrC:sBin
			
//			ControlInfo setvarSpike2FiltThresh
//			Variable nSD=V_Value
			NVAR nSD=dfrC:nSD
			
			WAVE w=TraceNameToWaveRef("graphBandPass",sva.userData)
			
			hiroSpike2Filt(w,cutHz1,dval,coef,sBin,nSD)
			
			// Save
			NVAR cutHz2=dfrC:cutHz2
			cutHz2=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function SetVarProcSpike2Filtcoef(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfrC=:FilterCache
			
			WAVE wHi=:Filter:wHi
			
			Variable dx=deltax(wHi)
			
//			Variable coef=dval
			
//			ControlInfo setvarSpike2Filtf1
//			Variable f1=V_Value*dx
			NVAR cutHz1=dfrC:cutHz1
			
//			ControlInfo setvarSpike2Filtf2
//			Variable f2=V_Value*dx
			NVAR cutHz2=dfrC:cutHz2
			
//			ControlInfo setvarSpike2FiltBin
//			Variable sBin=V_Value
			NVAR sBin=dfrC:sBin
			
//			ControlInfo setvarSpike2FiltThresh
//			Variable nSD=V_Value
			NVAR nSD=dfrC:nSD
			
			WAVE w=TraceNameToWaveRef("graphBandPass",sva.userData)
			
			hiroSpike2Filt(w,cutHz1,cutHz2,dval,sBin,nSD)
			
			// Save
			NVAR coef=dfrC:coef
			coef=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2FiltBin(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfrC=:FilterCache
			
			WAVE wZ=:Filter:wZ
			
			WAVE wINDX=:Filter:wINDX
			
			hiroSpike2FiltBin(wINDX,dval)
			
			// Save
			NVAR sBin=dfrC:sBin
			sBin=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcSpike2FiltThresh(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfrC=:FilterCache
			
			WAVE wHi=:Filter:wHi
			
//			ControlInfo setvarSpike2FiltBin
//			Variable sBin=V_Value
			NVAR sBin=dfrC:sBin
			
			Variable sd=sqrt(Variance(wHi))
			Variable thresh=dval*sd
			
			hiroSpike2FiltThresh(wHi,sBin,thresh)
			
			// Save
			NVAR nSD=dfrC:nSD
			nSD=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2FiltEdit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2FiltEditMode()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcSpike2FiltSkip(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			DoAlert/T="Skip for sure?" 2, "This may negatively affect baseline detection later.\r\rAre you sure to skip? Cancel will end."
			if (V_flag==1)
				KillWindow graphBandPass
				KillDataFolder :Filter
				KillDataFolder :FilterCache
			elseif (V_flag==3)
				KillWindow graphBandPass
				KillDataFolder :Filter
				KillDataFolder :FilterCache
				Print "User canceled procedure"
				Abort
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2FiltEditMode()
	
	TitleBox titleSpike2FiltBandPass disable=0
	
	SetVariable setvarSpike2Filtf1 disable=0
	SetVariable setvarSpike2Filtf2 disable=0
	SetVariable setvarSpike2Filtcoef disable=0
	SetVariable setvarSpike2FiltBin disable=0
	//SetVariable setvarSpike2FiltThresh disable=0
	
	TitleBox titleSpike2FiltEdit title="Edit and click OK"
	
	Button buttonSpike2FiltEdit disable=1
	
	Button buttonSpike2FiltSkip title="Skip",pos={1,210},size={42,20},proc=ButtonProcSpike2FiltSkip
	Button buttonSpike2FiltSkip help={"Click if you want to skip this step."}
	
End


Function ButtonProcSpike2FiltDone(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroSpike2Filt2Baseline()
			hiroSpike2MakeBaselineLib()
			
			KillWindow graphBandPass
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroSpike2Filt2Baseline()
	// Extract baseline from wZ, then make a library of baseline values for later use
	
	WAVE wZ=:Filter:wZ
	
	if (DataFolderExists(":Baseline"))
		KillDataFolder :Baseline
	endif
	NewDataFolder :Baseline
	DFREF dfr=:Baseline
	
	// get indeces of baseline
	Extract/INDX wZ,dfr:wINDX,wZ==0
	WAVE wINDX=dfr:wINDX	// indeces of baseline
	
	// find gaps
	Variable nGaps
	nGaps=hiroSpike2FilterINDXGap(wINDX,dfr=dfr,nameWGap="wGaps")
	
	WAVE wGaps=dfr:wGaps
	
	Variable n=numpnts(wGaps)
	Make/N=(n+1) dfr:wBaseOnLoc,dfr:wBaseOffLoc
	
	WAVE wBaseOnLoc=dfr:wBaseOnLoc
	WAVE wBaseOffLoc=dfr:wBaseOffLoc
	
	Variable bootsActivity
	if (wINDX[0])
		bootsActivity=1
		wBaseOnLoc[0]=wINDX[0]
	endif
	
	Variable endsActivity
	if (wINDX[numpnts(wINDX)-1]<numpnts(wZ)-1)
		endsActivity=1
	endif
	
	Variable i
	for (i=0;i<n;i+=1)
		//if (bootsActivity)
		//	wBaseOnLoc[i]=wINDX[wGaps[i]+1]
		//else
			wBaseOnLoc[i+1]=wINDX[wGaps[i]+1]	// the very first point is skipped
		//endif
		wBaseOffLoc[i]=wINDX[wGaps[i]]
	endfor
	
	if (endsActivity)
		// fill the last slot manually
		wBaseOffLoc[numpnts(wBaseOffLoc)-1]=wINDX[numpnts(wINDX)-1]
	endif
	
End


Function hiroSpike2MakeBaselineLib()
	// find median baseline for each pair of wBaseOnLoc and wBaseOffLoc
	
	//? get the name of the trace--alternatively, you can find this in the cache
	ControlInfo setvarSpike2Filtf1
	String nameTrace=S_UserData
	
	WAVE w=TraceNameToWaveRef("graphBandPass",nameTrace)
	
	DFREF dfr=:Baseline
	
	WAVE wOnLoc=dfr:wBaseOnLoc
	WAVE wOffLoc=dfr:wBaseOffLoc
	
	Variable n=numpnts(wOnLoc)
	
	Make/D/O/N=(n) dfr:wBaseline
	WAVE wBaseline=dfr:wBaseline
	
	Variable i
	for(i=0;i<n;i+=1)
		Duplicate/FREE/R=[wOnLoc[i],wOffLoc[i]] w,wFree
		wBaseline[i]=StatsMedian(wFree)
	endfor
	
End