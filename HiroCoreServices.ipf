#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.55		// version of procedure
#pragma IgorVersion=6.2

#include <AxisSlider>
#include <XY Pair To Waveform>

// Written by Hirofumi Watari, Ph.D. © 2010-2016.  All rights reserved.
// This ipf is shared among HiroImaging.ipf, HiroEEG.ipf, HiroSpike2.ipf

// What's new in HiroCoreServices 1.55 (2016-11-02);UI change on X-axis scrolling;---
// What's new in HiroCoreServices 1.54 (2016-10-10);CenterObjScreen now supports screen DPI on Windows;---
// What's new in HiroCoreServices 1.53 (2016-10-08);CheckDFDuplicates now supports non-liberal names in the data folder;The new Data Folder name now increments properly;---
// What's new in HiroCoreServices 1.52 (2016-08-23);Fixed a bug that causes an error when duplicating a Data Folder with its name longer than 31 characters;---
// What's new in HiroCoreServices 1.51 (2016-07-22);Fixed a bug that fails to load a text file under rare condition;---
// What's new in HiroCoreServices 1.50 (2016-05-13);Fixed a bug that causes an inconsistent result in a multi-threaded process under certain condition;---
// What's new in HiroCoreServices 1.49 (2016-05-05);Supports multi-threaded separation of columns from matrix;---
// What's new in HiroCoreServices 1.48 (2016-04-26);Supports a timer function similar to MATLAB's tic and toc;---
// What's new in HiroCoreServices 1.47 (2016-04-25);Introduces AI that helps your workflow when opening a file;---
// What's new in HiroCoreServices 1.46 (2016-04-14);Minor update;---
// What's new in HiroCoreServices 1.45 (2016-04-08);Introducing the new X-axis scrolling version 2;---
// What's new in HiroCoreServices 1.44 (2016-03-22);Adds support for multithreading;---
// What's new in HiroCoreServices 1.43 (2016-03-16);Supports new binary file format;---
// What's new in HiroCoreServices 1.42 (2016-02-28);Minor update;---
// What's new in HiroCoreServices 1.41 (2016-02-23);CheckDFDuplicates now returns DF name;updated AboutScripts;---
// What's new in HiroCoreServices 1.40 (2016-02-21);XAxisScrolling moved to Core Services;---
// What's new in HiroCoreServices 1.39 (2016-02-18);Complies with rtGlobals 3;---
// What's new in HiroCoreServices 1.38 (2016-02-18);ImportLOGintoNotebook moved to Core Services;---
// What's new in HiroCoreServices 1.37 (2016-02-12);CheckDFDuplicates, etc. moved to Core Services;---
// What's new in HiroCoreServices 1.36 (2015-08-20);Logs an error under rare instances when the ANOVA is run on bad sample size;---
// What's new in HiroCoreServices 1.35 (2015-08-18);Supports cleaner report in the history for automated stats;---
// What's new in HiroCoreServices 1.34 (2015-08-05);Supports a new X scrolling feature (the original is found in BosmaImaging);---
// What's new in HiroCoreServices 1.33 (2015-07-31);Supports fully automated graph and stats;Functions for grouping pxps for phase 2 transferred from BosmaEphys;---
// What's new in HiroCoreServices 1.32 (2015-07-30);Stats on demand auto-skip groups with no data (i.e., n=0);---
// What's new in HiroCoreServices 1.31 (2015-06-12);Minor update;---
// What's new in HiroCoreServices 1.30 (2015-04-13);GetFileInfo, CreateAnalysisDF moved to Core Services;---
// What's new in BosmaCoreServices 1.29 (2015-04-01);Updated import of general binary file;---
// What's new in BosmaCoreServices 1.28 (2015-02-24);Updated Author info;Added support for loading general binary file;---
// What's new in BosmaCoreServices 1.27 (2015-02-05);Experiment info now creates WinGlobals DF when it does not already exist;---
// What's new in BosmaCoreServices 1.26 (2013-03-07);Author info was updated;---
// What's new in BosmaCoreServices 1.25 (2013-04-10);Supports measurement of x-interval between two cursors on the top graph (for Amanda Danger Tose);---
// What's new in BosmaCoreServices 1.24 (2013-02-28);Fixed a bug where paired t-test was attempted between waves of different sample sizes;---
// What's new in BosmaCoreServices 1.23 (2013-02-14);Supports comments detection in Metafluor log files;---
// What's new in BosmaCoreServices 1.22 (2012-08-17);Features Paired T-test (you will see this in the history section when you do stats);---
// What's new in BosmaCoreServices 1.21 (2011-12-01);Now prints p-value in non-scientific notation;---
// What's new in BosmaCoreServices 1.20 (2011-11-07);Fixed a minor bug where it prints out the same p-value twice in certain cases;---
// What's new in BosmaCoreServices 1.19 (2011-10-30);Fixed a minor bug for an ephys function;---
// What's new in BosmaCoreServices 1.18 (2011-10-29);Supports automatic printing of all visible layouts;---
// What's new in BosmaCoreServices 1.17 (2011-10-27);Supports automatic drawing of stimulus bars;---
// What's new in BosmaCoreServices 1.16 (2011-10-19);Supports the new layout for current clamp traces;---
// What's new in BosmaCoreServices 1.15 (2011-10-03);Adjusted position of the stimulus bars;---
// What's new in BosmaCoreServices 1.14 (2011-09-25);Added support for converting YYYY-MM-DD hh:mm:ss into Igor Pro seconds format;---
// What's new in BosmaCoreServices 1.13 (2011-04-08);Prints p-values for every statistical analyses done;---
// What's new in BosmaCoreServices 1.12 (2011-02-28);Supports tags in new mini graphs;---
// What's new in BosmaCoreServices 1.11 (2010-10-24);Supports color palette in Plot Mean function;New color scheme;---
// What's new in BosmaCoreServices 1.10 (2010-10-21);Improved peak analysis algorithm;---
// What's new in BosmaCoreServices 1.09 (2010-10-21);Dunnett and/or Tukey test will be done as a post-hoc test in Plot Mean function;Improved peak analysis algorithm;Analyzed peak values are now automatically copied onto the clipboard (so you can paste into Excel, etc.);---
// What's new in BosmaCoreServices 1.08 (2010-10-19);Added an Analyze Peak function to the waterfall plots;---
// What's new in BosmaCoreServices 1.07 (2010-10-17);Updates in Plot Mean fuction;Now tags sample sizes to the graph;Now automatically assigns a new graph name if it already exists;Now reports n.s. in history when ANOVA returns non-significant result;Now returns focus to the selected Data Folder at the end;---
// What's new in BosmaCoreServices 1.06 (2010-10-14);Minor update;---
// What's new in BosmaCoreServices 1.05 (2010-10-13);Supports Plot Mean function under Imaging menu;---
// What's new in BosmaCoreServices 1.03 (2010-10-09);Automatic update via internet is now available;---


Constant kHWStandardButtonHeight = 20		// referenced in BosmaImaging and BosmaCoreServices


Function ImportLOGintoNotebook()
		
	String strWinName = "ImageLog"
	
	SVAR fileName = fileName
	SVAR folderPath = folderPath
	NewPath/O/Q path, folderPath
	
	// Kill Log Window if it already exists
	DoWindow/K $strWinName
	
	OpenNotebook/K=1/N=$strWinName/P=path fileName
	
	DoWindow $strWinName	// Check if window exists
	
	if (V_flag == 1)	// Window exists
		MoveWindow/W=$strWinName 1000,0,1400,150
	endif
	
End


Function ShowCursors()
	
	String list=TraceNameList("",";",5)	// get a list of normal, visible trace names
	String traceName = StringFromList(0, list)	// get a name of a first on the list
	
	// Find min and max of X axis that are visible on graph
	GetAxis/Q bottom
	
	Variable pos40 = V_min + (V_max - V_min)*0.4	// location 40% from minimum
	Variable pos60 = V_max - (V_max - V_min)*0.4	// location 60% from minimum
	Cursor A $traceName pos40
	Cursor B $traceName pos60
	
End


Function HideCursors()
	
	Cursor/K A
	Cursor/K B
	
End


Function XAxisScrolling()
	// Zoom in on x-axis and enable WM's Axis Slider
	Variable x1,x2
	
	// Find current x1 position
	GetAxis/Q bottom
	
	x1=V_min
	x2=V_max
	
	Prompt x1, "From - hit a tab-key to go to next one"
	Prompt x2, "To"
	DoPrompt/HELP="Enter a number. Hit a tab-key to toggle between the two fields." "Resize X-Axis",x1,x2
	
	if (V_flag == 1)
		Print "User Canceled Procedure"
		Abort	//quit if cancel button was clicked
	endif

	SetAxis bottom x1,x2
	WMAppendAxisSlider()	// Call function in AxisSlider.ipf
	
	//ShowVerticalLine()
	ModifyGraph grid(bottom)=1
End


Function XAxisScrolling2(x1,x2)
	// Zoom in on x-axis and enable WM's Axis Slider
	Variable x1,x2
	
	if (x1==x2)
		// Find current x1 position
		GetAxis/Q bottom
		
		x1=V_min
		x2=V_max
		
		Prompt x1, "From - hit a tab-key to go to next one"
		Prompt x2, "To"
		DoPrompt/HELP="Enter a number. Hit a tab-key to toggle between the two fields." "Resize X-Axis",x1,x2
		
		if (V_flag == 1)
			Print "User Canceled Procedure"
			Abort	//quit if cancel button was clicked
		endif
	endif

	SetAxis bottom x1,x2
	ControlInfo WMAxSlSl
	// for some reason V_flag, as in the manual, is not there--it has to be V_Flag (the case matters here)
	if (V_Flag)
		// remove the existing slider
		WMAxSlPopProc("WMAxSlSl",3,"Resync position")
	else
		WMAppendAxisSlider()	// Call function in AxisSlider.ipf
			
		// Customize control
		KillControl WMAxSlPop
		Button buttonKillXAS title="X",pos={3,10},size={20,20},proc=ButtonProcKillXAS
		Button buttonInfoXAS title="i",pos={28,10},size={20,20},proc=ButtonProcInfoXAS
		Slider WMAxSlSl side=1
	endif
	
	//ShowVerticalLine()
	//ModifyGraph grid(bottom)=1
End


Function ButtonProcKillXAS(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			KillControl buttonKillXAS
			KillControl buttonInfoXAS
			WMAxSlPopProc("WMAxSlSl",5,"Remove")
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcInfoXAS(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			XAxisScrolling2(0,0)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckStrInThisList(str,list)
	// Checks if the string exists in the list
	
	String str
	String list
	
	return StringMatch(list,"*"+str+"*")		// 1=str is in the list, 0=no match, NaN=ran out of memory
	
End


Function PrintVisibleLayouts(mode)
	
	Variable mode	// 0 for prompt first, 1 for automatic printing of top layout, 2 for automatic printing of all visible layouts
	
	String listLayout=WinList("*",";","WIN:4,VISIBLE:1")	// List all visible layouts
	String nameLayout
	Variable i=0
	
	// Bring all layouts on the top and autoposition
	do
		nameLayout = StringFromList(i, listLayout, ";")
		if (strlen(nameLayout)==0)
			break
		else
			DoWindow/F $nameLayout
			AutoPositionWindow/E/M=0 $nameLayout
		endif
		i+=1
	while(1)
	
	if (mode == 0)
		DoAlert 2, "Print all layouts on screen?\r\r(You can decide to print from the Print Layouts menu later)"
		if (V_flag>1)
			return -1
		endif
	endif
	
	i=0	// reset
	do
		nameLayout = StringFromList(i, listLayout, ";")
		if (strlen(nameLayout)==0)
			break
		else
			PrintLayout $nameLayout
			if (mode == 1)
				break
			endif
		endif
		i+=1
	while(1)
	
End


Function EnterExptInfo()

	SVAR/Z hbnum = root:WinGlobals:numHB
	SVAR/Z hbage = root:WinGlobals:ageHB
	SVAR/Z hbnote = root:WinGlobals:noteHB
	SVAR/Z hbcode = root:WinGlobals:codeHB
	SVAR/Z hbdude = root:WinGlobals:dudeHB

	String num = StrVarOrDefault("root:WinGlobals:numHB","M0")
	String age = StrVarOrDefault("root:WinGlobals:ageHB","p")
	String comment = StrVarOrDefault("root:WinGlobals:noteHB","")
	String code = StrVarOrDefault("root:WinGlobals:codeHB","")
	String dude = StrVarOrDefault("root:WinGlobals:dudeHB","Hiro")
	
	if (!DataFolderExists("root:WinGlobals"))
		NewDataFolder root:WinGlobals
	endif
	
	if (!SVAR_Exists(hbnum))
		String/G root:WinGlobals:numHB
	endif
	
	if (!SVAR_Exists(hbage))
		String/G root:WinGlobals:ageHB
	endif
	
	if (!SVAR_Exists(hbnote))
		String/G root:WinGlobals:noteHB
	endif
	
	if (!SVAR_Exists(hbcode))
		String/G root:WinGlobals:codeHB
	endif
	
	if (!SVAR_Exists(hbdude))
		String/G root:WinGlobals:dudeHB
	endif
	
	Prompt num, "Experiment ID (e.g., \"M001\")"
	Prompt age, "Age (e.g., \"P12\")"
	Prompt code, "Special Code (e.g., \"Cs\" to indicate CsMeSO4 internal), if any"
	Prompt comment, "Short comment, if any"
	Prompt dude, "Experimenter"
	DoPrompt "Enter Experiment Info",num,age,code,comment,dude
	
	// Store global variable
	SVAR hbnum = root:WinGlobals:numHB
	SVAR hbage = root:WinGlobals:ageHB
	SVAR hbnote = root:WinGlobals:noteHB
	SVAR hbcode = root:WinGlobals:codeHB
	SVAR hbdude =  root:WinGlobals:dudeHB
	hbnum = num
	hbage = age
	hbnote = comment
	hbcode = code
	hbdude = dude
	
End


Function PlaceButtonToShowCursors()
// Places an "X-Axis Scrolling" button on a top graph.
	
	Button buttonCursors title="Show Cursors",pos={640,50},size={100,kHWStandardButtonHeight},proc=ButtonCursorsProc
	Button buttonCursors help={"Click this button to show or hide cursors"}
	
End


Function PlaceButtonToZoomBetweenCursors()
// Places an "Analyze Peak" button on a top graph.  Formerly called "Zoom" button
	
	Button buttonZoomBetweenCursors title="Analyze Peak",pos={750,50},size={100,kHWStandardButtonHeight},proc=ButtonZoomBetweenCursorsProc
	Button buttonZoomBetweenCursors help={"Click this button to zoom in between cursors"}
	
End


Function ButtonCursorsProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			// Graph Name of the top graph	
			String graphName = WinName(0,1)
			
			Variable aExists= strlen(CsrInfo(A,graphName)) > 0	// A is a name, not a string
			Variable bExists= strlen(CsrInfo(B,graphName)) > 0
			
			if (aExists && bExists)
				HideCursors()
				Button buttonCursors title="Show Cursors"
				Button buttonZoomBetweenCursors disable=2
			else
				HideCursors()
				ShowCursors()
				Button buttonCursors title="Hide Cursors"
				PlaceButtonToZoomBetweenCursors()
				Button buttonZoomBetweenCursors disable=0
			endif
						
			break
	endswitch

	return 0
End


Function ButtonZoomBetweenCursorsProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			// If cursors A and B are on a trace in the waterfall plot,
			// this function will pop a zoomed in graph and lets the user
			// analyze peak of a spike.  It only works on waterfall plots.
			String graphName=WinName(0,1)
			Variable aExists= strlen(CsrInfo(A,graphName)) > 0	// A is a name, not a string
			Variable bExists= strlen(CsrInfo(B,graphName)) > 0
			
			if (!aExists || !bExists)
				Button buttonCursors title="Show Cursors"
				Abort "Error: Two cursors must be present on a trace.\r\rClick \"Show Cursors\" button and try again."
			endif
			
			if (qcsr(A) != qcsr(B))
				Abort "Error: Two cursors must be on the same trace.\r\rMove a cursor to the same trace as the other cursor and try again."
			endif
			
			// FindPeak function only works on 1D wave.  So extract 1D from the 3D wave
			WAVE Time_min
			Extract3Dinto1DWave(Time_min)
			
			PlaceButtonToAnalyzePeak()
			
			PeakAnalysis()
			
			break
	endswitch

	return 0
End


Function CheckCursorPositions()
// If Cursor A is right of B, flip position
	
	Variable xA = xcsr(A)
	Variable xB = xcsr(B)
	
	String traceName = CsrWave(A)
	
	if (xA>xB)
		Cursor A $traceName xB
		Cursor B $traceName xA
	endif
	
End


Function CopyXintervalAtoB()
	
	// xcsr cannot measure X-value in Igor Pro when X vs Y plot is made.  So, we will find the point number, 
	// cross-reference with Time_sec wave
	
	WAVE w=Time_sec
	
	Variable timeA = w[pcsr(A)]
	Variable timeB = w[pcsr(B)]
	
	Variable interval = abs(timeA-timeB)
	
	Print interval,"s (copied on the clipboard)"
	
	// Put this in clipboard
	PutScrapText num2str(interval)
	
End


Function PeakAnalysis()
// Analyzes positive peak in between cursors A and B
	
	String nameW = CsrWave(A)
	Variable amplitude,peakWidth,tau
	
	// Check to make sure the cursor is still on the graph to avoid error
	String graphName=WinName(0,1)
	Variable aExists= strlen(CsrInfo(A,graphName)) > 0	// A is a name, not a string
	Variable bExists= strlen(CsrInfo(B,graphName)) > 0
	
	if (!aExists)
		GetAxis/Q bottom
		if (bExists)
			nameW = CsrWave(B)
		else
			ShowCursors()
			nameW = CsrWave(A)
		endif
		Cursor A $nameW V_min
	endif
	
	if (!bExists)
		GetAxis/Q bottom
		Cursor B $nameW V_max
	endif
	
	CheckCursorPositions()
	
	Variable threshold = vcsr(A)+0.01
	
	FindPeak/Q/M=(threshold)/R=(xcsr(A),xcsr(B)) $nameW
	
	if (V_flag == 0)
		
		// Find the peak more accurately than FindPeak (no interpolation)
		WaveStats/R=(xcsr(A),xcsr(B))/Q $nameW
		amplitude = V_max - vcsr(A)
		
		Tag/C/N=peak/F=0/X=0/Y=0/B=1/L=0/G=(0,0,65535)/Z=1 $nameW, V_maxloc, "ð"
		
		// Clear previous drawing if there is any
		DrawAction delete
		
		// Draw a vertical line for amplitude
		SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linefgc= (30583,30583,30583)
		DrawLine V_maxloc, vcsr(A), V_maxloc, V_max
		
		// Draw a horizontal line for baseline
		SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linefgc= (30583,30583,30583)
		DrawLine xcsr(A),vcsr(A), xcsr(B),vcsr(A)
		
		Variable startLevel = V_max
		Variable endLevel = vcsr(A)
		PulseStats/L=(startLevel,endLevel)/R=(xcsr(A),xcsr(B))/Q $nameW
		
		if (V_flag < 2)
			if (numtype(V_PulseWidth2_1)==0)	// 0 means normal number.
				// Draw a horizontal line for peak width
				SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linefgc= (30583,30583,30583)
				DrawLine V_PulseLoc1,V_PulseLvl123, V_PulseLoc2,V_PulseLvl123
				peakWidth = (V_PulseLoc2-V_PulseLoc1)*60
			else
				Abort "Full Width Half Maximum could not be found.\r\rMake sure that both cursors are placed below the half maximum amplitude and try again."
			endif
		else
			Abort "Full Width Half Maximum could not be found.\r\rMake sure that both cursors are placed below the half maximum amplitude and try again."
		endif
		
		WAVE w=$nameW
		
		DFREF dfr=GetDataFolderDFR()
			// Curve fitting to decaying phase, starting from the peak
			NewDataFolder/O/S CurveFitting
			CurveFit/NTHR=0/N=1/Q exp_XOffset, w(V_maxloc,xcsr(B))/D
			WAVE w=W_coef
			tau=w[2]*60
		SetDataFolder dfr
		
		String scrap= num2str(amplitude)+"\t"+num2str(peakWidth)+"\t"+num2str(tau)
		PutScrapText scrap		// copy the results into clipboard (so it can be pasted into other programs)
		
		Print "¥ Find a peak between",xcsr(A),"(cursor A) and",xcsr(B),"(cursor B) minutes"
		Print "¥ The following values are copied to the clipboard:"
		Print "Amplitude:",amplitude
		Print "Width:",peakWidth,"seconds"
		Print "Tau:",tau,"seconds"
		Print "\r"
		
	else
		Abort "Peak could not be found.\r\rBring cursors closer to the beginning and end of a spike and try again."
	endif
	
	ZoomInTraceBetweenCursors()
	
End


Function PlaceButtonToAnalyzePeak()
// Places an "Analyze" button on graphSpike inside the control bar.
	
	ControlBar/B/W=graphSpike 30
	
	// Find a height and width of the window so you can place button at the bottom right.
	GetWindow graphSpike wsize
	Variable height = V_bottom-V_top
	Variable width = V_right-V_left
	Variable buttonWidth = 100
	Variable x=width-buttonWidth-25
	Variable y=height-kHWStandardButtonHeight-5
	Button buttonAnalyzePeak title="Analyze Peak",pos={x,y},size={buttonWidth,kHWStandardButtonHeight},proc=ButtonAnalyzePeakProc
//	Button buttonAnalyzePeak title="Analyze Peak",pos={260,300},size={100,kHWStandardButtonHeight},proc=ButtonAnalyzePeakProc
	Button buttonAnalyzePeak help={"Bring cursors closer to the beginning and ending of a spike.\r\rClick this button to analyze a peak in between the cursors.\r\rResults will be written in the command window."}
	
	// Add a cancel button to the left of this button.
	PlaceButtonToCancelGraph(x,y,buttonWidth)
	
End


Function PlaceButtonToCancelGraph(x,y,buttonWidth)
// Places an "Cancel" button to the left of the action button inside a top graph.
	
	Variable x,y,buttonWidth		// button Width of a action button
	
	x=x-buttonWidth+10
	
	Button buttonCancel title="Cancel",pos={x,y},size={75,kHWStandardButtonHeight},proc=ButtonCancelGraphProc
	Button buttonCancel help={"Click this button to cancel."}
	
End


Function ButtonAnalyzePeakProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			PeakAnalysis()
			break
	endswitch

	return 0
End


Function ButtonCancelGraphProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			String graphName=WinName(0,1)
			DoWindow/K $graphName
			break
	endswitch

	return 0
End


Function Extract3Dinto1DWave(Time_min)
// and display a resulting 1D wave between two cursor points
	
	WAVE Time_min
	
	// Graph Name of the top graph	
	String graphName = WinName(0,1)

	Variable aExists= strlen(CsrInfo(A,graphName)) > 0	// A is a name, not a string
	Variable bExists= strlen(CsrInfo(B,graphName)) > 0
//	Variable nData= NumberByKey("POINT",CsrInfo(A)) - NumberByKey("POINT",CsrInfo(A))
	
	// When cursor A is on a trace of 2D wave, extract that layer into a 1D wave
	String nameW = CsrWave(A,graphName)
	Variable nData = DimSize($nameW,0)		// DimSize is like a numpnts for multidimentional waves
	
	WAVE w2d=$nameW
	
	Make/O/N=(nData) wSpike

	//wave0 = wave0_2D[p][0]	// Extract column 0 into 1D wave
	wSpike = w2d[p][qcsr(A,graphName)]
	
	DoWindow/K graphSpike
	
	Variable x0,y0,width=400,height=300
	
	CenterObjScreen(x0,y0,width,height)
	
	Display/N=graphSpike/W=(x0,y0,x0+width,y0+height)/K=1 wSpike as "Analyzing Peak"
	ModifyGraph rgb=(0,0,0)	// black trace
	
	// Make X-Axis scale of the wSpike into minutes
	SetScale/I x WaveMin(Time_min), WaveMax(Time_min), wSpike
	
	// Find the cursor points A and B on wSpike
	Cursor A wSpike xcsr(A,graphName)
	Cursor B wSpike xcsr(B,graphName)
	
	CheckCursorPositions()
	
	ZoomInTraceBetweenCursors()
	
End


Function ZoomInTraceBetweenCursors()
// If cursors A and B are on the trace, zoom in to fill that trace on a graph
	
	String graphName=WinName(0,1)	// top graph
	String trace=CsrWave(A,graphName)
	
	// Zoom in X-Axis
	SetAxis bottom xcsr(A,graphName)-0.1,xcsr(B,graphName)+0.1	// 0.1 adds padding
	
	// Zoom in Y-Axis
	SetAxis left WaveMin($trace, xcsr(A,graphName),xcsr(B,graphName)),WaveMax($trace, xcsr(A,graphName),xcsr(B,graphName))
	
End


Function StatsOnDemand(list,skipprompt,matchStr,nameDF)

	String list	// Separated by semicolons
	Variable skipprompt	// 0=prompt as usual; 1=skip prompt, the first wave in the list is the control, 2=skip, the first is not the control
	String matchStr		// e.g., " c V1 Stim".  When set, this string will be removed from printing the result of post-hoc test
	String nameDF		// for error detection only
	
	// Check if each group has at least one data point, if not remove the group from the list
	String ListOfWaves=""	// len is zero if declared as ""
	String nameW
	Variable i
	for(i=0;i<ItemsInList(list);i+=1)
		nameW=StringFromList(i,list)
		WaveStats/M=1/Q $nameW
		if (V_npnts)	// V_npnts is zero if wave is all NaNs
			ListOfWaves+=nameW+";"
		endif
	endfor
	
	if (!strlen(ListOfWaves))
		ListOfWaves=list
	endif
	//Print ListOfWaves
	
	Variable nGroups=ItemsInList(ListOfWaves)
	
	if (nGroups<2)
		if (skipprompt)
			Print "-Skipped.  There is not enough number of groups to run statistics."
		else
			DoAlert 0,"There is not enough number of groups to run statistics."
		endif
		return -1
	endif
	
	Variable len=strlen(ListOfWaves)
	if (len  == 0 || numtype(len) == 2)
		// Do stats on all waves in current DF
		//ListOfWaves = WaveList("*",";","")
		//ListOfWaves = SortList(ListOfWaves,";",16)
		if (skipprompt)
			Print "The selected dataset is empty. Try again."
		else
			DoAlert 0,"The selected dataset is empty\rTry again."
		endif
		return -1
	endif
	
	StatsAnova1Test/Q/Z/WSTR=ListOfWaves
	if (V_flag==-1)
		LogError("Problem detected during Stats On Demand in "+nameDF)
		return -1
	endif
	
	WAVE M_ANOVA1
	Variable Significant
	String Stars
	
	Significant = CheckPValue(M_ANOVA1[2][5])
	
	// Post hoc tests
	if (Significant)
		if (nGroups > 2)
			Print "One-way ANOVA",GiveStars(Significant, M_ANOVA1[2][5],1)
			Print "\r"
			
			if (!skipprompt)
				String strPrompt="Is \""+StringFromList(0,ListOfWaves)+"\" the only control group?"
				DoAlert/T="Deciding an appropriate post-hoc test" 1,strPrompt
				skipprompt=V_flag
			endif
			if (skipprompt == 1)	// yes
				// Do Dunnett test - first wave on the list must be a control
				StatsDunnettTest/SWN/WSTR=ListOfWaves
				Print "Post-hoc: Dunnett test (\""+StringFromList(0,ListOfWaves)+"\" is a control)"
				WAVE M_DunnettTestResults
				WAVE T_DunnettDescriptors
				PrintSignificantPairs(M_DunnettTestResults,T_DunnettDescriptors,matchStr)
				Print "\r"
			endif
			
			// Do Tukey test
			StatsTukeyTest/SWN/WSTR=ListOfWaves
			Print "Post-hoc: multiple comparison Tukey (HSD) test"
			WAVE M_TukeyTestResults
			WAVE T_TukeyDescriptors
			PrintSignificantPairs(M_TukeyTestResults,T_TukeyDescriptors,matchStr)
		else
			Print "Unpaired Student's T-test",GiveStars(Significant, M_ANOVA1[2][5],1)
		endif
	else
		if (ItemsInList(ListOfWaves) > 2)
			Print "n.s. one-way ANOVA (p="+num2str(M_ANOVA1[2][5])+")"
		else
			Print "n.s. Unpaired Student's T-test (p="+num2str(M_ANOVA1[2][5])+")"
		endif
	endif
	
	WAVE/Z W_StatsTTest
	if (WaveExists(W_StatsTTest))
		KillWaves W_StatsTTest
	endif
	
	if (nGroups == 2)
		// Do Paired Student's T-test if the n-sizes match
		String s1=StringFromList(0, ListOfWaves)
		String s2=StringFromList(1, ListOfWaves)
		WAVE w1=$s1
		WAVE w2=$s2
		
		if (numpnts(w1) == numpnts(w2))
			StatsTTest/PAIR/Q w1,w2
			
			WAVE W_StatsTTest
			Significant = CheckPValue(W_StatsTTest[6])
			if (Significant > 0)
				Print "Paired Student's T-test",GiveStars(Significant, W_StatsTTest[6],1)
			else
				Print "n.s. Paired Student's T-test (p="+num2str(W_StatsTTest[6])+")"
			endif
		endif
	endif
	
	if (WaveExists(W_StatsTTest))
		KillWaves W_StatsTTest
	endif
	
	Print "---"
	
End


Function CheckPValue(p)
	
	Variable p

	if (p < 0.001)
		return 3
	elseif (p < 0.01)
		return 2
	elseif (p < 0.05)
		return 1
	else
		return 0
	endif
	
End


Function/S GiveStars(Significant, p, detail)
	
	Variable Significant, p
	Variable detail	// 0 for just stars, 1 for include p-values
	String Stars	// e.g., "*"
	String p_short	// e.g., "p < 0.05"
	String p_value	// e.g., "p=0.034555"
	
	switch(Significant)
		case 1:
			Stars = "*"
			p_short="p < 0.05"
			sprintf p_value, "%0.5f",p	// five decimal points
			break
		case 2:
			Stars = "**"
			p_short="p < 0.01"
			sprintf p_value, "%0.5f",p
			break
		case 3:
			Stars = "***"
			p_short="p < 0.001"
			sprintf p_value, "%0.15f",p	// 15 decimal points
			break
		default:
			Stars = "n.s."
			break
	endswitch
	
	if (detail)
		return Stars + p_short + " (p=" + p_value + ")"
	else
		return Stars
	endif
	
End


Function PrintSignificantPairs(m,t,matchStr)
	
	WAVE m
	WAVE/T t
	String matchStr	// e.g., " c V1 Stim". This string will be removed from the report in the history area.
	
	String Stars,justStars,strVs
	Variable i=0,Significant
	Variable count=DimSize(m,0)
	
	// This will keep a list of significant pairs for processing later
	Make/FREE/T/N=(count) w1
	Make/FREE/T/N=(count) w2
	//WAVE/T w1=wOrderPair
	//WAVE/T w2=wOrderStars
	
	do
		Significant = CheckPValue(m[i][5])
	
		if (Significant > 0)
			Stars=GiveStars(Significant, m[i][5],1)
			strVs=ReplaceString(matchStr,t[i],"")
			Print strVs,Stars
			
			// Store pair info and just stars in wave
			justStars=GiveStars(Significant, m[i][5],0)
			w1[i]=strVs
			w2[i]=justStars
		endif
		i+=1
	while(i<count)
	
	// Remove rows that has no entry
	Extract w1,wOrderPair,strlen(w1)
	Extract w2,wOrderStars,strlen(w2)
	
End


Function/S findNameThatDoesNotExist(dfr,nameDF)
	// in current DF
	
	DFREF dfr
	String nameDF
	
	String objName,cmpName,suffix
	Variable i=0
	
	do
		objName=GetIndexedObjNameDFR(dfr,4,i)
		if (strlen(objName)==0)
			break
		endif
		cmpName="x"+nameDF
		if (cmpstr(objName,cmpName)==0)
			suffix="-"+num2str(i)
			nameDF=ReplaceString(suffix,nameDF,"")
			nameDF=nameDF+"-"+num2str(i+1)
		endif
		i+=1
	while(1)
	
	return nameDF
	
End


Function CheckNumberOfProcessors()
	
	Variable processors = ThreadProcessorCount		// Number of processors on the computer
	return processors
	
End


Function CheckFreeMemory()
// Check the amount of memory available to Igor and display a message if it is low.
	
	Variable freeMB = NumberByKey("FREEMEM",IgorInfo(0))/1000000	// MB
	
	if (freeMB < 300)
		DoAlert/T="Low Memory" 0, "Igor is running low on memory. Crashes and poor performance may result if not dealt with.  Please quit the application and restart soon."
	elseif (freeMB < 100)
		DoAlert/T="Really Low Memory" 0, "Igor is running dangerously low on memory! Please quit the application and restart as soon as possible."
	else
		Print "Free memory left:",freeMB,"MB"
	endif
	
End


Function ResizeWindow(width,height)
	// Works on top window
	
	Variable width,height
	Variable left,top,right,bottom
	
	// Handle differently for PC vs Mac
//	Variable isMac
//	String OS=IgorInfo(2)
//	if (cmpstr(OS,"Macintosh")==0)
//		isMac=1
//	endif
	
	if (width == 0 || height == 0)
		GetWindow kwTopWin, title
		String WindowTitle = S_value
		if (strlen(WindowTitle) == 0)
			WindowTitle = WinName(0,7)
		endif
		
		GetWindow kwTopWin, wsize
		left = V_left
		top = V_top
		right = V_right
		bottom = V_bottom
		
		width = right - left
		height = bottom - top
		
//		if (!isMac)
//			width=width/72*96
//			height=height/72*96
//		endif
		
		Prompt width, "Width (points)"
		Prompt height, "Height (points)"
		DoPrompt "Resize " + WindowTitle,width,height
		
		if (V_flag == 1)
			Print "User Canceled Procedure"
			return -1	//quit if cancel button was clicked
		endif
	else
		GetWindow kwTopWin, wsize
		left = V_left
		top = V_top
		right = V_right
		bottom = V_bottom
	endif
	
	// PCs only
//	if (!isMac)
//		width=width/96*72
//		height=height/96*72
//	endif
	
	right = left + width
	bottom = top + height
	
	MoveWindow left, top, right, bottom
	
End


Function SetYAxisRange()
	
	Variable Ymin, Ymax
	
	String nameTopVisibleGraph = WinName(0,1,1)	// name of top visible graph
	
	DoWindow/F $nameTopVisibleGraph
	
	GetAxis/W=$nameTopVisibleGraph/Q left
	
	Ymin = V_min
	Ymax = V_max
	
	Prompt Ymin, "Minimum value"
	Prompt Ymax, "Maximum value"
	DoPrompt/HELP="Enter a number. Hit a tab-key to toggle between the two fields." "Rescale Y-axis range",Ymin,Ymax
	
	if (V_flag == 1)
		Print "User Canceled Procedure"
		return -1
	endif
	
	SetAxis left Ymin, Ymax
	
End


Function Bar(mode)
	// Draw a horizontal line across the graph to indicate drug application

	Variable mode	// 0 for appending bars directly on the graph
					// 1 for appending bars on duplicated blank graph

	if (mode == 1)
		Variable tracesHidden = HiddenTraceCheck()
		
		if (tracesHidden == 0)
			DuplicateWindowHideTrace()
			
			// Delete the two tags that are present
			Tag/K/N=text0
			Tag/K/N=text1
		endif
	endif
	
	DoUpdate
	
	String lblBar
	Variable x0, x1, y
	
	Prompt x0, "Bar starts at"
	Prompt x1, "Bar ends at"
	Prompt lblBar, "Label"
	DoPrompt/HELP="Enter two numbers and a label. Hit a tab-key to toggle between the three fields." "Stimulus Bar",x0,x1,lblBar

	if (V_flag == 1)
		Print "User Canceled Procedure"
		return -1	//quit if cancel button was clicked
	endif
	
	DrawBar(lblBar,x0,x1)
	
End


Function DrawBar(lblBar,x0,x1)
	
	String lblBar
	Variable x0,x1
	Variable y
	
	String nameTopGraph = WinName(0,1)
	
	if (x0 == x1)
		String strError
		strError = nameTopGraph + ": No bar can be drawn from " + num2istr(x0) + " to " + num2istr(x1) + "."
		LogError(strError)
		return -1
	endif
	
	GetAxis/Q left
	y = V_min + (V_max - V_min) * 1.00
	SetDrawEnv xcoord= bottom,ycoord= left, linethick=5.00, linefgc= (30583,30583,30583)
	DrawLine x0, y, x1, y
	
	if (stringmatch(lblBar,"")==0)
		lblBar = "\Z10" + lblBar
		
		y = V_min + (V_max - V_min) * 1.005
		SetDrawEnv xcoord= bottom,ycoord= left
		DrawText/W=$nameTopGraph x0, y, lblBar
	endif
	
End


Function BarsFromWinGlobals(WNsecsStartExpt)
	
	Variable WNsecsStartExpt	// Igor Pro time in seconds for the start of this experiment
	
	// Automatic stimulus bar creation on existing graph
	Variable i=1,x0,x1
	do
		String gDrugPathName = "root:WinGlobals:perf:gDrug" + num2str(i) + "Name"
		String gDrugPathStartSEC = "root:WinGlobals:perf:gDrug" + num2str(i) + "StartSec"
		String gDrugPathEndSEC = "root:WinGlobals:perf:gDrug" + num2str(i) + "EndSec"
		SVAR/Z nameDrug = $gDrugPathName
		NVAR/Z secDrugStart = $gDrugPathStartSec
		NVAR/Z secDrugEnd = $gDrugPathEndSec
		if (!SVAR_Exists(nameDrug))
			break
		endif
		if (NVAR_Exists(secDrugStart))
			x0=(secDrugStart-WNsecsStartExpt)/60	// min
		else
			break
		endif
		if (NVAR_Exists(secDrugEnd))
			x1=(secDrugEnd-WNsecsStartExpt)/60	// min
		else
			break
		endif
		DrawBar(nameDrug,x0,x1)
		i+=1
	while(1)
End


Function BarsPromptAndSaveInWinGlobals()
	// Create a new perfusion folder within WinGlobals
	if (DataFolderExists("root:WinGlobals:perf"))
		KillDataFolder root:WinGlobals:perf
	endif
	
	NewDataFolder root:WinGlobals:perf
	
	Variable i=1
	do
		if (i!=1)
			String listDrugs = ""
			Variable countback=1
			do
				String prevDrugPathName = "root:WinGlobals:perf:gDrug" + num2str(i-countback) + "Name"
				String prevDrugPathStartTN = "root:WinGlobals:perf:gDrug" + num2str(i-countback) + "StartTN"
				String prevDrugPathEndTN = "root:WinGlobals:perf:gDrug" + num2str(i-countback) + "EndTN"
				SVAR prevDrugName=$prevDrugPathName
				NVAR prevDrugStartTN=$prevDrugPathStartTN
				NVAR prevDrugEndTN=$prevDrugPathEndTN
				if (i==2)
					listDrugs = prevDrugName + ": " + num2str(prevDrugStartTN) + "-" + num2str(prevDrugEndTN) + "\r"
				else
					listDrugs = listDrugs + prevDrugName + ": " + num2str(prevDrugStartTN) + "-" + num2str(prevDrugEndTN) + "\r"
				endif
				countback+=1
			while (i-countback>0)
			String alertText = listDrugs + "\rDid you perfuse another drug at some point?"
			DoAlert 1,alertText
		else
			DoAlert 1,"Did you perfuse a drug at some point?"
		endif
		if (V_flag == 1)
			i = EnterPerfusionData(i)
		else
			if (i==1)
				// There was no perfusion. Delete DF (the presence of DF will be checked in AddWaveNotes later).
				KillDataFolder root:WinGlobals:perf
			endif
			break
		endif
	while(1)
End


Function EnterPerfusionData(i)
	
	Variable i
	
	String strNewPathName = "root:WinGlobals:perf:gDrug" + num2str(i) + "Name"
	String strNewPathStartTN = "root:WinGlobals:perf:gDrug" + num2str(i) + "StartTN"
	String strNewPathEndTN = "root:WinGlobals:perf:gDrug" + num2str(i) + "EndTN"
	
	String/G $strNewPathName ="Drug"
	Variable/G $strNewPathStartTN=0
	Variable/G $strNewPathEndTN=0
	
	String nameDrug=StrVarOrDefault(strNewPathName,"Drug")
	String concDrug = "µM"
	Variable startDrugTN=NumVarOrDefault(strNewPathStartTN,0)
	Variable endDrugTN=NumVarOrDefault(strNewPathEndTN,0)
	
	Prompt nameDrug, "Drug Name"
	Prompt concDrug, "Concentration"
	Prompt startDrugTN, "From the start of Trace Number"
	Prompt endDrugTN, "To the end of Trace Number"
	DoPrompt "Drug Perfusion",nameDrug,concDrug,startDrugTN,endDrugTN
	
	if (V_flag == 0)
		nameDrug = concDrug + " " + nameDrug
		if (endDrugTN>0)
			SVAR nameD=$strNewPathName
			NVAR startD=$strNewPathStartTN
			NVAR endD=$strNewPathEndTN
			nameD=nameDrug
			if (endDrugTN>startDrugTN)
				startD=startDrugTN
				endD=endDrugTN
			else
				// flip
				startD=endDrugTN
				endD=startDrugTN
			endif
			return i+1
		else
			DoAlert 0, "The end Trace Number cannot be zero! Try again."
			KillStrings $strNewPathName
			KillVariables $strNewPathStartTN
			KillVariables $strNewPathEndTN
			return i
		endif
	else
		// User canceled.
		KillStrings $strNewPathName
		KillVariables $strNewPathStartTN
		KillVariables $strNewPathEndTN
		return i
	endif
	
End


Function AutoscaleAxes()

	SetAxis/A

End


Function WipeAllAxes()

	ModifyGraph noLabel=2,axThick=0
	
End


Function ShowAxes()

	ModifyGraph noLabel=0,axThick=1

End


Function WipeBottomAxis()

	ModifyGraph noLabel(bottom)=2,axThick(bottom)=0
	
End


Function HiddenTraceCheck()
// Check if all traces are hidden on the top graph

	String visibleTraces=TraceNameList("",";",1+4)// only visible normal traces
//	String allNormalTraces=TraceNameList("",";",1)// hidden + visible normal traces
//	String hiddenTraces= RemoveFromList(visibleTraces,allNormalTraces)
	
	if (strlen(visibleTraces) == 0)
		return 1
	else
		return 0
	endif
	
End


Function DuplicateWindowHideTrace()

	// Duplicate Window
	DoIgorMenu "Edit","Duplicate"
		
	// Hide trace
	ModifyGraph hideTrace=2	// Do not use 1 because it may crash the program if an axis is autoscaled.
	
	// Hide Axes
	WipeAllAxes()

	DoUpdate
	
End


Function AboutHiroScript()
	
	DoWindow/F NoteAboutBosmaEphys		// Check if the error log exists
	if (V_flag == 0)
		NewNotebook/F=0/K=1/N=NoteAboutHiroScript/OPTS=2/W=(650,200,1100,350) as "About this menu"
		
		String str = "\r\rHiro\'s Igor Pro Scripts\r\rThe functions are written by Hirofumi Watari, Ph.D.\r\rCopyright © 2010-2016 Hirofumi Watari.  All rights reserved."
	
		Notebook NoteAboutHiroScript Text=str
	endif
	
End


Function LogError(strLog)
	
	String strLog
	
	DoWindow ErrorLog		// Check if the error log exists
	if (V_flag == 0)
		NewNotebook/F=0/N=ErrorLog/W=(900,0,1100,125) as "Error Log"
	endif
	
	// move selection to the end of the notebook
	Notebook ErrorLog selection={endOfFile, endOfFile}
	
	Notebook ErrorLog Text=strLog+"\r"
	
End


Function SettoRootDataFolder()

	SetDataFolder root:
	
End


Function LoadDataFromClipboard(mode)
	// Load text data that are in the clipboard.  Used if zero reset is present in the original data.
	
	Variable mode	// 0 for waves, 1 for matrix
	Variable/G nRegions
	
	if (!mode)
		LoadWave/J/D/N=R/K=0/Q "Clipboard"
		nRegions = V_flag-1
	else
		LoadWave/J/D/N=M/K=0/Q/M "Clipboard"
		WAVE M0
		nRegions = DimSize(M0,1)
	endif
	//Print "Number of waves loaded:",nRegions
	// Print "Semicolon-separated list of the names of loaded waves:",S_waveNames

End


Function LoadDataAsGeneralText(mode)
	// Igor automatically searches for the data in a log file.
	
	Variable mode	// 0 for waves, 1 for matrix
	
	SVAR fileName
	SVAR folderPath
	NewPath/O/Q path, folderPath
	Variable/G nRegions
	if (!mode)
		LoadWave/G/K=0/D/N=R/Q/P=path fileName
		nRegions = V_flag-1
	else
		LoadWave/G/K=0/D/N=M/Q/P=path/M fileName
		WAVE M0
		nRegions = DimSize(M0,1)
	endif
	//Print "Number of waves loaded:",nRegions
	// Print "Semicolon-separated list of the names of loaded waves:",S_waveNames

End


Function CopyDataToClipBoard()
	
	// Select the data
	Notebook ImageLog selection={startOfParagraph, endOfFile}
	
	// Copy selection into a new notebook
	Notebook ImageLog getData=3	// Stores in S_value plain text or formatted text data, depending on the type of the notebook, from the notebook selection only.
	
	// Put the selection into clipboard
	PutScrapText S_Value
	
//	Print "Data copied to clipboard"
	
End


Function/S CheckDFDuplicates(nameDF)
	// Check if Data Folder exists under the name of nameDF.
	
	String nameDF
	
	String nameDF2,nameNewDF
	
	// The existing nameDF may contain single quotes. Remove before proceeding
	nameDF=ReplaceString("'",nameDF,"")
	
	// DF name must be 31 characters max.  Allow two characters for single quotes, if needed,
	// and an underscore plus number.  Thus, truncate to 27, if needed
	Variable flag
	do
		if (strlen(nameDF)<28)
			break
		endif
		nameDF=RemoveEnding(nameDF)
		flag+=1
	while (1)
	
	if (DataFolderExists("root:" + PossiblyQuoteName(nameDF)) == 1)
		// Make a new DF name
		Variable n=1
		
		// If fileName exists, use it as a base to increment the number
		SVAR/Z fileName
		if (SVAR_Exists(fileName))
			nameDF=ParseFilePath(3,fileName,":",0,0)	// file name without the extension
			//Print nameDF
		endif
		
		do
			nameDF2 = nameDF + "_" + num2str(n)
			n+=1
		while (DataFolderExists("root:" + PossiblyQuoteName(nameDF2)) == 1)
		
		nameNewDF=nameDF2
	else
		// Use the nameDF
		nameNewDF=nameDF
	endif
	
	// Optional: if root:temp exists, rename using the new DF name
	if (DataFolderExists("root:temp"))
		// RenameDataFolder cannot accept single quotes! Do not wrap here (weird...)
		RenameDataFolder root:temp, $nameNewDF
	endif
	
	return PossiblyQuoteName(nameNewDF)			// wrap single quotes if needed
	
End


Function CenterObjScreen(x0,y0,width,height)
	// Find screen size and center object
	// To make it work with windows, points will be converted to pixels first. Output will be in points
	
	Variable &x0, &y0,width,height		// in points
	
	String ScreenInfo=StringByKey("Screen1",IgorInfo(0))
	
	String expr="RECT=([[:digit:]]+),([[:digit:]]+),([[:digit:]]+),([[:digit:]]+)"
	String strleft, strtop, strright, strbottom
	SplitString/E=(expr) ScreenInfo, strleft, strtop, strright, strbottom
	
	Variable left,top,right,bottom
	
	left=str2num(strleft)	// in pixels
	top=str2num(strtop)
	right=str2num(strright)
	bottom=str2num(strbottom)
	
	if (cmpstr(IgorInfo(2),"Windows")==0)
		
		// The pixels need to be converted into points
		Variable pxl2pnts=72/ScreenResolution
		
		left*=pxl2pnts	// in points
		top*=pxl2pnts
		right*=pxl2pnts
		bottom*=pxl2pnts
		
	endif
	
	x0 = (right-left)/2 - width/2
	y0 = (bottom-top)/2 - height/2
	
End


Function ChooseFrom10PresetColors(i, red, green, blue)
	
	Variable i, &red, &green, &blue
	
	Variable index = mod(i, 10)				// Wrap after 10 traces.
	switch(index)
		case 0:	// Dark gray
			red = 17476; green = 17476; blue = 17476;
			break

		case 1:	// off red
			red = 65535; green = 16385; blue = 16385;
			break
			
		case 2:	// blueberry
			red = 0; green = 0; blue = 65535;
			break
			
		case 3:	// tangerine
			red = 65535; green = 32896; blue = 0;
			break
			
		case 4:	// moss
			red = 16448; green = 32896; blue = 0;
			break
			
		case 5:	// brown
			red = 39321; green = 26214; blue = 13107;
			break
			
		case 6:	// salmon
			red = 65535; green = 26214; blue = 26214;
			break
			
		case 7:
			red = 47375; green = 65535; blue = 29214;
			break
			
		case 8:	// Orchid
			red = 26214; green = 26214; blue = 65535;
			break
			
		case 9:
			red = 65535; green = 32768; blue = 58981;
			break
	endswitch
	
End


Function DateTimeToSecs(dt)
	// Convert YYYY-MM-DD HH:MM:SS into secs (Igor Pro format)
	
	String dt
	Variable secs
	
	// Separate date and time into two strings
	String d = StringFromList(0,dt," ")
	String t = StringFromList(1,dt," ")
	
	Variable YYYY = str2num(StringFromList(0,d,"-"))
	Variable MO = str2num(StringFromList(1,d,"-"))
	Variable DD = str2num(StringFromList(2,d,"-"))
	
	Variable HH = str2num(StringFromList(0,t,":"))
	Variable MN = str2num(StringFromList(1,t,":"))
	Variable SS = str2num(StringFromList(2,t,":"))
	
	secs = date2secs(YYYY, MO, DD) + 3600*HH + 60*MN + SS
	
//	Print secs,"s"
	return secs
	
End


Function LoadDataAsGeneralBin(n)
	// Low-endian double float binary with no header.  Needs column number as user-prompt
	
	Variable n	// number of columns in the file
	
	SVAR fileName = fileName
	SVAR folderPath = folderPath
	NewPath/O/Q path, folderPath
	
	if (!n)
		// Check if the column number is embedded in the file name (e.g., ending in "_20.bin")
		String regExp = "_([[:digit:]]+).bin"
		String str
		SplitString /E=(regExp) filename, str
		n=str2num(str)
		if (!n)
			// Prompt the user for number of columns in the file to import
		endif
	endif
	
	if (n)
		GBLoadWave/B/T={4,4}/Q/N=R/W=(n)/P=path fileName
		//Print "Number of waves loaded:",V_flag
		Variable/G nRegions = V_flag - 1
		Variable/G gNumAllTraces = V_flag
		// Print "Semicolon-separated list of the names of loaded waves:",S_waveNames
	endif
	
End


Function GetFileInfo(type)
	
	Variable type
	
	Variable refNum
	String fileFilters
	
	switch (type)
		case 0:	// Metafluor or Elements
			fileFilters = "Data File (*.LOG,*.xlsx):.LOG,.xlsx;"
			break
		case 1:	// Elements
			fileFilters = "Data File (*.xlsx):.xlsx;"
			break
		case 2:	// binary with no headers
			fileFilters = "Data File (*bin):.bin;"
			break
		case 3:	// tab-delimited text
			fileFilters = "Data File (*txt):.txt;"
			break
		case 4:	// binary with custom headers (post-stimulus histogram, poly2 electrode)
			fileFilters = "Data File (*psh):.psh;"
			break
		case 5:	// Spike2 as text file
			fileFilters = "Spike2 Text File (*txt):.txt;"
			break
		case 6:	// tab-delimited text or Stroh Lab m2i binary
			fileFilters = "Data File (*.txt,*.bin):.txt,.bin;"
			break
	endswitch
	
	fileFilters += "All Files:.*;"
	
	Variable useCache
	
	if (exists("folderPath"))
		SVAR fP=folderPath
		NewPath/O/Q UserPath, fP
		//Open/D/R/F=fileFilters/P=UserPath refNum	// just open a dialog box.  refNum will be unchanged
	else
		useCache=1
		NewPath/O/Q/Z UserPath, hiroPathCacheLoad()
		//GetFileFolderInfo/P=UserPath/Z/Q
		if (V_flag!=0)	// does not exist
			// revert to default path (e.g., Documents)
			NewPath/O/Q UserPath, hiroDefaultPath()
		endif
		//Open/D/R/F=fileFilters refNum	// just open a dialog box.  refNum will be unchanged
	endif
	
	Open/D/R/F=fileFilters/P=UserPath refNum
	if (V_Flag==-1)
		Print "User canceled"
		return -1
	endif
		
	String fullPath = S_fileName
	
	String extension = ParseFilePath(4, fullPath, ":", 0, 0)
	
	if (CmpStr(extension, "xlsx") == 0)
		type = 1
	elseif (CmpStr(extension, "LOG") == 0)
		type = 0
	endif
	
	if (CmpStr(extension, "txt") == 0)
		type = 3
	elseif (CmpStr(extension, "bin") == 0)
		type = 6
	endif
	
	if (strlen(S_fileName) == 0) // User canceled
		return -1
	endif

	Open/R/F=fileFilters refNum as fullPath	// open the file as read-only.  refNum assigned
												// for later use
	
	FStatus refNum		// detect file name
	if (V_flag > 0)
		if (DataFolderExists("root:temp"))
			// this will prevent errors that will happen if root:temp with content already exists
			KillDataFolder root:temp
		endif
		NewDataFolder/O/S root:temp	//New waves are created in data folder called temp
		String/G fileName,folderPath
		fileName = S_fileName	// simple name of the file
		folderPath = S_path		// path to the folder that contains the file
	else
		Abort "refNum invalid in GetFileInfo()"
	endif
	
	Close refNum
	
	// Update path cache in the preferences
	if (useCache)
		hiroPathCacheUpdate(folderPath)
	endif
	
	Return type
End


Function/DF CreateAnalysisDF(grandParentDF, parentDF)

	String grandParentDF, parentDF		// Names of destination DF
		
	DFREF saveDFR = GetDataFolderDFR()	// Save current data folder
	
		// Create a new destination DF
		NewDataFolder/O/S root:$grandParentDF	// e.g., "Analysis"
		NewDataFolder/O/S $parentDF				// e.g., "Ramp Up"
		
		DFREF pathNewDFR = GetDataFolderDFR()
		
	SetDataFolder saveDFR	// Restore data folder

	return pathNewDFR

End


Function CopyThisNumToWaveInDFR(num,nameW,dfr)
	
	// Add a number to a new wave (of specifed name) inside specified dfr
	// This is a simplified version of the original "CopyVariableToDF" that is included in the ephys package
	
	Variable num
	String nameW
	DFREF dfr
	
	DFREF saveDFR = GetDataFolderDFR()	// Save current dfr
		
		// Create a new wave and put the number in it
		SetDataFolder dfr
		Make/N=1/D temp0		// specify as double float with D flag (default is single float for waves in ver 6.x)
		WAVE w=temp0
		w[0] = num
		Rename temp0, $nameW
		
	SetDataFolder saveDFR	// Restore dfr
	
End


// Try simpletest(0,0) and simpletest(1,0), simpletest(0,1) and simpletest(1,1)
// Modified from Igor Pro Manual
Function simpletest(indefinite, useIgorDraw)
	Variable indefinite
	Variable useIgorDraw// True to use Igor's own draw method rather than native
	NewPanel /N=ProgressPanel /W=(285,111,739,193)
	ValDisplay valdisp0,pos={18,32},size={342,18}
	ValDisplay valdisp0,limits={0,100,0},barmisc={0,0}
	ValDisplay valdisp0,value= _NUM:0
	if( indefinite )
		ValDisplay valdisp0,mode= 4// candy stripe
	else
		ValDisplay valdisp0,mode= 3// bar with no fractional part
	endif
	if( useIgorDraw )
		ValDisplay valdisp0,highColor=(0,65535,0)
	endif
	Button bStop,pos={375,32},size={50,20},title="Stop"
	DoUpdate /W=ProgressPanel /E=1// mark this as our progress window
	Variable i,imax= indefinite ? 10000 : 100
	for(i=0;i<imax;i+=1)
		Variable t0= ticks
		do
		while( ticks < (t0+3) )
		if( indefinite )
			ValDisplay valdisp0,value= _NUM:1,win=ProgressPanel
		else
			ValDisplay valdisp0,value= _NUM:i+1,win=ProgressPanel
		endif
			DoUpdate /W=ProgressPanel
		if( V_Flag == 2 )// we only have one button and that means stop
			break
		endif
	endfor
	KillWindow ProgressPanel
End


//--- Grouping pxps for phase 2
Function ImportIgorPXPFromFolder()	// Load all analyzed pxp files from a selected folder
	
	DFREF dfr = GetDataFolderDFR()	// Save current DF reference
	
		GetFileFolderInfo/D/Q
		if (V_Flag == 0)	// Folder is found.  The path is stored in S_Path
			// Loop and get file names in the folder
			NewPath/O sympath, S_Path	// IndexedFile function requires symbolic path, not a string
			String list = IndexedFile(sympath, -1, ".pxp")	// List all pxp files in this folder
			list = SortList(list, ";", 16)	// Sort list in alphanumeric order
			//Print list
			Variable numItems = ItemsInList(list)
			Variable i
			String fileName, filePath
			
			SetDataFolder root:	// Set DF to root
			
			for(i=0; i<numItems; i+=1)
				fileName = StringFromList(i, list)
				filePath = S_Path + fileName
				
				LoadData/Q/T/R/S="Export Waves" filePath	// Load contents of subfolder, "Export Waves"
				LoadData/T/R/S="Export" filePath	// Load contents of subfolder, "Export"
				
				if (V_Flag>0)
					CreateImportWavesDF()	// Merge loaded waves into "Imported Waves" DF.
					CreateImportDF()	// Merge loaded data into "Imported" DF.
				endif
				
				Print i+1, "of", numItems, "loaded"
				
			endfor
		endif
	
	SetDataFolder dfr
	
End


Function ImportIgorPXP()	// Append one analyzed pxp file into the existing group
	
	Variable flag = BrowseIgorExperiment()	// Load data from Igor pxp files
	
	if (flag > 0)
		CreateImportWavesDF()	// Merge loaded waves into "Imported Waves" DF.
		CreateImportDF()	// Merge loaded data into "Imported" DF.
	endif
	
	Print "Done!"
	
End


Function BrowseIgorExperiment()
// Load data from Igor pxp files; equivalent of Browse Expt... button in Data Browser
	
	DFREF dfr = GetDataFolderDFR()	// Save current DF reference
	
		GetFileFolderInfo/Q		// Get a full path for a pxp file in S_path
		SetDataFolder root:	// Set DF to root
		LoadData/Q/T/R/S="Export Waves" S_path	// Load contents of subfolder, "Export Waves"
		LoadData/T/R/S="Export" S_path	// Load contents of subfolder, "Export"

	SetDataFolder dfr

	return V_Flag	// V_Flag contains number of items loaded.
	
End


Function CreateImportWavesDF()
// Similar to CreateImportDF, but do not append data
	
	if (DataFolderExists("root:'Export Waves'"))
		if (DataFolderExists("root:'Imported Waves'"))
			DFREF dfrExport = root:'Export Waves'
			DFREF dfrImported = root:'Imported Waves'
			String nameDF
			Variable i=0
			do
				nameDF = GetIndexedObjNameDFR(dfrExport, 4, i)
				if (strlen(nameDF) == 0)
					break
				endif
				if (DataFolderExists("root:'Imported Waves':'" + nameDF + "'"))
					DFREF dfrExportChild = root:'Export Waves':$nameDF
					DFREF dfrImportedChild = root:'Imported Waves':$nameDF
					Variable k=0
					String nameWave
					do
						nameWave = GetIndexedObjNameDFR(dfrExportChild, 1, k)
						if (strlen(nameWave) == 0)
							break
						endif
						MoveWave dfrExportChild:$nameWave, dfrImportedChild
						// Moving DF shifts index.  So no need to update k.
					while(1)
				else
					MoveDataFolder root:'Export Waves':$nameDF, root:'Imported Waves':
					i-=1	// Moving DF shifts index.  Revert one back.
				endif
				i+=1
			while(1)
			KillDataFolder root:'Export Waves'
			// Print "Import Complete!"
		else
			RenameDataFolder root:'Export Waves', 'Imported Waves'
		endif
	else
		LogError("\"Export Waves\" DF does not exist at root level.")
	endif
End


Function CreateImportDF()
// Transfers waves from "Export" DF into "Imported" DF.  If a target wave already exists, append data

	if (DataFolderExists("root:Export"))
		if (DataFolderExists("root:Imported"))
			DFREF dfrExport = root:Export
			DFREF dfrImported = root:Imported
			String nameDF
			Variable i = 0
			do
				nameDF = GetIndexedObjNameDFR(dfrExport, 4, i)
				if (strlen(nameDF) == 0)
					break
				endif
				if (DataFolderExists("root:Imported:'" + nameDF +"'"))
					DFREF dfrExportChild = root:Export:$nameDF
					DFREF dfrImportedChild = root:Imported:$nameDF
					Variable k = 0
					String nameWave
					do
						nameWave = GetIndexedObjNameDFR(dfrExportChild, 1, k)
						if (strlen(nameWave) == 0)
							break
						endif
						Wave wExport = dfrExportChild:$nameWave
						Wave/Z wImport = dfrImportedChild:$nameWave
						if (WaveExists(wImport))
							WaveStats/M=1/Q wExport
							Variable wExportEndRow = V_endRow
							WaveStats/M=1/Q wImport
							Variable wImportEndRow = V_endRow
							Variable j=0
							do
								InsertPoints wImportEndRow+j+1,1,wImport
								wImport[wImportEndRow+j+1] = wExport[j]
							j+=1
							while(j <= wExportEndRow)
						else
							MoveWave dfrExportChild:$nameWave, dfrImportedChild
							k-=1	// Moving DF shifts index.  Revert one back.
						endif
						k+=1
					while(1)
				else
					MoveDataFolder root:Export:$nameDF, root:Imported:
					i-=1	// Moving DF shifts index.  Revert one back.
				endif
				i+=1
			while(1)
			KillDataFolder root:Export
			//Print "Import Complete!"
		else
			RenameDataFolder root:Export, Imported
		endif
	else
		LogError("\"Export\" DF does not exist at root level.")
	endif

End
//--- grouping pxps for phase 2 ends


//--- Path Cache System
// save user-selected paths in the preferences
// used with GetFileInfo()
Function hiroPathCacheUpdate(selectedFilePath)
	// save the selected file path in the cache
	
	String selectedFilePath
	
	String cacheFilePath
	
	WAVE/T/Z wT=root:wPathCache
	if (!WaveExists(wT))
		// init
		cacheFilePath=hiroPathCacheLoad()
	endif
	
	WAVE/T wT=root:wPathCache
	
//	// check if the selectedFilePath already exists in the cache
//	if (cmpstr(selectedFilePath,wT[3])==0)
//		// already exists.  no update needed.
//	elseif (cmpstr(selectedFilePath,wT[4])==0)
//		// also do nothing.
//	else
		// update--replace wT[4] with wT[3], then enter the new path to wT[4]
		wT[3]=wT[4]
		wT[4]=selectedFilePath
//	endif
	
	String strParse
	if (cmpstr(wT[3],selectedFilePath)==0)
		strParse=selectedFilePath
	else
		// parse path
		Variable i,flag
		do
			strParse=ParseFilePath(1,wT[3],":",1,i)
			flag=strsearch(wT[4],strParse,Inf,1)
			//print strParse,"vs",wT[4],flag
			i+=1
			if (i>=ItemsInList(wT[3],":"))
				// no match. use default
				//print i
				strParse=hiroDefaultPath()
				break
			endif
		while(flag==-1)
	endif
	
	//Print strParse,"is best"
	
	// Save the parsed path
	wT[2]=strParse
	
	// Save the pref file
	Save/O/P=Packages wT as "HiroPathCache.ibw"
	
	KillWaves wT
	
End


Function/S hiroPathCacheLoad()
	// returns a string containing parsed full path that is saved in the preferences
	
	// Check if Packages path exists
	PathInfo Packages
	if (!V_flag)		// does not exist
		NewPath/Q Packages, SpecialDirPath("Packages",0,0,0)
	endif
	
	// Check if the cache file exists
	GetFileFolderInfo/P=Packages/Z/Q "HiroPathCache.ibw"
	if (V_Flag!=0)	// does not exist
		// make a new cache file
		//print "init path cache"
		hiroPathCacheInit()
	endif
	
	// Make sure this loads at root level
	DFREF dfrSaved=GetDataFolderDFR()
	SetDataFolder root:
	LoadWave/O/P=Packages/Q "HiroPathCache.ibw"
	SetDataFolder dfrSaved
	
	WAVE/T wT=root:wPathCache
	
	return wT[2]	// this is the parsed full path (as a string)
	
End


Function hiroPathCacheInit()
	// create a path cache file for the first time
	// default path is the user's Documents folder
	
	// make a text wave
	Make/T/N=5 root:wPathCache	// can't be a free wave
	WAVE/T wT=root:wPathCache
	
	// cache format
	// 0 version
	// 1 AUTO or MANUAL
	// 2 Parsed directory
	// 3 directory used in the past
	// 4 directory used in the past
	wT[0]="1.00"
	wT[1]="AUTO"
	wT[2]=hiroDefaultPath()
	wT[3]=""
	wT[4]=""
	
	// this function doesn't work with free waves
	Save/O/P=Packages wT as "HiroPathCache.ibw"
	
	KillWaves wT
	
End


Function/S hiroDefaultPath()
	
	return SpecialDirPath("Documents",0,0,0)	// e.g., "Mac HD:Users:hiro:Documents:"
	
End
//--- end path cache


//--tic toc
Function tic()
	
	Variable timerRefNum
	
	timerRefNum=startMSTimer
	
	if (timerRefNum == -1)
		Abort "All timers are in use: See Hiro"
	endif
	
	return timerRefNum

End

Function toc(timerRefNum)
	
	Variable timerRefNum
	
	Print stopMSTimer(timerRefNum),"µs"
	
End
//--tic toc


ThreadSafe Function/WAVE splitColumn(M,dfr,nameW,col)
	
	// separate a designated column from a matrix M
	// save the wave named by nameW (the wave can't be free; setting to /FREE causes error with $nameW)
	// store with a unique name inside a DF (free DF ok)
	// then assign it to an inline wave ref (important--without this the wref will overwrite and use the last reference only)
	
	// A known issue: the first wave will not be saved in some cases (MultiThread).  This appears to be a bug.
	
	WAVE M		// source (M0)
	DFREF dfr		// ref to a DF
	String nameW	// "wFree"+num2str(col)
	Variable col		// column number (p)
	
	Duplicate/O/R=[*][col] M, dfr:$nameW/WAVE=w
	Redimension/N=-1 w	// important--when skipped, the first wave can get weird (e.g., disappear in the physical DF, etc.)
	
	return w
	
End


ThreadSafe Function setColumn(M,source,col)
	// Used in the final phase of the MultiThread matrix operation: Rick Gerkin method
	WAVE M,source
	Variable col
	
	ImageTransform/D=source/G=(col) putCol M
End