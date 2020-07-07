#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=0.50		// version of procedure
#pragma IgorVersion = 6.2	// Requires Igor Pro v6.2

#include "HiroCoreServices"

// Written by Hirofumi Watari, Ph.D. © 2016
// This file helps Consuelo, Georg, Ting, Hendrik and Miriam analyze data

// What's new in HiroOdor 0.50 (2016-12-13);Supports graphing of mean odor responses;Updated default stimulus parameters;---
// What's new in HiroOdor 0.49 (2016-12-12);Supports averaging odor responses for Consuelo;---
// What's new in HiroOdor 0.48 (2016-10-05);Supports error-detection and correction of stimulus artifact for Consuelo;---
// What's new in HiroOdor 0.47 (2016-08-24);Supports peak info export for Miriam;---
// What's new in HiroOdor 0.46 (2016-07-29);Added an overview graph for Ting;---
// What's new in HiroOdor 0.45 (2016-07-26);Updated left marker limits for Consuelo;---
// What's new in HiroOdor 0.44 (2016-07-22);Added additional data for output for Consuelo;---
// What's new in HiroOdor 0.43 (2016-07-21);Evoked response analysis upgraded to beta version for Consuelo;---
// What's new in HiroOdor 0.42 (2016-07-18);Supports user-defined stimulus protocol for Consuelo;---
// What's new in HiroOdor 0.41 (2016-07-15);Supports alpha version of evoked response analysis for Consuelo;---
// What's new in HiroOdor 0.40 (2016-05-31);Inherits control parameters in not-yet-analyzed ROIs for Ting;---
// What's new in HiroOdor 0.39 (2016-05-30);New stimulus detection algorithm for Ting;---
// What's new in HiroOdor 0.38 (2016-05-30);Auto-corrects stimuli detection for Ting;Fixed a minor bug for Ting;---
// What's new in HiroOdor 0.37 (2016-05-25);Detects, aligns and counts evoked responses for Ting;---
// What's new in HiroOdor 0.36 (2016-05-17);Supports exporting PeakLoc datapoints for Hendrik;---
// What's new in HiroOdor 0.35 (2016-04-18);Saves additional parameters for Georg;---
// What's new in HiroOdor 0.34 (2016-04-18);Supports stimulus artifact subtraction for Ting;Supports 30-70 rise time and area for Georg;Fixed a bug showing baseline for Georg under certain circumstance;---
// What's new in HiroOdor 0.33 (2016-04-11);Opens text file and filters;---
// What's new in HiroOdor 0.32 (2016-04-08);Modified baseline detection for Georg;---
// What's new in HiroOdor 0.31 (2016-04-08);New baseline detection for Georg;---
// What's new in HiroOdor 0.30 (2016-04-08);New baseline detection for Georg;---
// What's new in HiroOdor 0.29 (2016-04-08);Supports X-axis scrolling;Time-locks the stimulus onset in step 3;---
// What's new in HiroOdor 0.28 (2016-04-07);Fixed a bug that fails to show the stimulus onset;---
// What's new in HiroOdor 0.27 (2016-04-06);Supports Georg's analysis;---
// What's new in HiroOdor 0.26 (2016-02-23);Normalizes baseline and shows the result as a pair of before and after light;---
// What's new in HiroOdor 0.25 (2016-02-18);Auto-detects light stimulus from odor experiment;---

static constant ksLightDuration=20			// s
static constant ksOdorDuration=2			// s
static constant ksOdorBeforeLight=-30		// s (relative to light onset)
static constant ksOdorAfterLight=2			// s (relative to light onset)

static constant kIsDevMode=0

static constant kScaleBarVertical=1.008	// position of the scale bar;used as prel
static constant kScaleBarLabel=1.009

static constant kDefaultSDMultiple=3.5	// 3.5 times SD above the mean is the default threshold for peak detection
static constant kDefaultSecStimInit=25	// s
static constant kDefaultSecStimPeriod=30	// s

// TF constants
static constant ksTFDefaultBefore=2		// s pre-stim (minus sign will be added in the function)
static constant ksTFDefaultAfter=5		// s post-stim
static constant ksTFBeforeFrom=-1		// s (negative sign important)
static constant ksTFBeforeTo=-0.1		// s (negative sign important)
static constant ksTFAfterFrom=0.5		// s
static constant ksTFAfterTo=1.5			// s

static constant kTFThreshHighLimit=25

// GP cursor A and C relative to B (peak)
static constant kGPPercentPeak=0.3	// 30% of the peak

Function hiroCFOpenTextFile()
	
	OpenImagingData()
	
	// steps
	Variable/G step
	step=1
	
	// Remove some controls that won't be used
	CheckBox checkInclude disable=1
	Button buttonToStep2 disable=1
	
	// Add a button to go to Step 2
//	Button buttonGPToStep2 title="Next: Pick Analysis >>",pos={1000,50},size={200,20}
//	Button buttonGPToStep2 proc=ButtonProcCFToStep2,fColor=(0,0,65535)
//	Button buttonGPToStep2 valueColor=(65535,65535,65535)
//	Button buttonGPToStep2 help={"Click to start baseline selection"}
	
	PopupMenu popupCFEvokedToStep2 title="Menu",pos={1,50}
	PopupMenu popupCFEvokedToStep2 proc=PopMenuProcCFEvokedToStep2,mode=0
	PopupMenu popupCFEvokedToStep2 value="Avg responses;%-amplitude duration;Normalize light effect"
	
	DoWindow/HIDE=1 GraphStep1
	
	// Design or verify stimulus protocol
	hiroCFEvokedStep0()
	
End


Function hiroCFAvgTrials()
	
	NVAR step
	if (step<2)
		step=2

		DoWindow/HIDE=1 GraphStep1

		hiroCFEvokedDetectStim(1)
	endif

	WAVE M_smooth
	WAVE wOnLoc
	//WAVE wOffLoc
	//WAVE wOdorOnLoc
	//WAVE wOdorOffLoc

	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	Variable sLightDuration=V_Value

	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
	Variable sOdorDuration=V_Value

	ControlInfo/W=GraphCFEvokedStep0 setvarBeforeLight
	Variable sBeforeLight=V_Value

	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	Variable sAfterLight=V_Value

	Variable nROIs=DimSize(M_smooth,1)
	Variable nStim=numpnts(wOnLoc)

	Duplicate/FREE/R=[*][0] M_smooth,wFREE

	Variable x1,x2,p1,p2
	String nameDF,nameW

	Variable dx=deltax(wFREE)
	String strUnits=WaveUnits(wFREE,0)

	NewDataFolder/S :Trials

	Variable i,k
	for(i=0;i<nROIs;i+=1)

		nameDF="ROI"+num2str(i+1)

		NewDataFolder :$nameDF
		DFREF dfr=:$nameDF

		for(k=0;k<nStim;k+=1)

			// get odor response during light stim# k
			nameW="wAfter"+num2str(k+1)

			x1=wOnLoc[k]
			x2=x1+sLightDuration
			p1=x2pnt(wFREE,x1)
			p2=x2pnt(wFREE,x2)
			Duplicate/O/R=[p1,p2][i] M_smooth,dfr:$nameW

			WAVE w=dfr:$nameW

			// vectorize
			Redimension/N=-1 w

			// force start to zero sec
			SetScale/P x -sAfterLight,dx,strUnits, w

			// get odor response before light stim# k
			nameW="wBefore"+num2str(k+1)

			x1=wOnLoc[k]+sBeforeLight
			x2=x1+sLightDuration
			p1=x2pnt(wFREE,x1)
			p2=x2pnt(wFREE,x2)
			Duplicate/O/R=[p1,p2][i] M_smooth,dfr:$nameW

			WAVE w=dfr:$nameW

			// vectorize
			Redimension/N=-1 w

			// force start to zero sec
			SetScale/P x -sAfterLight,dx,strUnits, w

		endfor
	endfor

	String nameGraphAfter,nameGraphBefore,strList

	// Display individual traces
	for (i=0;i<nROIs;i+=1)

		nameDF="ROI"+num2str(i+1)

		nameGraphBefore="GraphBefore"+nameDF
		nameGraphAfter="GraphAfter"+nameDF

		Display/K=2/N=$nameGraphBefore as nameDF+" Before"
		Display/K=2/N=$nameGraphAfter as nameDF+" After"
		AutoPositionWindow/E

		DFREF dfr=:$nameDF

		for (k=0;k<nStim;k+=1)

			nameW="wBefore"+num2str(k+1)
			AppendToGraph/W=$nameGraphBefore dfr:$nameW

			nameW="wAfter"+num2str(k+1)
			AppendToGraph/W=$nameGraphAfter dfr:$nameW
		endfor

		ModifyGraph/W=$nameGraphBefore rgb=(34816,34816,34816),margin(left)=50
		ModifyGraph/W=$nameGraphAfter rgb=(34816,34816,34816),margin(left)=50

		// Append stim bar
		hiroCFAvgTrialsAppendStimBar(nameGraphBefore)
		hiroCFAvgTrialsAppendStimBar(nameGraphAfter)

	endfor

	SetDataFolder ::
	
	hiroCFAvgTrialsCalc(nROIs,nStim)

	// Graph all mean plots
	hiroCFAvgTrialsGraphMean(nROIs)

	// Bring up floating panel to switch ROI
	hiroCFAvgTrialsInitSwitchPanel(nROIs)

	// Hide all graphs
	DoIgorMenu "Hide","Hide All Graphs"

	// init panel
	hiroCFAvgTrialsSwitchROI(1,0)

End


Function hiroCFAvgTrialsInitSwitchPanel(nROIs)
	
	Variable nROIs

	Variable x0,y0
	Variable width=200
	Variable height=300
	CenterObjScreen(x0,y0,width,height)

	NewPanel/N=PanelSwitchROI/FLT=2/W=(x0,y0,x0+width,y0+height) as "Avg Responses"

	SetVariable setvarCFROI title="ROI",proc=SetVarProcCFROI,value=_NUM:1
	SetVariable setvarCFROI limits={1,nROIs,1},live=1,size={55,16}
	SetVariable setvarCFROI userData="1"
	SetVariable setvarCFROI help={"Show graphs for specific ROI"}

End


Function SetVarProcCFROI(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval

			Variable oldJ=str2num(sva.userData)

			hiroCFAvgTrialsSwitchROI(dval,oldJ)

			// Save userData
			SetVariable setvarCFROI userData=num2str(dval)

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroCFAvgTrialsSwitchROI(j,oldJ)

	Variable j
	Variable oldJ

	String nameGraphBefore
	String nameGraphAfter
	String nameGraphMeanBefore
	String nameGraphMeanAfter
	
	// Show graphs of j
	nameGraphBefore="GraphBeforeROI"+num2str(j)
	nameGraphAfter="GraphAfterROI"+num2str(j)
	nameGraphMeanBefore="GraphMeanBeforeROI"+num2str(j)
	nameGraphMeanAfter="GraphMeanAfterROI"+num2str(j)

	DoWindow/F/HIDE=0 $nameGraphBefore
	DoWindow/F/HIDE=0 $nameGraphAfter
	DoWindow/F/HIDE=0 $nameGraphMeanBefore
	DoWindow/F/HIDE=0 $nameGraphMeanAfter

	// Hide graphs of previous j
	if (oldJ && oldJ!=j)
		nameGraphBefore="GraphBeforeROI"+num2str(oldJ)
		nameGraphAfter="GraphAfterROI"+num2str(oldJ)
		nameGraphMeanBefore="GraphMeanBeforeROI"+num2str(oldJ)
		nameGraphMeanAfter="GraphMeanAfterROI"+num2str(oldJ)

		DoWindow/F/HIDE=1 $nameGraphBefore
		DoWindow/F/HIDE=1 $nameGraphAfter
		DoWindow/F/HIDE=1 $nameGraphMeanBefore
		DoWindow/F/HIDE=1 $nameGraphMeanAfter
	endif
End


Function hiroCFAvgTrialsCalc(nROIs,nStim)
	
	Variable nROIs
	Variable nStim

	String nameDF,listWBefore,listWAfter
	String nameGraphBefore,nameGraphAfter

	WAVE w=:Trials:ROI1:wAfter1
	Variable nPnts=numpnts(w)

	Make/FREE/D/N=(nPnts,nStim) M_before,M_after

	SetScale/P x leftx(w),deltax(w),WaveUnits(w,0), M_before,M_after
	SetScale d 0,0,WaveUnits(w,-1), M_before,M_after

	Variable i,k
	for (i=0;i<nROIs;i+=1)

		nameDF="ROI"+num2str(i+1)

		nameGraphBefore="GraphBefore"+nameDF
		nameGraphAfter="GraphAfter"+nameDF

		// list only visible traces on a specified graph
		listWBefore=TraceNameList(nameGraphBefore,";",1+4)
		listWAfter=TraceNameList(nameGraphAfter,";",1+4)

		for (k=0;k<nStim;k+=1)

			WAVE w=TraceNameToWaveRef(nameGraphBefore,StringFromList(k,listWBefore))
			//Print nameDF,NameOfWave(w)
			M_before[][k]=w[p]

			WAVE w=TraceNameToWaveRef(nameGraphAfter,StringFromList(k,listWAfter))
			M_after[][k]=w[p]
		endfor

		// Average of all traces
		DFREF dfr=:Trials:$nameDF
		MatrixOp/O dfr:mean_before=sumRows(M_before)/numCols(M_before)
		MatrixOp/O dfr:mean_after=sumRows(M_after)/numCols(M_after)

		// MatrixOp doesn't have "varRows" so transpose first
		MatrixTranspose M_before
		MatrixTranspose M_after

		MatrixOp/S/FREE M_variance_before=varCols(M_before)
		MatrixOp/S/FREE M_variance_after=varCols(M_after)

		MatrixTranspose M_variance_before
		MatrixTranspose M_variance_after

		M_variance_before=sqrt(M_variance_before)/sqrt(nStim)
		M_variance_after=sqrt(M_variance_after)/sqrt(nStim)
		//M_variance=sqrt(M_variance)/sqrt(n)

		Duplicate/O M_variance_before,dfr:ste_before
		Duplicate/O M_variance_after,dfr:ste_after

		WAVE wMeanBefore=dfr:mean_before
		WAVE wSteBefore=dfr:ste_before
		WAVE wMeanAfter=dfr:mean_after
		WAVE wSteAfter=dfr:ste_after

		SetScale/P x leftx(w),deltax(w),WaveUnits(w,0), wMeanBefore,wSteBefore,wMeanAfter,wSteAfter
		SetScale d 0,0,WaveUnits(w,-1), wMeanBefore,wSteBefore,wMeanAfter,wSteAfter

		// Create edges based on the SEM
		Duplicate/O wMeanBefore, dfr:hiEdgeBefore,dfr:loEdgeBefore
		Duplicate/O wMeanAfter, dfr:hiEdgeAfter,dfr:loEdgeAfter

		WAVE hiEdgeBefore=dfr:hiEdgeBefore
		WAVE hiEdgeAfter=dfr:hiEdgeAfter
		WAVE loEdgeBefore=dfr:loEdgeBefore
		WAVE loEdgeAfter=dfr:loEdgeAfter

		hiEdgeBefore+=wSteBefore
		loEdgeBefore-=wSteBefore
		hiEdgeAfter+=wSteAfter
		loEdgeAfter-=wSteAfter
		
		// Fix transponse before the next for loop
		MatrixTranspose M_before
		MatrixTranspose M_after

	endfor

End


Function hiroCFAvgTrialsGraphMean(nROIs)
	
	// Graph mean +/- ste
	Variable nROIs

	SetDataFolder :Trials

	String nameDF, nameGraphBefore,nameGraphAfter

	Variable i
	for (i=0;i<nROIs;i+=1)

		nameDF="ROI"+num2str(i+1)

		nameGraphBefore="GraphMeanBefore"+nameDF
		nameGraphAfter="GraphMeanAfter"+nameDF

		// dummy graph to prep AutoPositionWindow
		Display/N=graphDummy

		Display/K=2/N=$nameGraphBefore as nameDF+" Before: Mean +/- STEM"
		AutoPositionWindow/E/M=1
		Display/K=2/N=$nameGraphAfter as nameDF+" After: Mean +/- STEM"
		AutoPositionWindow/E

		KillWindow graphDummy

		DFREF dfr=:$nameDF

		AppendToGraph/W=$nameGraphBefore dfr:hiEdgeBefore,dfr:loEdgeBefore,dfr:mean_before
		AppendToGraph/W=$nameGraphAfter dfr:hiEdgeAfter,dfr:loEdgeAfter,dfr:mean_after

		ModifyGraph/W=$nameGraphBefore mode(hiEdgeBefore)=7,lsize(hiEdgeBefore)=0
		ModifyGraph/W=$nameGraphBefore hbFill(hiEdgeBefore)=5,toMode(hiEdgeBefore)=1
		ModifyGraph/W=$nameGraphBefore lsize(loEdgeBefore)=0,margin(left)=50

		ModifyGraph/W=$nameGraphAfter mode(hiEdgeAfter)=7,lsize(hiEdgeAfter)=0
		ModifyGraph/W=$nameGraphAfter hbFill(hiEdgeAfter)=5,toMode(hiEdgeAfter)=1
		ModifyGraph/W=$nameGraphAfter lsize(loEdgeAfter)=0,margin(left)=50

		// Append stim bar
		hiroCFAvgTrialsAppendStimBar(nameGraphBefore)
		hiroCFAvgTrialsAppendStimBar(nameGraphAfter)
	endfor

	SetDataFolder ::

End


Function hiroCFAvgTrialsAppendStimBar(nameGraph)
	
	// Append odor stim bar on a specified graph

	String nameGraph

	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
	Variable sOdorDuration=V_Value

	SetDrawEnv/W=$nameGraph xcoord= bottom,ycoord= prel,linethick= 3.00
	DrawLine/W=$nameGraph 0,1,sOdorDuration,1

End


//Function ButtonProcCFToStep2(ba) : ButtonControl
//	STRUCT WMButtonAction &ba
//
//	switch( ba.eventCode )
//		case 2: // mouse up
//			// click code here
//			
//			hiroCFSelectAnalysis()
//			
//			break
//		case -1: // control being killed
//			break
//	endswitch
//
//	return 0
//End


Function PopMenuProcCFEvokedToStep2(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			switch(popNum)
				case 1:
					hiroCFAvgTrials()
					break
				case 2:
					hiroCFEvokedStep2()
					break
				case 3:
					OdorLightBaselineAnalysis()
					break
				default:
					hiroCFEvokedStep2()
			endswitch
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//Function hiroCFSelectAnalysis()
//	
//	String nameAnalysis
//	
//	Prompt nameAnalysis, "Analyze:", popup, "Half-width duration;Normalize light effect"
//	DoPrompt/HELP="Select an analysis.  Go on, you can do it ;p" "Select an analysis",nameAnalysis
//	if (V_flag == 1)
//		Print "User Canceled Procedure"
//		Abort	//quit if cancel button was clicked
//	else
//		if (cmpstr(nameAnalysis,"_none_")==0)
//			DoAlert/T="Analysis not selected" 0, "You need to select analysis.\rTry again."
//			Abort
//		endif
//	endif
//	
//	strswitch(nameAnalysis)
//		case "Half-width duration":
//			hiroCFEvokedStep2()
//			break
//		case "Normalize light effect":
//			OdorLightBaselineAnalysis()
//			break
//		default:
//			hiroCFEvokedStep2()
//	endswitch
//	
//End


// Consuelo's evoked response analysis
// 0. Design and verify stimulus protocol
Function hiroCFEvokedStep0()
	
	DoWindow GraphCFEvokedStep0
	if (V_flag)
		KillWindow GraphCFEvokedStep0
	endif
	
	Display/N=GraphCFEvokedStep0/K=2 as "Step 0: Verify Stimulus Protocol"
	
	ResizeWindow(1280,150)
	
	ControlBar/L 140
	
	Variable sLightDuration=ksLightDuration
	Variable sOdorDuration=ksOdorDuration
	Variable sOdorBeforeLight=ksOdorBeforeLight
	Variable sOdorAfterLight=ksOdorAfterLight
	
	hiroCFEvokedUpdateStimProtocol(sLightDuration,sOdorDuration,sOdorBeforeLight,sOdorAfterLight)
	
	WAVE wLightDesign
	WAVE wOdorDesign1
	WAVE wOdorDesign2
	
	AppendToGraph wLightDesign,wOdorDesign1,wOdorDesign2
	ModifyGraph lsize=3,rgb(wLightDesign)=(65535,65532,16385)
	ModifyGraph rgb(wOdorDesign1)=(3,52428,1),rgb(wOdorDesign2)=(3,52428,1)
	ModifyGraph noLabel(left)=2,axThick(left)=0
	//SetAxis left -5,5
	
	Legend/C/N=text0/J/F=0/A=MC "\\s(wLightDesign) Light\r\\s(wOdorDesign1) Odor"
	Legend/C/N=text0/J/X=-52.95/Y=48.00
	
	// Controls
	SetVariable setvarLightDuration title="Light duration (s)",bodyWidth=60,pos={1,2}
	SetVariable setvarLightDuration proc=SetVarProcLightDuration,value= _NUM:sLightDuration
	SetVariable setvarLightDuration limits={1,inf,1},live=1
	
	SetVariable setvarOdorDuration title="Odor duration (s)",bodyWidth=60,pos={1,22}
	SetVariable setvarOdorDuration proc=SetVarProcOdorDuration,value= _NUM:sOdorDuration
	SetVariable setvarOdorDuration limits={1,inf,1},live=1
	
	SetVariable setvarBeforeLight title="Odor onset 1* (s)",bodyWidth=60,pos={1,42}
	SetVariable setvarBeforeLight proc=SetVarProcBeforeLight,value= _NUM:sOdorBeforeLight
	SetVariable setvarBeforeLight limits={-inf,-1,1},live=1
	
	SetVariable setvarAfterLight title="Odor onset 2* (s)",bodyWidth=60,pos={1,62}
	SetVariable setvarAfterLight proc=SetVarProcAfterLight,value= _NUM:sOdorAfterLight
	SetVariable setvarAfterLight limits={1,inf,1},live=1
	
	TitleBox titleCFEvokedStep0Fineprint title="*Relative to light onset ",frame=0
	TitleBox titleCFEvokedStep0Fineprint pos={1,82}
	
	Button buttonCFEvokedStep0Done title="OK",proc=ButtonProcCFEvokedStep0Done
	Button buttonCFEvokedStep0Done pos={84,100}
	
End


Function SetVarProcLightDuration(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			hiroCFEvokedRefreshStimProtocol()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcOdorDuration(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			hiroCFEvokedRefreshStimProtocol()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcBeforeLight(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			hiroCFEvokedRefreshStimProtocol()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcAfterLight(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			hiroCFEvokedRefreshStimProtocol()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroCFEvokedRefreshStimProtocol()
	
	Variable sLightDuration
	Variable sOdorDuration
	Variable sOdorBeforeLight
	Variable sOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	sLightDuration=V_Value
	
	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
	sOdorDuration=V_Value
	
	ControlInfo/W=GraphCFEvokedStep0 setvarBeforeLight
	sOdorBeforeLight=V_Value
	
	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	sOdorAfterLight=V_Value
	
	hiroCFEvokedUpdateStimProtocol(sLightDuration,sOdorDuration,sOdorBeforeLight,sOdorAfterLight)
	
End


Function hiroCFEvokedUpdateStimProtocol(sLightDuration,sOdorDuration,sOdorBeforeLight,sOdorAfterLight)
	
	Variable sLightDuration
	Variable sOdorDuration
	Variable sOdorBeforeLight
	Variable sOdorAfterLight
	
	Variable nSample=sLightDuration+abs(sOdorBeforeLight)+10
	
	Make/O/N=(nSample) wLightDesign=NaN,wOdorDesign1=NaN,wOdorDesign2=NaN
	SetScale/P x sOdorBeforeLight,1,"s", wLightDesign,wOdorDesign1,wOdorDesign2
	
	WAVE wLightDesign
	WAVE wOdorDesign1
	WAVE wOdorDesign2
	
	// Construct
	Variable p0
	
	// Light bar
	p0=abs(sOdorBeforeLight)
	wLightDesign[p0,p0+sLightDuration]=0
	
	// Odor bar (ctrl)
	p0=0
	wOdorDesign1[p0,p0+sOdorDuration]=0
	
	// Odor bar (light)
	p0=abs(sOdorBeforeLight)+sOdorAfterLight
	wOdorDesign2[p0,p0+sOdorDuration]=0
	
End


Function ButtonProcCFEvokedStep0Done(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			hiroCFEvokedStep1()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroCFEvokedStep1()
	
	DoWindow/HIDE=1 GraphCFEvokedStep0
	DoWindow/HIDE=0/F GraphStep1
	
End


Function hiroCFEvokedStep2()
	
	NVAR step
	step=2
	
	DoWindow/HIDE=1 GraphStep1
	
	Variable j=1	// init (ROI 1)
	
	// auto-detects light onset, then calculates odor onset
	hiroCFEvokedDetectStim(j)
	
	// make stimulus bars
	hiroCFEvokedMakeStimBars()	// Outputs wBarLight and wBarOdor
	
	// Initialize M_Base
	WAVE wOdorOnLoc
	WAVE M0
	Variable nStim=numpnts(wOdorOnLoc)
	Variable nROI=DimSize(M0,1)
	
	// Initialize M_PeakLoc, etc.
	Make/O/N=(nStim,nROI) M_Base,M_PeakLoc,M_PeakAmp,M_LeftLoc,M_RightLoc,M_Percent,M_Duration,M_Odor2Peak
	M_Base=NaN
	M_PeakLoc=NaN
	M_PeakAmp=NaN
	M_LeftLoc=NaN
	M_RightLoc=NaN
	M_Percent=NaN
	M_Duration=NaN
	M_Odor2Peak=NaN
	
	// Dimension labels
	Variable i,m
	String strLabel
	for(i=0;i<nStim;i+=1)
		strLabel="Stim"+num2str(i+1)
		SetDimLabel 0,i,$strLabel,M_Base,M_PeakLoc,M_PeakAmp,M_LeftLoc,M_RightLoc,M_Percent,M_Duration,M_Odor2Peak
		for(m=0;m<nROI;m+=1)
			if (i==0)
				strLabel="ROI"+num2str(m+1)
				SetDimLabel 1,m,$strLabel,M_Base,M_PeakLoc,M_PeakAmp,M_LeftLoc,M_RightLoc,M_Percent,M_Duration,M_Odor2Peak
			endif
		endfor
	endfor
	
	WAVE w
	Duplicate/O w,wPeakMarker,wLeftMarker,wRightMarker
	wPeakMarker=NaN
	wLeftMarker=NaN
	wRightMarker=NaN
	
	// Graph the result of stimulus detection
	DoWindow GraphOdor
	if (V_flag)
		KillWindow GraphOdor
	endif
	Display/N=GraphOdor as "Odor response"
	
	ResizeWindow(1280,400)
	
	AppendToGraph w
	
	AppendToGraph wPeakMarker
	ModifyGraph mode(wPeakMarker)=3,marker(wPeakMarker)=8
	ModifyGraph msize(wPeakMarker)=6
	ModifyGraph rgb(wPeakMarker)=(1,16019,65535)
	
	AppendToGraph wLeftMarker
	ModifyGraph mode(wLeftMarker)=3,marker(wLeftMarker)=46
	ModifyGraph msize(wLeftMarker)=6
	ModifyGraph rgb(wLeftMarker)=(1,16019,65535)
	
	AppendToGraph wRightMarker
	ModifyGraph mode(wRightMarker)=3,marker(wRightMarker)=49
	ModifyGraph msize(wRightMarker)=6
	ModifyGraph rgb(wRightMarker)=(1,16019,65535)
	
	WAVE wBarLight
	AppendToGraph wBarLight
	ModifyGraph lsize(wBarLight)=3,rgb(wBarLight)=(65535,65532,16385)
	ModifyGraph offset(wBarLight)={0,-20}
	
	WAVE wBarOdor
	AppendToGraph wBarOdor
	ModifyGraph lsize(wBarOdor)=3,rgb(wBarOdor)=(3,52428,1)
	ModifyGraph offset(wBarOdor)={0,-20}
	
	// Make an overview window below
	DoWindow GraphOdor_1
	if (V_flag)
		KillWindow GraphOdor_1
	endif
	DoIgorMenu "Edit","Duplicate"	// duplicate window
	DoWindow/T GraphOdor_1,"Overview"
	SetAxis bottom 0,rightx(w)		// Force the left-end to be 0 s
	ResizeWindow(1280,200)
	AutoPositionWindow/E/M=1
	
	ControlBar/L/W=GraphOdor 75
	
	Variable k=1	// 1-based stim number
	
	DoWindow/F GraphOdor
	
	SetVariable setvarCFEvokedPercent title="%",proc=SetVarProcCFEvokedPercent
	SetVariable setvarCFEvokedPercent value= _NUM:50,limits={0,100,1},live=1
	SetVariable setvarCFEvokedPercent size={75,20},pos={1,50}
	
	SetVariable setvarCFEvokedPeakLoc title="Peak",size={75,20},pos={1,120}
	SetVariable setvarCFEvokedPeakLoc proc=SetVarProcCFEvokedPeakLoc,value= _NUM:(wOdorOnLoc[0]+10)
	SetVariable setvarCFEvokedPeakLoc limits={wOdorOnLoc[0],wOdorOnLoc[0]+50,0.05},live=1
	
	Slider sliderCFEvokedPeakLoc vert=0,side=0,proc=SliderProcCFEvokedPeakLoc
	Slider sliderCFEvokedPeakLoc value=wOdorOnLoc[0]+10,limits={wOdorOnLoc[0],wOdorOnLoc[0]+50,0.05}
	Slider sliderCFEvokedPeakLoc pos={0,140},size={75,13}
	
	SetVariable setvarCFEvokedBaseline title="Base",size={75,20},pos={1,211}
	SetVariable setvarCFEvokedBaseline proc=SetVarProcCFEvokedBaseline
	SetVariable setvarCFEvokedBaseline value= _NUM:0,limits={WaveMin(w),WaveMax(w),1},live=1
	
	Slider sliderCFEvokedBaseline side=0,proc=SliderProcCFEvokedBaseline,value=0
	Slider sliderCFEvokedBaseline limits={WaveMin(w),WaveMax(w),0},ticks=0
	Slider sliderCFEvokedBaseline size={13,100},pos={35,235}
	
	SetVariable setvarCFEvokedStimNum title="Stim",size={75,20},pos={1,350}
	SetVariable setvarCFEvokedStimNum proc=SetVarProcCFEvokedStimNum,value= _NUM:k
	SetVariable setvarCFEvokedStimNum limits={1,nStim,1},live=1
	
	SetVariable setvarCFEvokedROINum title="ROI",size={75,20},pos={1,370}
	SetVariable setvarCFEvokedROINum proc=SetVarProcCFEvokedROINum,value= _NUM:1
	SetVariable setvarCFEvokedROINum limits={1,nROI,1},live=1
	
	Button buttonCFEvokedShowData title="Data",pos={1200,50}
	Button buttonCFEvokedShowData proc=ButtonProcCFEvokedShowData,fColor=(0,0,65535)
	Button buttonCFEvokedShowData valueColor=(65535,65535,65535)
	
	// Set range, baseline, etc., for each odor stimulus
	hiroCFEvokedStep2Update(k,j)
	
End


Function ButtonProcCFEvokedShowData(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE w
			
			WAVE M_Base
			WAVE M_Duration
			WAVE M_LeftLoc
			WAVE M_Odor2Peak
			WAVE M_PeakAmp
			WAVE M_PeakLoc
			WAVE M_Percent
			WAVE M_RightLoc
			WAVE wOnLoc
			WAVE wOffLoc
			WAVE wOdorOnLoc
			WAVE wOdorOffLoc
			
			String yUnit=WaveUnits(w,-1)
			String xUnit=WaveUnits(w,0)
			
			Variable width=400
			Variable height=200
			
			Edit/K=1/W=(0,0,width,height) M_Base.ld as "Baseline ("+yUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_Percent.ld as "%-level (%)"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_Duration.ld as "%-amplitude duration ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_LeftLoc.ld as "Left marker ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_RightLoc.ld as "Right marker ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_PeakLoc.ld as "Time at peak ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_PeakAmp.ld as "Peak amplitude ("+yUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) M_Odor2Peak.ld as "Latency to peak ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) wOnLoc,wOffLoc as "Onset and offset of light stimuli ("+xUnit+")"
			AutoPositionWindow/E
			Edit/K=1/W=(0,0,width,height) wOdorOnLoc,wOdorOffLoc as "Onset and offset of odor stimuli ("+xUnit+")"
			AutoPositionWindow/E
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcCFEvokedPercent(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable k,j
			
			ControlInfo/W=GraphOdor setvarCFEvokedStimNum
			k=V_Value
			
			ControlInfo/W=GraphOdor setvarCFEvokedROINum
			j=V_Value
			
			hiroCFEvokedAnalyzeLeftRight(k,j)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SetVarProcCFEvokedPeakLoc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroCFEvokedUpdatePeakLoc(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SliderProcCFEvokedPeakLoc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				hiroCFEvokedUpdatePeakLoc(curval)
				
			endif
			break
	endswitch

	return 0
End


Function SliderProcCFEvokedBaseline(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				hiroCFEvokedUpdateBaseline(curval)
				
				SetVariable setvarCFEvokedBaseline value=_NUM:curval
				
			endif
			break
	endswitch

	return 0
End


Function SetVarProcCFEvokedBaseline(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			hiroCFEvokedUpdateBaseline(dval)
			
			Slider sliderCFEvokedBaseline value=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcCFEvokedROINum(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable j=floor(dval)
			
			// Get the wave for ROI#j
			hiroCFEvokedUpdateWave(j)
			
			Variable k
			//ControlInfo/W=GraphOdor setvarCFEvokedStimNum
			//k=V_Value
			
			k=1 // init
			SetVariable setvarCFEvokedStimNum, value=_NUM:k
			
			hiroCFEvokedStep2Update(k,j)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcCFEvokedStimNum(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable k=floor(dval)
			
			ControlInfo/W=GraphOdor setvarCFEvokedROINum
			Variable j=V_Value
			
			hiroCFEvokedStep2Update(k,j)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroCFEvokedUpdatePeakLoc(xloc)
	
	Variable xloc
	
	WAVE w
	WAVE wPeakMarker
	wPeakMarker=NaN
	
	Variable ploc=x2pnt(wPeakMarker,xloc)
	wPeakMarker[ploc]=w[ploc]
	
	Variable k,j,base
	ControlInfo/W=GraphOdor setvarCFEvokedStimNum
	k=V_Value
	ControlInfo/W=GraphOdor setvarCFEvokedROINum
	j=V_Value
	
	ControlInfo/W=GraphOdor setvarCFEvokedBaseline
	base=V_Value
	
	// Store value
	hiroCFEvokedStorePeak(xloc,base,k,j)
	
	SetVariable setvarCFEvokedPeakLoc value=_NUM:xloc
	Slider sliderCFEvokedPeakLoc value=xloc
	
	hiroCFEvokedAnalyzeLeftRight(k,j)
	
End


Function hiroCFEvokedStep2Update(k,j)
	
	Variable k	// 1-based stim number
	Variable j	// 1-based ROI number
	
	WAVE w
	WAVE wOdorOnLoc
	
	// reset
	WAVE wPeakMarker
	WAVE wLeftMarker
	WAVE wRightMarker
	wPeakMarker=NaN
	wLeftMarker=NaN
	wRightMarker=NaN
	
	Variable sLightDuration=ksLightDuration
	Variable sOdorAfterLight=ksOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	if (V_flag)
		sLightDuration=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	if (V_flag)
		sOdorAfterLight=V_Value
	endif
	
	Variable x1=wOdorOnLoc[k-1]-sOdorAfterLight
	Variable x2=x1+sLightDuration
	
	// Draw curtain to highlight a response
	DrawAction/W=GraphOdor_1/L=ProgBack delete
	SetDrawLayer/W=GraphOdor_1 ProgBack
	
	SetDrawEnv/W=GraphOdor_1 xcoord= bottom,fillfgc= (52428,52428,52428),linethick= 0.00
	DrawRect/W=GraphOdor_1 0,1,x1,0
	
	SetDrawEnv/W=GraphOdor_1 xcoord= bottom,fillfgc= (52428,52428,52428),linethick= 0.00
	DrawRect/W=GraphOdor_1 x2,1,rightx(w),0
	
	// Focus on main graph
	DoWindow/F GraphOdor
	
	XAxisScrolling2(x1,x2)
	
	// Check if the baseline is already set
	Variable base
	WAVE M_Base
	if (numtype(M_Base[k-1][j-1])==0)
		// load value
		base=M_Base[k-1][j-1]
	else
		// Estimate baseline between x1 and x2
		base=hiroCFEvokedGuessBaseline(w,x1,x2)
	endif
	
	hiroCFEvokedUpdateBaseline(base)
	
End


Function hiroCFEvokedUpdateBaseline(base)
	
	Variable base
	
	WAVE w
	
	// Draw a dotted line to indicate baseline
	DrawAction/W=GraphOdor/L=ProgBack delete
	SetDrawLayer/W=GraphOdor ProgBack
	
	SetDrawEnv/W=GraphOdor ycoord= left,dash= 2
	DrawLine/W=GraphOdor 0,base,1,base
	
	Variable x1,x2
	
	GetAxis/W=GraphOdor/Q bottom
	x1=V_min
	x2=V_max
	
	// Improve y-axis on GraphOdor
	Variable yMax=WaveMax(w,x1,x2)+20
	Variable yMin=base-20
	
	SetAxis/W=GraphOdor left yMin,yMax
	
	Slider sliderCFEvokedBaseline limits={yMin,yMax,0},value=base
	SetVariable setvarCFEvokedBaseline limits={yMin,yMax,1},value=_NUM:base
	
	// Offset stimulus bars close to baseline
	ModifyGraph/W=GraphOdor offset(wBarLight)={0,yMin}
	ModifyGraph/W=GraphOdor offset(wBarOdor)={0,yMin}
	
	// Store baseline value
	Variable k,j
	ControlInfo/W=GraphOdor setvarCFEvokedStimNum
	k=V_Value
	ControlInfo/W=GraphOdor setvarCFEvokedROINum
	j=V_Value
	WAVE M_Base
	M_Base[k-1][j-1]=base
	
	hiroCFEvokedAnalyzePeak(base,k,j)
	
End


Function hiroCFEvokedAnalyzePeak(base,k,j)
	
	Variable base
	Variable k
	Variable j
	
	Variable peakloc,peak
	
	WAVE M_PeakLoc
	WAVE w
	WAVE wOdorOnLoc
	
	Variable sLightDuration=ksLightDuration
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	if (V_flag)
		sLightDuration=V_Value
	endif
	
	Variable x1=wOdorOnLoc[k-1]
	Variable x2=x1+sLightDuration
	
	if (numtype(M_PeakLoc[k-1][j-1])==0)
		// Load
		peakloc=M_PeakLoc[k-1][j-1]
		peak=w(peakloc)
	else
		// Guess
		WaveStats/M=1/Q/R=(x1,x2) w
		
		peakloc=V_maxloc
		peak=V_max
	endif
	
	//Cursor/A=0 A w peakloc
	WAVE wPeakMarker
	wPeakMarker[x2pnt(w,peakloc)]=peak
	
	// Store in matrix
	hiroCFEvokedStorePeak(peakloc,base,k,j)
	
	// Redef limits control
	SetVariable setvarCFEvokedPeakLoc limits={x1,x2,0.05},value=_NUM:peakloc
	Slider sliderCFEvokedPeakLoc limits={x1,x2,0.05},value=peakloc
	
	hiroCFEvokedAnalyzeLeftRight(k,j)
	
End


Function hiroCFEvokedStorePeak(peakloc,base,k,j)
	
	Variable peakloc
	Variable base
	Variable k
	Variable j
	
	WAVE M_PeakLoc
	WAVE M_Odor2Peak
	WAVE M_PeakAmp
	
	Variable odor2peak,peakamp
	
	WAVE wOdorOnLoc
	Variable x1=wOdorOnLoc[k-1]
	odor2peak=peakloc-x1
	
	WAVE w
	peakamp=w[x2pnt(w,peakloc)]-base
	
	// Store peakloc
	M_PeakLoc[k-1][j-1]=peakloc
	M_Odor2Peak[k-1][j-1]=odor2peak
	M_PeakAmp[k-1][j-1]=peakamp
	
End


Function hiroCFEvokedAnalyzeLeftRight(k,j)
	
	Variable k
	Variable j
	
	Variable level,xloc,ploc,peak,base,percent,fraction,range1,range2,xleft,xright,pleft,pright,xduration
	
	ControlInfo/W=GraphOdor setvarCFEvokedPercent
	percent=V_Value
	fraction=percent*0.01
	
	ControlInfo/W=GraphOdor setvarCFEvokedPeakLoc
	xloc=V_Value
	
	WAVE w
	ploc=x2pnt(w,xloc)
	peak=w[ploc]
	
	ControlInfo/W=GraphOdor setvarCFEvokedBaseline
	base=V_Value
	
	level=peak-(1-fraction)*(peak-base)
	
	WAVE wOdorOnLoc
	//range1=wOdorOnLoc[k-1]
	
	GetAxis/W=GraphOdor/Q bottom
	range1=V_min
	range2=V_max
	
	// Nearest left (reverse search)
	FindLevel/R=(xloc,range1)/Q w,level
	if (!V_Flag)
		xleft=V_LevelX
	else
		xleft=range1
	endif
	pleft=x2pnt(w,xleft)
	WAVE wLeftMarker
	wLeftMarker=NaN	// reset
	wLeftMarker[pleft]=w[pleft]
	
	// Nearest right
	FindLevel/R=(xloc,range2)/Q w,level
	if (!V_Flag)
		xright=V_LevelX
	else
		xright=range2
	endif
	pright=x2pnt(w,xright)
	WAVE wRightMarker
	wRightMarker=NaN	// reset
	wRightMarker[pright]=w[pright]
	
	xduration=xright-xleft
	
	// Store results
	WAVE M_LeftLoc
	WAVE M_RightLoc
	WAVE M_Percent
	WAVE M_Duration
	
	M_LeftLoc[k-1][j-1]=xleft
	M_RightLoc[k-1][j-1]=xright
	M_Percent[k-1][j-1]=percent
	M_Duration[k-1][j-1]=xduration
	
End


Function hiroCFEvokedGuessBaseline(w,x1,x2)
	
	WAVE w
	Variable x1
	Variable x2
	
	Variable base
	
	Duplicate/FREE/R=(x1,x2) w,wFree
	base=StatsMedian(wFree)
	
	// Improve y-axis on GraphOdor
	//Variable yMax=WaveMax(w,x1,x2)+20
	//Variable yMin=base-20
	
	//Slider sliderCFEvokedBaseline limits={yMin,yMax,0},value=base
	//SetVariable setvarCFEvokedBaseline limits={yMin,yMax,1},value=_NUM:base
	
	Slider sliderCFEvokedBaseline value=base
	SetVariable setvarCFEvokedBaseline value=_NUM:base
	
	return base
	
End


Function hiroCFEvokedMakeStimBars()
	
	WAVE w
	
	// Light stim bar
	WAVE wOnLoc
	WAVE wOffLoc
	
	Duplicate/O w,wBarLight
	WAVE wBarLight
	wBarLight=NaN
	
	Variable nStim=numpnts(wOnLoc)
	Variable i,p1,p2
	for(i=0;i<nStim;i+=1)
		p1=x2pnt(wBarLight,wOnLoc[i])
		p2=x2pnt(wBarLight,wOffLoc[i])
		wBarLight[p1,p2]=0
	endfor
	
	// Odor stim bar
	WAVE wOdorOnLoc
	WAVE wOdorOffLoc
	
	Duplicate/O w,wBarOdor
	WAVE wBarOdor
	wBarOdor=NaN
	
	nStim=numpnts(wOdorOnLoc)
	for(i=0;i<nStim;i+=1)
		p1=x2pnt(wBarOdor,wOdorOnLoc[i])
		p2=x2pnt(wBarOdor,wOdorOffLoc[i])
		wBarOdor[p1,p2]=0
	endfor
	
End


Function hiroCFEvokedUpdateWave(j)
	
	Variable j	// 1-based ROI
	
	Variable range1,range2
	
	range1=pcsr(A,"GraphStep1")
	range2=pcsr(B,"GraphStep1")
	
	//WAVE M0
	WAVE M_smooth
	Duplicate/O/R=[range1,range2][j-1] M_smooth,w
	
End


Function hiroCFEvokedDetectStim(j)
	// Modified from OdorLightBaselineAnalysis()
	
	Variable j	// 1-based ROI
	
	//DFREF dfrSaved=GetDataFolderDFR()
	
	// Get the wave for ROI#j
	hiroCFEvokedUpdateWave(j)
	
	WAVE w
	
	Variable nStim, flag, trial
	Variable thresh=WaveMax(w)/2
	
	// Load user-defined variables
	Variable sLightDuration=ksLightDuration
//	Variable sOdorDuration=ksOdorDuration
//	Variable sOdorBeforeLight=ksOdorBeforeLight
//	Variable sOdorAfterLight=ksOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	if (V_flag)
		sLightDuration=V_Value
	endif
	
//	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
//	if (V_flag)
//		sOdorDuration=V_Value
//	endif
//	
//	ControlInfo/W=GraphCFEvokedStep0 setvarBeforeLight
//	if (V_flag)
//		sOdorBeforeLight=V_Value
//	endif
//	
//	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
//	if (V_flag)
//		sOdorAfterLight=V_Value
//	endif
	
	// Optionally check the result and redo with a different threshold in a loop
	do
		trial+=1
		nStim=AutoDetectLightOnset2(w,thresh)	// Outputs wOnLoc and wOffLoc
		
		WAVE wOnLoc
		WAVE wOffLoc
		
		// Confirm the number of stim
		if (nStim==numpnts(wOffLoc))
			flag=1	// confirmed
		else
			flag=0	// wOnLoc and wOffLoc are different lengths. Try with different thresh
			thresh-=10
		endif
		
		if (flag)
			// Duration should match the user-supplied value (default: 30 s) for each stim
			Make/FREE/N=(nStim) wDiff
			wDiff=round(wOffLoc-wOnLoc)
			if (round(mean(wDiff))==sLightDuration && variance(wDiff)<1)
				flag=1
			else
				flag=0
				thresh-=10
			endif
		endif
		
		if (flag)	// detection verified
			break
		endif
	while(trial<10)
	
	if (trial>=10)
		hiroCFEvokedPickStimuli(w,wOnLoc,wOffLoc,round(mean(wDiff)),sLightDuration)
	endif
	
	//Print nStim,"light stimuli detected!"
	
	// Refine stimulus onset
	hiroCFEvokedRefineLightOnset(w,wOnLoc,wOffLoc)
	
	// Auto-detect odor locations. Outputs wOdorOnLoc and wOdorOffLoc
	AutoLocateOdorStim()
	
	//SetDataFolder dfrSaved
	
End


Function hiroCFEvokedPickStimuli(w,wOnLoc,wOffLoc,avgDuration,sLightDuration)
	// After 10 failed trials of auto-stimulus detection, let user see the problem and manually pick stimuli
	
	WAVE w
	WAVE wOnLoc
	WAVE wOffLoc
	Variable avgDuration	// mean duration of all the detected light stimulus (may contain artifacts)
	Variable sLightDuration
	
	String strTitle="Pick stimuli (duration should be "+num2str(sLightDuration)+" +/- 1s)"
	
	Display/K=2/N=GraphPickStim w as strTitle
	ModifyGraph/W=GraphPickStim rgb(w)=(34816,34816,34816)
	
	ResizeWindow(700,300)
	
	// Prompt user with instructions
	String strErr="The algorithm found "+num2str(numpnts(wOnLoc))+" possible stimuli.\rIt reports, however, that the avg light duration is "+num2str(avgDuration)+", not "+num2str(sLightDuration)+" s.\rThis may, or may not be, a problem to you.\r\rNext, it will auto-scan and show you any problem.\rCan you pick which stimuli to keep?"
	DoAlert/T="Help! Stimulus auto-detection is having a problem after trying 10 times..." 0, strErr
	
	ControlBar/L 120
	
	// stimulus bar will be offset by 15% of the amplitude below w
	Variable offset=WaveMin(w)-0.15*(WaveMax(w)-WaveMin(w))
	
	// For each putative stimulus, a stimulus bar will be made by a simple wave technique. Store all waves in a temp DF
	if (DataFolderExists(":TempDF"))
		KillDataFolder :TempDF
	endif
	NewDataFolder TempDF
	
	Variable nStim=numpnts(wOnLoc)
	Make/N=(nStim) :TempDF:selStim /WAVE=selStim	// will be used to keep track of which stimulus is included by the user
	selStim=1	// init
	
	String nameW,nameTag,nameCheck,titleCheck
	
	Variable i,duration,flag,ctrlPosY
	for (i=0;i<nStim;i+=1)
		flag=0	// init
		
		// Make a simple wave inside the temp DF
		nameW="wBar"+num2str(i)
		Make/N=2 :TempDF:$nameW /WAVE=wBar
		
		// Scale x as start and end of wOnLoc[i] and wOffLoc[i]
		SetScale/I x wOnLoc[i],wOffLoc[i],"", wBar
		
		// Flag if the duration do not match the user-supplied value +/-1
		duration=wOffLoc[i]-wOnLoc[i]
		if (round(duration+1)<sLightDuration)
			flag=1
		elseif (round(duration-1)>sLightDuration)
			flag=2
		endif
		
		AppendToGraph/W=GraphPickStim wBar
		ModifyGraph/W=GraphPickStim offset($nameW)={0,offset},lsize($nameW)=3
		ModifyGraph/W=GraphPickStim rgb($nameW)=(0,34816,52224)
		
		// Add a tag
		nameTag="tag"+num2str(i)
		Tag/N=$nameTag/F=0/S=0/Z=1/L=0 $nameW, wOnLoc[i],num2str(i+1)
		Tag/C/N=$nameTag/A=MC/B=1/X=1.00/G=(0,34816,52224)
		
		// Add checkbox
		ctrlPosY=20*i+2
		nameCheck="check"+num2str(i)
		titleCheck=num2str(i+1)
		CheckBox $nameCheck title=titleCheck,pos={1,ctrlPosY},userData=num2str(i)
		CheckBox $nameCheck proc=CheckProcCFEvokedPickStim,value=1
		
		// Handle errors based on the flag above
		if (flag)
			selStim[i]=0
			ModifyGraph/W=GraphPickStim rgb($nameW)=(65280,0,0)
			Tag/C/N=$nameTag/G=(65280,0,0)
			if (flag==1)
				titleCheck+=" (too short: "+num2str(duration)+"s)"
			elseif (flag==2)
				titleCheck+=" (too long: "+num2str(duration)+"s)"
			endif
			CheckBox $nameCheck title=titleCheck,value=0
		endif
	endfor
	
	// add a button below the last checkbox
	ctrlPosY=20*i+2
	Button buttonCFPickStim title="Keep",pos={1,ctrlPosY},proc=ButtonProcCFPickStim
	Button buttonCFPickStim fColor=(0,12800,52224),valueColor=(65535,65535,65535)
	
	// disable this button if no checkbox is checked
	if (sum(selStim)==0)
		Button buttonCFPickStim disable=2
	endif
	
	// cancel button (will terminate program)
	Button buttonCFPickStimCancel title="Cancel",pos={61,ctrlPosY}
	Button buttonCFPickStimCancel proc=ButtonProcCFPickStimCancel
	
	// If no detailed problem exist, recommend the user to just keep all the stimuli.
	//Extract/FREE/INDX selStim,wINDX,selStim==0
	//if (numtype(wINDX)==2)
	if (sum(selStim)==numpnts(wOnLoc))
		i+=1
		ctrlPosY=20*i+2
		TitleBox titleOk title="Everything looks OK.\rClick the Keep button\rand continue."
		TitleBox titleOk pos={1,ctrlPosY},frame=0
	endif
	
	PauseForUser GraphPickStim	// returns when the graph is killed
	
End


Function ButtonProcCFPickStim(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			WAVE wOnLoc
			WAVE wOffLoc
			WAVE selStim=:TempDF:selStim
			
			// Modify wOnLoc and wOffLoc based on user-selected stimuli
			Extract/O wOnLoc,wOnLoc,selStim==1
			Extract/O wOffLoc,wOffLoc,selStim==1
			
			KillWindow GraphPickStim
			KillDataFolder :TempDF
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcCFPickStimCancel(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			DoAlert/T="Wow, wait!" 1, "Program will terminate. Are you sure?"
			if (V_flag==1)
				KillWindow GraphPickStim
				KillDataFolder :TempDF
				Print "User canceled procedure"
				Abort
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcCFEvokedPickStim(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			WAVE selStim=:TempDF:selStim	// 0 or 1 based on selection
			
			// get zero-based stim number
			Variable i=str2num(cba.userData)
			//Print i
			
			String nameW="wBar"+cba.userData
			String nameTag="tag"+cba.userData
			
			if (checked)
				// blue
				ModifyGraph/W=GraphPickStim rgb($nameW)=(0,34816,52224)
				Tag/C/N=$nameTag/G=(0,34816,52224)
				selStim[i]=1
			else
				// red
				ModifyGraph/W=GraphPickStim rgb($nameW)=(65280,0,0)
				Tag/C/N=$nameTag/G=(65280,0,0)
				selStim[i]=0
			endif
			
			// Disable button if none of the checkbox is selected
			if (sum(selStim)==0)
				Button buttonCFPickStim disable=2
			else
				Button buttonCFPickStim disable=0
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroCFEvokedRefineLightOnset(w,wOnLoc,wOffLoc)
	
	WAVE w
	WAVE wOnLoc
	WAVE wOffLoc
	
	Variable vHere,vOneInFront
	
	Variable xHere,xOneInFront
	Variable pHere,pOneInFront
	Variable pOrig,pShifted
	Variable xShifted
	
	xHere=wOnLoc[0]
	pHere=x2pnt(w,xHere)
	pOrig=pHere
	
	do
		pHere-=1
		pOneInFront=pHere-1
		vHere=w[pHere]
		vOneInFront=w[pOneInFront]
	while(vHere>vOneInFront+10)	// two data points are within 10 dF/F of each other
	
	// How many data points to shift?
	pShifted=pOrig-pHere-1
	
	// Convert to seconds
	xShifted=pShifted*deltax(w)
	
	// Adjust
	wOnLoc-=xShifted
	wOffLoc-=xShifted
	
End


// Consuelo's baseline analysis
// 1. Detect light onset and offset (~30 s duration).
// 2. Odor (5 s duration) is given 1 s after light onset.
// 3. Odor was given 60 s earlier without the light.
// 4. Next Odor happens 90 s later
// 5. Consuelo will select baseline in a blind fashion, so randomize order of traces and hide axes
// 6. Baseline will be normalized "before" and "after" light.  Show the pair side by side.
Function OdorLightBaselineAnalysis()
	
	DFREF dfrSaved=GetDataFolderDFR()
	
	NVAR step
	step=2
	
	DoWindow/HIDE=1 GraphStep1
	
	Variable j
	String nameTrace
	
	// wave may be loaded using my script or manually
	WAVE/Z M0
	if (WaveExists(M0))
		// data loaded as matrix using my script
		do
			Prompt j, "ROI number (1-"+num2str(DimSize(M0,1))+")"
			DoPrompt/HELP="ROI number is a positive integer above 0. Hit a tab-key to toggle between the two fields." "Trace number",j
			
			j=floor(j)
			
			if (V_flag == 1)
				Print "User Canceled Procedure"
				Abort	//quit if cancel button was clicked
			endif
		while(j<=0 && j>=DimSize(M0,1))
		
		nameTrace = "filteredData"+num2str(j)
		WAVE M_smooth
		Duplicate/O/R=[*][j-1] M_smooth,$nameTrace
	else
		// the old fashioned way
		Prompt nameTrace, "Trace:", popup, WaveList("*",";","DIMS:1")
		DoPrompt/HELP="Select a wave.  Tab-key toggles between the two fields." "Select a wave",nameTrace
		if (V_flag == 1)
			Print "User Canceled Procedure"
			Abort	//quit if cancel button was clicked
		else
			if (cmpstr(nameTrace,"_none_")==0)
				DoAlert/T="Wave not selected" 0, "You need to select a wave.\rTry again."
				Abort
			endif
		endif
	endif
	
	WAVE w=$nameTrace
	
	Print nameTrace
	
	DoWindow GraphOdor
	if (V_flag)
		KillWindow GraphOdor
	endif
	
	//? This is shown only during development
	if (kIsDevMode)
		Display/N=GraphOdor as nameTrace
		AppendToGraph w
	else
		Display/N=GraphOdor as nameTrace+": Blind mode"
	endif
	
	String nameDF=nameTrace
	
	SetDataFolder root:
	NewDataFolder/O/S temp
	
	Duplicate/O w,data
	
	//AutoDetectLightOnset(w)
	
	Variable nStim, flag, trial
	Variable thresh=WaveMax(w)/2
	
	// Load user-defined variables
	Variable sLightDuration=ksLightDuration
	Variable sOdorDuration=ksOdorDuration
	Variable sOdorBeforeLight=ksOdorBeforeLight
	Variable sOdorAfterLight=ksOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	if (V_flag)
		sLightDuration=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
	if (V_flag)
		sOdorDuration=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarBeforeLight
	if (V_flag)
		sOdorBeforeLight=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	if (V_flag)
		sOdorAfterLight=V_Value
	endif
	
	
	// Optionally check the result and redo with a different threshold in a loop
	do
		trial+=1
		nStim=AutoDetectLightOnset2(w,thresh)
		
		WAVE wOnLoc
		WAVE wOffLoc
		
		// Confirm the number of stim
		if (nStim==numpnts(wOffLoc))
			flag=1	// confirmed
		else
			flag=0	// wOnLoc and wOffLoc are different lengths. Try with different thresh
			thresh-=10
		endif
		
		if (flag)
			// Duration should be 30 s for each stim
			Make/FREE/N=(nStim) wDiff
			wDiff=round(wOffLoc-wOnLoc)
			if (round(mean(wDiff))==sLightDuration && variance(wDiff)<1)
				flag=1
			else
				flag=0
				thresh-=10
			endif
		endif
		
		if (flag)	// detection verified
			break
		endif
	while(trial<10)
	
	if (trial>=10)
		DoAlert 0, "Stimulus could not be auto-detected after trying for 10 times.\rSee Hiro"
		Abort
	endif
	
	//Print nStim,"light stimuli detected!"
	
	// Refine light onset
	hiroCFEvokedRefineLightOnset(w,wOnLoc,wOffLoc)
	
	Make/O/N=(nStim*2) wStim	// double to include number of odor stims
	WAVE wStim
	
	//? This is only shown during dev
	//if (kIsDevMode)
		AppendToGraph wStim vs wOnLoc
		AppendToGraph wStim vs wOffLoc
		ModifyGraph mode(wStim)=3,marker(wStim)=10,rgb(wStim)=(0,0,0)
		ModifyGraph offset(wStim)={0,-10},mode(wStim#1)=3,marker(wStim#1)=10
		ModifyGraph rgb(wStim#1)=(0,0,0),offset(wStim#1)={0,-10}
	//endif
	
	// Auto-detect odor locations
	AutoLocateOdorStim()
	
	//? This is only shown during dev
	//if (kIsDevMode)
		WAVE w1=wOdorOnLoc
		WAVE w2=wOdorOffLoc
		AppendToGraph wStim vs w1
		AppendToGraph wStim vs w2
		ModifyGraph mode(wStim#2)=3,marker(wStim#2)=10,rgb(wStim#2)=(0,0,0)
		ModifyGraph offset(wStim#2)={0,-20},mode(wStim#3)=3,marker(wStim#3)=10
		ModifyGraph rgb(wStim#3)=(0,0,0),offset(wStim#3)={0,-20}
	//endif
	
	DoUpdate
	
	// analyze baseline
	DoAlert/T=num2str(nStim)+" light stimuli detected!" 2, "Next:\rReady to analyze baseline?"
	if (V_flag==1)
		if (!kIsDevMode)
			AppendToGraph w
			ModifyGraph noLabel(bottom)=2,axThick(bottom)=0
		endif
		AnalyzeOdorBaseline(w)
	else
		Print "User ended the procedure"
		DoWindow GraphOdor
		if (V_flag)
			KillWindow GraphOdor
		endif
		SetDataFolder dfrSaved
		Abort
	endif
	
	// slice out the traces
	SliceOdorTraces()
	
	// visualize the first pair: before and after
	WAVE w0_before
	WAVE w0_after
	Duplicate/O w0_before,wBefore
	Duplicate/O w0_after,wAfter
	Display/N=GraphOdorPair wBefore,wAfter as "Before and After Light: "+nameTrace
	ModifyGraph rgb(wBefore)=(0,0,0),margin(left)=85
	
	SetAxis left -20,*
	
	SetDrawEnv xcoord= bottom,ycoord= left,linethick= 3.00
	DrawLine sOdorAfterLight,-15,sOdorAfterLight+sOdorDuration,-15
	
	Legend/C/N=text0/J/F=0/A=RT "\\s(wBefore) Before light\r\\s(wAfter) After light"
	Legend/C/N=text0/J/X=0.00/Y=0.00
	
	ResizeWindow(1000,300)
	SetVariable setvarTrial pos={1,250},proc=SetVarProcTrial,limits={1,numpnts(wOnLoc),1},live=1,value=_NUM:1
	SetVariable setvarTrial userdata=nameDF
	CheckBox checkNorm title="Normalize",pos={1,275},proc=CheckProcOdorNormalize
	
	ShowOdorPair(1)
	
	nameDF=CheckDFDuplicates(nameDF)
	// update the userdata
	SetVariable setvarTrial userdata=nameDF
	
	SetDataFolder dfrSaved
	
End


Function NormalizeOdorResponse(i)
	// traces wBefore and wAfter on the graph are divided by SD of the baseline
	
	Variable i	// 1-based from setvar
	
	i-=1	// waves are zero-based
	
	String nameDF=GetUserData("","setvarTrial","")
	
	DFREF dfr=root:$nameDF
	
	WAVE wBefore=dfr:wBefore
	WAVE wAfter=dfr:wAfter
	WAVE BaseSD=dfr:BaseSD
	WAVE BaseSD=dfr:BaseSD
	
	wBefore/=BaseSD[2*i]
	wAfter/=BaseSD[2*i+1]
	
	Label left "Normalized"
	
End


Function CheckProcOdorNormalize(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			ControlInfo setvarTrial
			Variable i=V_value
			//Print i
			
			if (checked)
				NormalizeOdorResponse(i)
				
				i-=1
				
				String nameDF=GetUserData("","setvarTrial","")
				DFREF dfr=root:$nameDF
				
				WAVE BaseAvgNorm=dfr:BaseAvgNorm
				
				Variable avgBefore
				Variable avgAfter
				
				avgBefore=BaseAvgNorm[2*i]
				avgAfter=BaseAvgNorm[2*i+1]
				
				ModifyGraph offset(wBefore)={0,-avgBefore}
				ModifyGraph offset(wAfter)={0,-avgAfter}
				
			else
				ShowOdorPair(i)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ShowOdorPair(i)
	
	Variable i	// comes from setvar (1-based)
	
	i-=1	// waves are zero-based
	
	String nameDF=GetUserData("","setvarTrial","")
	
	String nameWBefore="w"+num2str(i)+"_before"
	String nameWAfter="w"+num2str(i)+"_after"
	
	DFREF dfr=root:$nameDF
	
	Duplicate/O dfr:$nameWBefore,dfr:wBefore
	Duplicate/O dfr:$nameWAfter,dfr:wAfter
	
	WAVE wBefore=dfr:wBefore
	WAVE wAfter=dfr:wAfter
	WAVE BaseAvg=dfr:BaseAvg
	WAVE BaseAvgNorm=dfr:BaseAvgNorm
	
	ReplaceWave trace=wBefore,wBefore
	ReplaceWave trace=wAfter,wAfter
	
	Variable avgBefore
	Variable avgAfter
	
	// Check if "Normalize" is on
	ControlInfo checkNorm
	//Print V_value
	if (V_value)
		NormalizeOdorResponse(i+1)	// increment by one to revert to 1-based
		avgBefore=BaseAvgNorm[2*i]
		avgAfter=BaseAvgNorm[2*i+1]
	else
		// Adjust offset
		avgBefore=BaseAvg[2*i]
		avgAfter=BaseAvg[2*i+1]
		Label left ""
	endif
	
	ModifyGraph offset(wBefore)={0,-avgBefore}
	ModifyGraph offset(wAfter)={0,-avgAfter}
	
End


Function SetVarProcTrial(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Reset offset
			//ModifyGraph offset(wBefore)={0,0}
			//ModifyGraph offset(wAfter)={0,0}
			
			ShowOdorPair(dval)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliceOdorTraces()
	
	WAVE w=data
	
	// baseline x-locations
	WAVE wXA=wCurX_A
	WAVE wXB=wCurX_B
	
	// Odor stim locations
	WAVE wOdorOnLoc
	
	String nameW
	
	Variable sLightDuration=ksLightDuration
	Variable sOdorAfterLight=ksOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarLightDuration
	if (V_flag)
		sLightDuration=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	if (V_flag)
		sOdorAfterLight=V_Value
	endif
	
	Variable x1,x2
	Variable p1,p2
	Variable i,j
	for(i=0;i<numpnts(wOdorOnLoc);i+=1)
		if (mod(i,2)==0)	// even
			nameW="w"+num2str(j)+"_before"
		else
			nameW="w"+num2str(j)+"_after"
			j+=1
		endif
		x1=wOdorOnLoc[i]-sOdorAfterLight
		x2=x1+sLightDuration
		p1=x2pnt(w,x1)
		p2=x2pnt(w,x1+sLightDuration)
		Duplicate/O/R=[p1,p2] w,$nameW
		
		// force-start on zero
		SetScale/P x 0,deltax(w),"", $nameW
	endfor
	
End


Function AutoLocateOdorStim()
	// Use user provided info to locate odor stim locations
	
	WAVE wOnLoc
	
	Variable n=numpnts(wOnLoc)
	Make/O/N=(n*2) wOdorOnLoc
	
	WAVE w=wOdorOnLoc
	
	Variable sOdorDuration=ksOdorDuration
	Variable sOdorBeforeLight=ksOdorBeforeLight
	Variable sOdorAfterLight=ksOdorAfterLight
	
	ControlInfo/W=GraphCFEvokedStep0 setvarOdorDuration
	if (V_flag)
		sOdorDuration=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarBeforeLight
	if (V_flag)
		sOdorBeforeLight=V_Value
	endif
	
	ControlInfo/W=GraphCFEvokedStep0 setvarAfterLight
	if (V_flag)
		sOdorAfterLight=V_Value
	endif
	
	Variable i,k
	for(i=0;i<n;i+=1)
		// "before" light
		w[k]=wOnLoc[i]+sOdorBeforeLight
		k+=1
		// "after" light
		w[k]=wOnLoc[i]+sOdorAfterLight
		k+=1
	endfor
	
	Duplicate/O w,wOdorOffLoc
	WAVE w2=wOdorOffLoc
	
	w2+=sOdorDuration
	
End


Function AutoDetectLightOnset2(w,thresh)
	
	WAVE w
	Variable thresh
	
	// baseline activity is usually smaller than 50 amplitude
	//Extract/INDX w, w2, w>thresh
	Extract/FREE/INDX w, w2, w>thresh
	
	//WAVE w2
	
	// there would be n steps in w2
	Make/O wOnLoc
	Make/O wOffLoc
	
	WAVE wOnLoc
	WAVE wOffLoc
	
	// initialize
	wOnLoc=-1
	wOffLoc=-1
	
	// converting from point numbers is more precise
	Variable sOff,sOn			
	
	// look for breaks
	Variable n=numpnts(w2)
	Variable i
	Variable k=0
	for(i=0;i<n;i+=1)
		if (i==0)
			sOn=pnt2x(w,w2[0])
			wOnLoc[0]=sOn
		elseif (i+1<n)	// if it's not the end
			if (w2[i]<w2[i+1]-1)
				sOff=pnt2x(w,w2[i])
				wOffLoc[k]=sOff
				k+=1
				// next one up is an ON
				sOn=pnt2x(w,w2[i+1])
				wOnLoc[k]=sOn
			endif
		endif
	endfor
	
	sOff=pnt2x(w,w2[n-1])
	wOffLoc[k]=sOff
	
	Extract/O wOnLoc,wOnLoc,wOnLoc>-1
	Extract/O wOffLoc,wOffLoc,wOffLoc>-1
	
	n=numpnts(wOnLoc)
	
//	// look for breaks
//	Extract w2, w3, p<=numpnts(w2)-1 && w2[p+1]>w2[p]+1
//	
//	// convert w3 from pnt to x
//	Duplicate w3, w4
//	
//	WAVE w4
//	
//	w4=pnt2x(w,w3[p])
//	
//	// look for breaks
//	Extract w2, w5, p>=0 && w2[p-1]<w2[p]-1
//	
//	WAVE w5
//	
//	Duplicate w5, w6
//	
//	WAVE w6
//	
//	w6=pnt2x(w,w5[p])
//	
//	Make/N=(numpnts(w4)) wStim
//	
//	AppendToGraph wStim vs w4
//	AppendToGraph wStim vs w6
	
	return n
	
End


Function AutoDetectLightOnset(w)
	// The whole baseline shifts vertically in the positive direction when light is on.
	// Detect onset by finding where the shift occurs.
	// as of vers 0.25, this doesn't work: use AutoDetectLightOnset2() instead
	
	WAVE w
	
	Variable off=0
	Variable on=WaveMax(w)
	
	PulseStats/F=0.1/P/L=(off,on)/Q w
	
	Variable pntOn,sOn
	Variable pntOff,sOff
	
	Make/O wOnLoc	// detects up to 128 stimuli.  See Hiro if you need more than 128	
	Make/O wOffLoc
	
	WAVE wOnLoc
	WAVE wOffLoc
	
	// initialize
	wOnLoc=-1
	wOffLoc=-1
	
	Variable i
	do
		if (V_flag!=2)	// a pulse was found
			if (V_PulsePolarity==1)	// pulse is increasing at the onset
				pntOn=round(V_PulseLoc1)		// this is the location of the onset
				pntOff=round(V_PulseLoc2)		// this is the location of the offset
				
				// converting from point numbers is more precise
				sOn=pnt2x(w,pntOn)
				sOff=pnt2x(w,pntOff)
				
				// Save the values as wave.  Save in sec because traces may have different sampling freq (e.g., VCmode)
				wOnLoc[i]=sOn
				wOffLoc[i]=sOff
				
				i+=1
				
				// Find the next stimulus
				PulseStats/F=0.1/P/R=[pntOff]/L=(off,on)/Q w
			endif
		else
			// stimulus does not exist
			break
		endif
	while(i<128)
	
	Extract/O wOnLoc,wOnLoc,wOnLoc>-1
	Extract/O wOffLoc,wOffLoc,wOffLoc>-1
	
	Variable n=numpnts(wOnLoc)
	Print n,"stimli detected!"
	
	// Visually confirm the result
	Make/O/N=(n) wStimOn
	WAVE wStimOn
	
	AppendToGraph wStimOn vs wOnLoc
	ModifyGraph mode(wStimOn)=3,marker(wStimOn)=10
	ModifyGraph rgb(wStimOn)=(0,0,0)
	ModifyGraph offset(wStimOn)={0,-20}
	
	AppendToGraph wStimOn vs wOffLoc
	ModifyGraph mode(wStimOn#1)=3,marker(wStimOn#1)=10
	ModifyGraph rgb(wStimOn#1)=(0,0,0)
	ModifyGraph offset(wStimOn#1)={0,-20}
	
End


Function AnalyzeOdorBaseline(w)
	// Create an interface where the user will pick baseline in a blinded fashion
	// Show 30 s with odor stimulus bar shown--hide y-axis so the user cannot guess if the light is on or off
	
	WAVE w		// original trace
	String nameW=NameOfWave(w)
	
	WAVE wOdorOnLoc
	
	Variable n=numpnts(wOdorOnLoc)
	
	// Create a wave with randomized order
	StatsSample/N=(n) wOdorOnLoc
	WAVE W_Sampled
	
	Variable i
	
	// Side bar
	ControlBar/T 25
	TitleBox titleInstruction title="Pick the baseline and click Next",frame=0
	//Button buttonNext,pos={0,100},size={90,20},title="Next"
	Button buttonNext title="Next",pos={150,2},proc=ButtonProcNextOdorTrace,userdata=num2str(i),userdata(nameW)+=nameW
	
	Duplicate/O W_Sampled, wCurX_A, wCurX_B
	WAVE wA=wCurX_A
	WAVE wB=wCurX_B
	wA+=20	// 20 s from the onset
	wB+=25
	
	// Make a wave that stores the standard deviation of the baseline
	Make/N=(numpnts(wA)) BaseSD
	Duplicate/O BaseSD,BaseAvg,BaseAvgNorm
	
	// Lock the axis range
	//GetAxis/W=GraphOdor/Q left
	//SetAxis left -20,V_max
	
	Variable sd=sqrt(Variance(w,0,wOdorOnLoc[0]))
	Variable avg=mean(w,0,wOdorOnLoc[0])
	
	
	Variable ymin=avg-7*sd
	Variable ymax=avg+15*sd
	if (ymin>-25)
		ymin = -25		// this will keep the stimulus marker shown
	endif
	SetAxis left ymin,ymax
	
	// Show the first randomly selected region
	ShowSelectedOdorResponse(i,nameW)
	
	PauseForUser GraphOdor	// this ends when the window is killed
	
End


Function ShowSelectedOdorResponse(i,nameW)
	
	Variable i
	
	String nameW
	
	WAVE w=W_Sampled
	WAVE wA=wCurX_A
	WAVE wB=wCurX_B
	WAVE BaseSD
	WAVE BaseAvg
	WAVE BaseAvgNorm
	
	WAVE wData=data
	
	Variable duration=ksLightDuration-ksOdorAfterLight-1	// extra 1 s is subtracted to ensure light off response doesn't show
	Variable x1,x2
	
	Variable baseline
	
	if (i<numpnts(w))
		x1=w[i]
		x2=x1+duration
		
		// Offset y-values so to prevent user from guessing
		baseline=mean(wData,x1,x2)
		//print i,nameW,baseline
		ModifyGraph offset($nameW)={0,-baseline}
		
		SetAxis bottom x1,x2
		// Cursors A and B for selecting baseline
		Cursor/A=1 A $nameW wA[i]
		Cursor/A=1 B $nameW wB[i]
		DoUpdate
	else
		// Sort W_Sampled and cursor positions in chronological order
		Sort w,w,wA,wB,BaseSD,BaseAvg,BaseAvgNorm
		KillWindow GraphOdor
	endif
	
End


Function ButtonProcNextOdorTrace(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			Variable i=str2num(GetUserData("","buttonNext",""))
			String nameW=GetUserData("","buttonNext","nameW")
			
			// Store cursor positions
			WAVE wA=wCurX_A
			WAVE wB=wCurX_B
			
			Variable xA=xcsr(A)
			Variable xB=xcsr(B)
			
			if (xcsr(A)<=xcsr(B))
				xA=xcsr(A)
				xB=xcsr(B)
			else
				xA=xcsr(B)
				xB=xcsr(A)
			endif
			
			wA[i]=xA
			wB[i]=xB
			
			WAVE w=data
			WAVE BaseSD
			BaseSD[i]=sqrt(Variance(w,xA,xB))
			
			WAVE BaseAvg
			BaseAvg[i]=mean(w,xA,xB)
			
			WAVE BaseAvgNorm
			Duplicate/FREE w,wFree
			wFree/=BaseSD[i]
			BaseAvgNorm[i]=mean(wFree,xA,xB)
			
			i+=1
			Button buttonNext userdata=num2str(i)
			ShowSelectedOdorResponse(i,nameW)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



// Georg's experiment
// 1. load all ROIs
// 2. name each location (optional)
// 3. pick one ROI as the stimulus
// 4. detect peaks in the stimulus ROI
// 5. measure normalized amplitude, half-width, etc.

// --- for Georg
Function hiroGPOpenTextFile()
	
	OpenImagingData()
	
	// steps
	Variable/G step
	step=1
	
	// Remove some controls that won't be used
	CheckBox checkInclude disable=1
	Button buttonToStep2 disable=1
	
	// Add a checkbox to select an ROI as the stimulus (checked by default)
	CheckBox checkGPSetStim title="Stimulus",pos={1,370},proc=CheckProcGPSetStim,value=0
	CheckBox checkGPSetStim help={"Check to select this ROI as the stimulus"}
	
	// Add a button to go to Step 2
	Button buttonGPToStep2 title="Step 2: Analyze stimulus >>",pos={1000,50},size={200,20}
	Button buttonGPToStep2 proc=ButtonProcGPToStep2,fColor=(0,0,65535)
	Button buttonGPToStep2 valueColor=(65535,65535,65535)
	Button buttonGPToStep2 help={"Click to start semi-auto peak detection"}
	
End


Function CheckProcGPSetStim(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			// Store this in master wave
			//WAVE selROI
			
			//Variable i=str2num(GetUserData("","setvarROI",""))
			ControlInfo setvarROI
			//Variable i=V_Value-1	// convert from 1-based to zero-based
			
			//selROI[i]=checked
			
			SetVariable setvarROI userData=num2str(V_Value-1)	// saves the index of the stimulus ROI as a string
			
			// Update trace color
			//UpdateTraceColor(checked)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcGPToStep2(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			// Check to make sure stimulus has been selected
			Variable i=str2num(GetUserData("","setvarROI",""))
			if (i>=0)
				hiroGPStep2()
			else
				// i is -1 if it is not selected
				DoAlert/T="Stimulus not yet selected" 0,"Please select the stimulus."
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


// --- GP Step 2
Function hiroGPStep2()
	// Detect stimulus onset and peak locations
	
	NVAR step
	step=2
	
	DoWindow/F GraphStep1
	
	// disable control
	Button buttonGPToStep2 disable=2
	
	Variable pA,pB
	
	pA=pcsr(A)
	pB=pcsr(B)
	
	// Which ROI is the stimulus?
	Variable stimROI=str2num(GetUserData("","setvarROI",""))	// zero-based
	
	// Hide the first window
	DoWindow/HIDE=1 GraphStep1
	
	// Make a new window
	DoWindow GraphStep2
	if (V_flag)
		KillWindow GraphStep2
	endif
	Display/N=GraphStep2 as "Step 2: Analyze stimulus"
	
	NVAR nRegions
	
	// Create a "selected" version of the M_smooth
	WAVE M_smooth
	Duplicate/O/R=[pA,pB][*] M_smooth,M_smoothSel
	
	WAVE M_smoothSel
	Duplicate/O/R=[*][stimROI] M_smoothSel,wSmoothSelStim		// this is the stimulus
	
	WAVE w=wSmoothSelStim
	Variable nRows=numpnts(w)
	Redimension/N=(nRows) w
	
	AppendToGraph w
	
	Variable/G nStim=floor(rightx(w)/kDefaultSecStimPeriod)-1
	
	Make/N=(nStim) wStimOnLoc,wStimPeakLoc,wStimBaseline,wStimPeak
	
	ModifyGraph margin(left)=75
	ModifyGraph noLabel(left)=2,axThick(left)=0
	
	// Add a vertical scale bar (2.5 units)
	String yUnits=WaveUnits(w,-1)
	SetDrawEnv xcoord= prel,ycoord= left
	DrawLine kScaleBarVertical,0,kScaleBarVertical,2.5
	SetDrawEnv xcoord= prel,ycoord= left,textrot= 90
	DrawText kScaleBarLabel,0,num2str(2.5)+" "+yUnits
	
	ResizeWindow(1280,400)
	
	WAVE M_smoothSel
	Variable maxPeak=WaveMax(M_smoothSel)
	
	SetAxis left *,maxPeak
	
	SetVariable setvarStim title="Stim",pos={1,350},size={60,20},proc=SetVarProcGPStim
	SetVariable setvarStim limits={1,nStim,1},live=1,value=_NUM:1,userdata=num2str(1)
	
	// show the first one, thereafter every 30 s
	Variable x1,x2
	x1=kDefaultSecStimPeriod-5
	x2=x1+kDefaultSecStimPeriod
	SetAxis/W=GraphStep2 bottom x1,x2		//30,60
	
	// find the 1st peak
	hiroGPDetectPeak(1)
	
	// Add a button to go to Step 3
	Button buttonToStep3 title="Step 3: Measure responses >>",pos={1000,50},size={200,20}
	Button buttonToStep3 proc=ButtonProcGPToStep3,fColor=(0,0,65535)
	Button buttonToStep3 valueColor=(65535,65535,65535)
	Button buttonToStep3 help={"Click to measure responses"}
	
	XAxisScrolling2(x1,x2)
	
End


Function hiroGPDetectPeak(j)
	// Find peak and onset
	Variable j	// 1st, 2nd, 3rd, etc.
	
	WAVE w=wSmoothSelStim
	
	Variable x1=j*kDefaultSecStimPeriod-5
	Variable x2=x1+kDefaultSecStimPeriod
	
	// Estimate baseline (30-31 s)
	Variable baseline=mean(w,x1,x1+1)
	
	WAVE wStimBaseline
	wStimBaseline[j-1]=baseline
	
	// Find peak and onset
	WaveStats/R=(x1,x2)/Q w
	
	Variable xPeak=V_maxloc
	Variable sd=V_sdev
	Variable thresh=baseline+0.4*sd
	
	FindPeak/R=(xPeak,x1)/N/M=(thresh)/Q w
	
	Variable xOnset=V_PeakLoc
	
	// place cursors at the onset and the peak
	Cursor/A=1 A wSmoothSelStim xOnset
	Cursor/A=1 B wSmoothSelStim xPeak
	
End


Function hiroGPSavePeak(j)
	
	Variable j
	
	Variable i=j-1	// zero-based
	
	WAVE wStimOnLoc
	WAVE wStimPeakLoc
	WAVE wStimBaseline
	WAVE wStimPeak
	
	wStimOnLoc[i]=pcsr(A)
	wStimPeakLoc[i]=pcsr(B)
	wStimPeak[i]=vcsr(B)-wStimBaseline[i]
	
End


Function SetVarProcGPStim(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Previous stim #
			Variable prevStim=str2num(GetUserData("","setvarStim",""))
			//Print "before:",prevStim,"now:",dval
			
			if (prevStim==dval)
				return 0
			endif
			
			// save cursor values (for previous stimulus)
			hiroGPSavePeak(prevStim)
			
			// read cursor values for the selected stimulus
			WAVE wSmoothSelStim
			WAVE wStimOnLoc
			WAVE wStimPeakLoc
			
			Variable i=dval-1	// zero-based
			
			if (!wStimOnLoc[i])
				// find peak and onset
				hiroGPDetectPeak(dval)
			else
				Cursor/A=1/P A wSmoothSelStim wStimOnLoc[i]
				Cursor/A=1/P B wSmoothSelStim wStimPeakLoc[i]
			endif
			
			// Move to the next/previous stimulus
			Variable x1,x2
			x1=kDefaultSecStimPeriod*dval-5
			x2=x1+kDefaultSecStimPeriod
			
			SetAxis/W=GraphStep2 bottom x1,x2
			
			XAxisScrolling2(x1,x2)
			
			// save current stim # to userdata
			sva.userdata=num2str(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcGPToStep3(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			// Last stim #
			Variable lastStim=str2num(GetUserData("","setvarStim",""))
			
			// save cursor values (for the last stimulus)
			hiroGPSavePeak(lastStim)
			
			// Check if every stimuli has been covered
			WAVE wStimPeakLoc
			Extract/FREE/INDX wStimPeakLoc,wINDX,wStimPeakLoc==0
			
			// Fill the rest automatically
			Variable k
			for(k=0;k<numpnts(wINDX);k+=1)
				//Print "Stimulus",wINDX[k]+1,"detected automatically"
				// input must be converted to 1-based
				hiroGPDetectPeak(wINDX[k]+1)
				hiroGPSavePeak(wINDX[k]+1)
			endfor
			
			// move to step 3
			hiroGPStep3()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroGPStep3()
	
	NVAR step
	step=3
	
	DoWindow/F GraphStep2
	
	// disable control
	Button buttonToStep3 disable=2
	
	// Hide the previous window
	DoWindow/HIDE=1 GraphStep2
	
	// Make a new window
	DoWindow GraphStep3
	if (V_flag)
		KillWindow GraphStep3
	endif
	Display/N=GraphStep3 as "Step 3: Measure responses"
	
	NVAR nRegions
	NVAR nStim
	
	Make/N=(nStim,nRegions) M_Baseline,M_PeakLoc,M_HalfFootLoc,M_HalfTailLoc	//M_Amp,M_NormAmp,M_HalfLatency,M_HalfRiseTime,M_HalfDuration
	
	WAVE M_smoothSel
	Duplicate/O/R=[*][0] M_smoothSel,wSmoothSel	// 1st response
	
	WAVE w=wSmoothSel
	WAVE wStim=wSmoothSelStim
	Variable nRows=numpnts(w)
	Redimension/N=(nRows) w
	
	AppendToGraph/W=GraphStep3 w,wStim
	
	NVAR offset
	ModifyGraph/W=GraphStep3 offset(wSmoothSelStim)={0,offset}
	ModifyGraph/W=GraphStep3 rgb(wSmoothSelStim)=(34952,34952,34952)
	
	ModifyGraph/W=GraphStep3 margin(left)=75
	ModifyGraph/W=GraphStep3 noLabel(left)=2,axThick(left)=0
	
	ResizeWindow(1280,400)
	
	Variable maxPeak=WaveMax(M_smoothSel)
	SetAxis left *,maxPeak
	
	// Show the 1st response
	Variable x1,x2
	//x1=kDefaultSecStimPeriod-5
	Variable pPad=x2pnt(w,2)
	WAVE wStimOnLoc
	x1=pnt2x(w,wStimOnLoc[0]-pPad)
	
	x2=x1+kDefaultSecStimPeriod
	
	SetAxis/W=GraphStep3 bottom x1,x2
	
	// Estimate baseline
	//Duplicate/FREE/R=(x1,x2) wSmoothSel,wFree
	
	//Variable base=StatsMedian(wFree)
	
	// draw a line for the 1st stim onset
	//hiroGPDrawLines(0,0,base)
	
	// Add numerical incrementors to move from one ROI to another
	SetVariable setvarROI3 title="ROI",pos={1,325},size={60,20}
	SetVariable setvarROI3 proc=SetVarProcGPROI3,value=_NUM:1,limits={1,nRegions,1},live=1
	SetVariable setvarROI3 userData=num2str(1)	// saves the index of the first ROI as a string
	SetVariable setvarROI3 help={"Show trace in the particular ROI"}
	
	// Add numerical incrementors to move from one ROI to another
	SetVariable setvarStim2 title="Stim",pos={1,350},size={60,20}
	SetVariable setvarStim2 proc=SetVarProcGPStim2,value=_NUM:1,limits={1,nStim,1},live=1
	SetVariable setvarStim2 userData=num2str(1)	// saves the index of the first Stim as a string
	SetVariable setvarStim2 help={"Show response on the particular stimulus"}
	
	// Add a button to go to Step 4
	Button buttonToStep4 title="Step 4: Done >>",pos={1000,50},size={200,20}
	Button buttonToStep4 proc=ButtonProcGPToStep4,fColor=(0,0,65535)
	Button buttonToStep4 valueColor=(65535,65535,65535)
	Button buttonToStep4 help={"Click to finish"}
	
	hiroGPDetectPeakResp(1)
	
End


Function hiroGPDetectPeakResp(j)
	
	Variable j	// one-based Stim #
	Variable x1,x2
	
	x1=kDefaultSecStimPeriod*j-5
	x2=x1+kDefaultSecStimPeriod
	
	// Refine x1: it should be the stim onset
	WAVE wSmoothSel
	WAVE wStimOnLoc
	Variable i=j-1	// zero-based Stim #
	x1=pnt2x(wSmoothSel,wStimOnLoc[i])
	
	//Print "Stim:",x1,x2
	
	Variable peakLoc,halfFootLoc,halfTailLoc
	
	Variable xPeak,peak
	
	// Find peak
	WaveStats/R=(x1,x2)/M=1/Q wSmoothSel
	xPeak=V_maxloc
	peakLoc=x2pnt(wSmoothSel,xPeak)
	
	WAVE wStimBaseline
	peak=V_max-wStimBaseline[i]
	
	// Find half foot
	FindLevel/R=(x1,xPeak)/P/Q wSmoothSel,peak*kGPPercentPeak
	if (V_flag==0)
		halfFootLoc=floor(V_LevelX)
	else
		halfFootLoc=peakLoc-(peakLoc-wStimOnLoc[i])*(1-kGPPercentPeak)
	endif
	
	// Find half tail
	FindLevel/R=(xPeak,x2)/P/Q wSmoothSel,peak*kGPPercentPeak
	if (V_flag==0)
		halfTailLoc=floor(V_LevelX)
	else
		halfTailLoc=peakLoc+(peakLoc-wStimOnLoc[i])*(1-kGPPercentPeak)
	endif
	
	// Place three cursors
	Cursor/A=1/P/S=1 A wSmoothSel halfFootLoc
	Cursor/A=1/P/S=1 B wSmoothSel peakLoc
	Cursor/A=1/P/S=1 C wSmoothSel halfTailLoc
	
	// Prime the storage (will be resaved when ROI or stim moves)
	WAVE M_PeakLoc
	WAVE M_HalfFootLoc
	WAVE M_HalfTailLoc
	
	ControlInfo setvarROI3
	Variable iROI=V_Value-1
	M_PeakLoc[i][iROI]=peakLoc
	M_HalfFootLoc[i][iROI]=halfFootLoc
	M_HalfTailLoc[i][iROI]=halfTailLoc
	
	// Move x1 to be -10 s of the stim onset. x2 is the stim onset
	x2=x1
	x1-=10
	
	
	Duplicate/FREE/R=(x1,x2) wSmoothSel,wFree
	Variable base=StatsMedian(wFree)
	
	hiroGPDrawLines(i,iROI,base)
	
End


Function SetVarProcGPROI3(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Save the latest ABC locations for the previous ROI
			hiroGPUpdatePrevious()
			
			Variable iROI
			iROI=dval-1	// index is zero-based, unlike the ROI which is one-based
			
			WAVE M_smoothSel
			Duplicate/O/R=[*][iROI] M_smoothSel,wSmoothSel
			
			ControlInfo setvarStim2
			Variable jStim=V_Value
			Variable iStim=jStim-1
			
			// detect peaks
			WAVE M_PeakLoc
			WAVE M_HalfFootLoc
			WAVE M_HalfTailLoc
			if (!M_PeakLoc[iStim][iROI])
				hiroGPDetectPeakResp(jStim)
			else
				// Read in stored values
				// Place three cursors
				Cursor/A=1/P/S=1 A wSmoothSel M_HalfFootLoc[iStim][iROI]
				Cursor/A=1/P/S=1 B wSmoothSel M_PeakLoc[iStim][iROI]
				Cursor/A=1/P/S=1 C wSmoothSel M_HalfTailLoc[iStim][iROI]
				
				// show baseline
				WAVE M_Baseline
				Variable base=M_Baseline[iStim][iROI]
				hiroGPDrawLines(iStim,iROI,base)
			endif
			
			// save current ROI # to userdata
			sva.userdata=num2str(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcGPStim2(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			// Save the latest ABC locations for the previous ROI
			hiroGPUpdatePrevious()
			
			// Previous stim #
			Variable jPrevStim=str2num(GetUserData("","setvarStim2",""))
			//Print "before:",jPrevStim,"now:",dval
			
			if (jPrevStim==dval)
				return 0
			endif
			
			// save cursor values (for previous stimulus)
			//hiroGPSavePeak(prevStim)
			
			// read cursor values for the selected stimulus
			WAVE wSmoothSelStim
			WAVE wStimOnLoc
			WAVE wStimPeakLoc
			
			Variable iStim=dval-1	// zero-based
			
			// Move to the next/previous stimulus
			Variable x1,x2
			//x1=kDefaultSecStimPeriod*dval-5
			Variable pPad=x2pnt(wSmoothSelStim,2)
			x1=pnt2x(wSmoothSelStim,wStimOnLoc[iStim]-pPad)
			
			x2=x1+kDefaultSecStimPeriod
			
			SetAxis/W=GraphStep3 bottom x1,x2
			
			WAVE wSmoothSel
			Duplicate/FREE/R=(x1,x2) wSmoothSel,wFREE
			
			Variable base=StatsMedian(wFree)
			
			//hiroGPDetectPeakResp(dval)
			
			ControlInfo setvarROI3
			Variable jROI=V_Value
			Variable iROI=jROI-1
			
			//hiroGPDrawLines(iStim,iROI,base)
			
			// detect peaks
			WAVE M_PeakLoc
			WAVE M_HalfFootLoc
			WAVE M_HalfTailLoc
			if (!M_PeakLoc[iStim][iROI])
				hiroGPDetectPeakResp(dval)
			else
				// Read in stored values
				// Place three cursors
				Cursor/A=1/P/S=1 A wSmoothSel M_HalfFootLoc[iStim][iROI]
				Cursor/A=1/P/S=1 B wSmoothSel M_PeakLoc[iStim][iROI]
				Cursor/A=1/P/S=1 C wSmoothSel M_HalfTailLoc[iStim][iROI]
				
				// show baseline?
				WAVE M_Baseline
				base=M_Baseline[iStim][iROI]
				hiroGPDrawLines(iStim,iROI,base)
			endif
			
			// save current stim # to userdata
			sva.userdata=num2str(dval)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroGPUpdatePrevious()
	// Update previous ROI's ABC locations
	
	// Previous ROI #
	Variable jPrevROI=str2num(GetUserData("","setvarROI3",""))
	//Print "before:",jPrevROI,"now:",dval
	
	// Previous stim #
	Variable jPrevStim=str2num(GetUserData("","setvarStim2",""))
	
	//Print "Previous Stim, ROI",jPrevStim,jPrevROI
	
	// Save the latest ABC locations for the previous ROI
	WAVE wSmoothSel
	WAVE M_PeakLoc
	WAVE M_HalfFootLoc
	WAVE M_HalfTailLoc
	
	Variable iPrevROI=jPrevROI-1
	Variable iPrevStim=jPrevStim-1
	
	M_HalfFootLoc[iPrevStim][iPrevROI]=pcsr(A)
	M_PeakLoc[iPrevStim][iPrevROI]=pcsr(B)
	M_HalfTailLoc[iPrevStim][iPrevROI]=pcsr(C)
	
End


//Function CursorMovedHook(info)
//	// Not specific to the graph--this executes whenever cursor moves on any graph (not good)
//	
//	String info
//	
//	//Print info
//	String nameGraph=StringByKey("GRAPH",info)
//	
//	
//	
//End


Function hiroGPDrawLines(i,k,base)
	
	Variable i	// zero-based stim #
	Variable k	// zero-based roi #
	Variable base	// estimated baseline
	
	DrawAction delete
	
	WAVE wSmoothSelStim
	WAVE wStimOnLoc
	Variable xStimOn=pnt2x(wSmoothSelStim,wStimOnLoc[i])
	
	SetDrawEnv xcoord= bottom,linefgc= (34952,34952,34952),dash= 2
	DrawLine xStimOn,0.95,xStimOn,0
	
	//Cursor/A=1/P A wSmoothSelStim wStimOnLoc[i]
	//Cursor/A=1/P B wSmoothSelStim wStimPeakLoc[i]
	
	// Add a vertical scale bar (5 units)
	String yUnits=WaveUnits(wSmoothSelStim,-1)
	SetDrawEnv xcoord= prel,ycoord= left
	DrawLine kScaleBarVertical,-5,kScaleBarVertical,0
	SetDrawEnv xcoord= prel,ycoord= left,textrot= 90
	DrawText kScaleBarLabel,-5,num2str(5)+" "+yUnits
	
	// Horizontal line indicating baseline
//	WAVE wStimBaseline
//	SetDrawEnv ycoord= left,linefgc= (34952,34952,34952),dash= 2
//	DrawLine 0,wStimBaseline[i],1,wStimBaseline[i]
	
	// save baseline if it hasn't already
	WAVE M_Baseline
	if (!M_Baseline[i][k])
		M_Baseline[i][k]=base
	endif
	
	SetDrawEnv ycoord= left,linefgc= (34952,34952,34952),dash= 2
	DrawLine 0,base,1,base
	
End


Function ButtonProcGPToStep4(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hiroGPUpdatePrevious()
			
			// Check if every stimuli has been covered
			WAVE M_PeakLoc
			Extract/FREE/INDX M_PeakLoc,wINDX,M_PeakLoc==0	//? can this work on matrix?
			
			// Fill the rest automatically
			WAVE M_smoothSel
			Variable iStim,iROI
			NVAR nStim
			Variable k
			for(k=0;k<numpnts(wINDX);k+=1)
				// get iROI and iStim from wINDX (a vector)
				iROI=floor(wINDX[k]/nStim)	// column
				iStim=wINDX[k]-nStim*iROI	// row
				//Print iROI,iStim
				
				Duplicate/O/R=[*][iROI] M_smoothSel,wSmoothSel
				//Print "Stimulus",wINDX[k]+1,"detected automatically"
				
				// Set setvar for both ROI and Stim
				SetVariable setvarROI3 value=_NUM:iROI+1
				SetVariable setvarStim2 value=_NUM:iStim+1
				
				// input must be converted to 1-based
				hiroGPDetectPeakResp(iStim+1)
			endfor
			
			// move to step 4
			hiroGPStep4()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroGPStep4()
	// Do the measurements
	
	NVAR step
	step=4
	
	DoWindow/F GraphStep3
	
	// disable control
	Button buttonToStep3 disable=2
	
	// Hide the previous window
	DoWindow/HIDE=1 GraphStep3
	
	// Make a new window
//	DoWindow GraphStep4
//	if (V_flag)
//		KillWindow GraphStep4
//	endif
//	Display/N=GraphStep4 as "Step 4: Browse the results"
	
	NVAR nStim
	NVAR nRegions
	
	Make/N=(nStim,nRegions) M_Peaks,M_NormPeaks,M_Latencies,M_RiseTimes,M_Durations,M_Areas,M_HalfFoot70Loc,M_R2
	
	WAVE M_smoothSel
	
	WAVE M_HalfFootLoc
	WAVE M_PeakLoc
	WAVE M_HalfTailLoc
	
	WAVE M_Baseline
	WAVE M_Peaks
	WAVE M_NormPeaks
	WAVE M_Latencies
	WAVE M_RiseTimes
	WAVE M_Durations
	WAVE M_Areas
	WAVE M_HalfFoot70Loc
	WAVE M_R2
	
	WAVE wStimBaseline
	WAVE wStimPeak
	WAVE wStimOnLoc
	
	String strLabel
	
	Variable pPeak,pHalfFoot,pHalfTail
	Variable xPeak,xHalfFoot,xHalfTail
	Variable peak
	Variable pSeventy
	Variable minimum
	Variable V_FitError	// used by CurveFit
	Variable area1,area0
	Variable i,k
	for(i=0;i<nStim;i+=1)
		strLabel="Stim"+num2str(i+1)
		SetDimLabel 0,i,$strLabel,M_Peaks,M_NormPeaks,M_Latencies,M_RiseTimes,M_Durations,M_Areas
		for(k=0;k<nRegions;k+=1)
			
			if (i==0)
				strLabel="ROI"+num2str(k+1)
				SetDimLabel 1,k,$strLabel,M_Peaks,M_NormPeaks,M_Latencies,M_RiseTimes,M_Durations,M_Areas
			endif
			
			Duplicate/FREE/R=[*][k] M_smoothSel,wSmoothSel
			
			pPeak=M_PeakLoc[i][k]
			xPeak=pnt2x(wSmoothSel,pPeak)
			//Print i,k,pPeak
			
			// Peak of the response
			//M_Peaks[i][k]=wSmoothSel[pPeak]-wStimBaseline[i]
			peak=wSmoothSel[pPeak]-M_Baseline[i][k]
			M_Peaks[i][k]=peak
			
			// Normalized peak (normalize to the stimulus amplitude)
			M_NormPeaks[i][k]=M_Peaks[i][k]/wStimPeak[i]
			
			// Latency to 30% peak
			pHalfFoot=M_HalfFootLoc[i][k]
			xHalfFoot=pnt2x(wSmoothSel,pHalfFoot)
			M_Latencies[i][k]=xHalfFoot-pnt2x(wSmoothSel,wStimOnLoc[i])
			
			// Rise time at 50% peak
			//M_RiseTimes[i][k]=(wSmoothSel[pHalfFoot]-wStimBaseline[i])/M_Latencies[i][k]
			
			// Rise time between 30-70%
			// Find the 70% peak
			FindLevel/R=(xHalfFoot,xPeak)/P/Q wSmoothSel,peak*0.7
			if (V_flag==0)
				pSeventy=floor(V_LevelX)
			else
				pSeventy=pPeak-(pPeak-wStimOnLoc[i])*(1-0.7)
			endif
			
			M_HalfFoot70Loc[i][k]=pSeventy
			
			// curve fit to get best line between 30-70%
			V_FitError=0
			KillWaves/Z W_coef,W_fitConstants,W_sigma
			CurveFit/N/M=2/W=2/Q line, wSmoothSel[pHalfFoot,pSeventy]/D
			WAVE W_coef
			
			M_RiseTimes[i][k]=W_coef[1]		// save the slope of the line
			M_R2[i][k]=V_r2
			
			// Duration at 30% peak
			pHalfTail=M_HalfTailLoc[i][k]
			xHalfTail=pnt2x(wSmoothSel,pHalfTail)
			M_Durations[i][k]=xHalfTail-xHalfFoot
			
			// Area above 30% peak (do this last)
			//-- shift the wave above zero to prevent area cancelation
			minimum=WaveMin(wSmoothSel)
			wSmoothSel-=minimum	// shift up
			
			// area under the curve (base inclusive)
			area1=area(wSmoothSel,xHalfFoot,xHalfTail)
			
			// area under the 30% (a rectangle)
			area0=wSmoothSel[pHalfFoot]*M_Durations[i][k]
			
			// Area above 30% peak
			M_Areas[i][k]=area1-area0
			
		endfor
	endfor
	
	Edit M_NormPeaks.ld as "Normalized amplitude"
	AutoPositionWindow/E
	Edit M_Latencies.ld as "Latency to 30% peak (s)"
	AutoPositionWindow/E
	Edit M_RiseTimes.ld as "Rise time betw 30-70% peak (dFF/s)"
	AutoPositionWindow/E
	Edit M_Durations.ld as "Duration at 30% peak (s)"
	AutoPositionWindow/E
	Edit M_Areas.ld as "Area above 30% peak (dFF*s)"
	AutoPositionWindow/E
	
End


// Ting's experiment
// 1. load all ROIs
// 2. test if stimulus artifact can be subtracted

// --- for Ting
Function hiroTFOpenTextFile()
	
	OpenImagingData()
	
	// steps
	Variable/G step
	step=1
	
	// Just hide the step 1 graph for now
	DoWindow/HIDE=1 GraphStep1
	
	NVAR nRegions
	if (nRegions<2)
		Abort "You need at least two traces to do subtraction.\r\rTry a different file."
	endif
	
	// Make a new sandbox window
	Display/N=GraphTFSandboxStep0 as "Sandbox: can stimulus artifact be subtracted?"
	
	WAVE M0
	
	// extract original and to-be-subtracted waves
	Duplicate/O/R=[*][0] M0,waveOrig,waveSub
	
	// extract background wave
	Duplicate/O/R=[*][1] M0,waveBG
	
	AppendToGraph/W=GraphTFSandboxStep0 waveOrig,waveSub,waveBG
	
	Variable offset=(abs(WaveMin(waveOrig))+WaveMax(waveBG))*1.2
	
	ModifyGraph/W=GraphTFSandboxStep0 offset(waveOrig)={0,-offset},offset(waveBG)={0,-2*offset}
	
	ModifyGraph/W=GraphTFSandboxStep0 rgb(waveOrig)=(0,0,65535)	// blue
	ModifyGraph/W=GraphTFSandboxStep0 rgb(waveBG)=(0,0,65535)
	
	// Label
	Make/N=3 :Controls:wPTFStep0
	Make/T/N=3 :Controls:wTTFStep0
	
	WAVE wP=:Controls:wPTFStep0
	WAVE/T wT=:Controls:wTTFStep0
	wP=-offset*x
	wT[0]="A-B"
	
	ModifyGraph/W=GraphTFSandboxStep0 userticks(left)={wP,wT}
	
	ResizeWindow(800,350)
	//XAxisScrolling2(0,10)
	
	// init with 1st and 2nd waves
	Variable roiA,roiB	// zero-based
	roiA=0
	roiB=1
	
	// add controls
	ModifyGraph/W=GraphTFSandboxStep0 margin(left)=85
	
	SetVariable setvarTFStep0Orig title="ROI A",proc=SetVarProcTFStep0Orig
	SetVariable setvarTFStep0Orig limits={1,nRegions,1},live=1
	SetVariable setvarTFStep0Orig size={70,15},pos={1,300},value=_NUM:roiA+1
	
	SetVariable setvarTFStep0BG title="ROI B",proc=SetVarProcTFStep0BG
	SetVariable setvarTFStep0BG limits={1,nRegions,1},live=1
	SetVariable setvarTFStep0BG size={70,15},pos={1,320},value=_NUM:roiB+1
	
	// show ROIs as contour
	NVAR imageWidthMicron=:map:imageWidthMicron
	hiroShowROIsAsContours(imageWidthMicron)
	AutoPositionWindow/E
	
	hiroTFStep0(roiA,roiB)
	
End


Function hiroTFStep0(roiA,roiB)
	
	Variable roiA,roiB	// zero-based ROIs
	
	WAVE M0
	
	// extract original and to-be-subtracted waves
	Duplicate/O/R=[*][roiA] M0,waveOrig,waveSub
	
	// extract background wave
	Duplicate/O/R=[*][roiB] M0,waveBG
	
	WAVE waveOrig
	WAVE waveSub
	WAVE waveBG
	
	waveSub-=waveBG
	
	// Recalculate offset
	Variable offset=(abs(WaveMin(waveOrig))+WaveMax(waveBG))*1.2
	ModifyGraph/W=GraphTFSandboxStep0 offset(waveOrig)={0,-offset},offset(waveBG)={0,-2*offset}
	
	WAVE wP=:Controls:wPTFStep0
	wP=-offset*x
	
	// Update label
	WAVE/T wT=:Controls:wTTFStep0
	wT[0]=num2str(roiA+1)+"-"+num2str(roiB+1)
	wT[1]=num2str(roiA+1)
	wT[2]=num2str(roiB+1)
	
	// Colorize
	String nameTraceA="ROI_"+num2str(roiA+1)+"=xymarkers"
	String nameTraceB="ROI_"+num2str(roiB+1)+"=xymarkers"
	
	ModifyGraph/W=GraphROIScaled rgb=(34952,34952,34952)
	ModifyGraph/W=GraphROIScaled rgb($nameTraceA)=(0,0,65535)	// blue
	ModifyGraph/W=GraphROIScaled rgb($nameTraceB)=(0,0,65535)
	
End


Function SetVarProcTFStep0Orig(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo setvarTFStep0BG
			Variable roiB=V_Value-1
			
			hiroTFStep0(dval-1,roiB)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcTFStep0BG(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			ControlInfo setvarTFStep0Orig
			Variable roiA=V_Value-1
			
			hiroTFStep0(roiA,dval-1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function patchExportPeakLoc(mode)
	
	// Hendrik needs to export the ROI and the PeakLoc (point) as a text file.
	// Although the PeakLocX (s) is corrected already,
	// if the user changes the range the starting point may shift.  Correct and then export.
	
	Variable mode	// 0 for 0-based, 1 for 1-based (e.g., MATLAB)
	
	if (!DataFolderExists(":Features"))
		Abort "This function cannot be used.\rPlease use this function in Step 3 or later of the main app."
	endif
	
	DoWindow/F GraphStep1
	  
	Variable pStart=pcsr(A)
	
	Print "This is an utility function created for Hendrik."
	Print "The first column is ROI.  The second column is PeakLoc."
	
	if (pStart)
		Print "The program detected a point-shift of",pStart,"in the original PeakLoc.  This has been corrected in the exported file and the new (but not the old) table."
	endif
	
	if (mode)
		// Correct for MATLAB (1-based)
		pStart+=1
		
		Print "The point number for the peak location has been converted to 1-based (for MATLAB)."
	endif
	
	DoWindow/HIDE=1 GraphStep1
	
	DFREF dfr=:Features
	
	WAVE M=dfr:M_features
	
	Variable nRows=DimSize(M,0)
	
	Make/O/N=(nRows,2) M_NewFeatures
	WAVE M1=M_NewFeatures
	
	Duplicate/FREE/R=[][0] M,wROIs
	Duplicate/FREE/R=[][3] M,wPeakLocCorrect
	
	wPeakLocCorrect+=pStart
	
	M1[][0]=wROIs
	M1[][1]=wPeakLocCorrect[p]
	
	SetDimLabel 1,0,ROI,M1
	SetDimLabel 1,1,PeakLocFix,M1
	
	SVAR fileName
	Save/G/I/J M1 as fileName
	
	Edit/K=1 M1.ld
	
End


Function patchExportPeakLocExtended(mode)
	
	// Based on the utility function written for Hendrik,
	// Miriam needs to export Foor and Tail location in addition to the ROI and the PeakLoc (point) as a text file.
	// Although the PeakLocX (s) is corrected already,
	// if the user changes the range the starting point may shift.  Correct and then export.
	
	Variable mode	// 0 for 0-based, 1 for 1-based (e.g., MATLAB)
	
	if (!DataFolderExists(":Features"))
		Abort "This function cannot be used.\rPlease use this function in Step 3 or later of the main app."
	endif
	
	DoWindow/F GraphStep1
	  
	Variable pStart=pcsr(A)
	
	Print "This is an utility function created for Hendrik."
	Print "The first column is ROI.  The second column is PeakLoc."
	
	if (pStart)
		Print "The program detected a point-shift of",pStart,"in the original PeakLoc.  This has been corrected in the exported file and the new (but not the old) table."
	endif
	
	if (mode)
		// Correct for MATLAB (1-based)
		pStart+=1
		
		Print "The point number for the peak location has been converted to 1-based (for MATLAB)."
	endif
	
	DoWindow/HIDE=1 GraphStep1
	
	DFREF dfr=:Features
	
	WAVE M=dfr:M_features
	
	Variable nRows=DimSize(M,0)
	
	Make/O/N=(nRows,4) M_NewFeatures
	WAVE M1=M_NewFeatures
	
	Duplicate/FREE/R=[][0] M,wROIs
	Duplicate/FREE/R=[][2] M,wFootLocCorrect
	Duplicate/FREE/R=[][3] M,wPeakLocCorrect
	Duplicate/FREE/R=[][4] M,wTailLocCorrect
	
	wFootLocCorrect+=pStart
	wPeakLocCorrect+=pStart
	wTailLocCorrect+=pStart
	
	M1[][0]=wROIs
	M1[][1]=wFootLocCorrect[p]
	M1[][2]=wPeakLocCorrect[p]
	M1[][3]=wTailLocCorrect[p]
	
	SetDimLabel 1,0,ROI,M1
	SetDimLabel 1,1,FootLocFix,M1
	SetDimLabel 1,2,PeakLocFix,M1
	SetDimLabel 1,3,TailLocFix,M1
	
	SVAR fileName
	Save/G/I/J M1 as fileName
	
	Edit/K=1 M1.ld
	
End


// TF new Step 0
Function hiroTFevokedStep0()
	
	// Detect stimulus artifacts, align and superimpose traces
	
	OpenImagingData()
	
	DoWindow/HIDE=1 GraphStep1
	
	// Data will be saved in a simple matrix: ROI number and Response number
	NVAR nRegions
	Make/O/N=(nRegions,2) wData
	// init
	SetDimLabel 1,0,ROI,wData
	SetDimLabel 1,1,Count,wData
	wData[][0]=x+1
	wData[][1]=NaN
	
	// Keeps track of parameters on the control.  selROI already exists
	Make/O/N=(nRegions) selVirgin,selBefore,selSD,selRange1,selX1,selX2,selRange2
	Make/O/N=(nRegions) wStim
	
	// first ROI
	Variable iROI=0
	
	WAVE selVirgin
	selVirgin=1
	
	//DFREF dfr=hiroTFDetectAlignStim(iROI)	// dfr is the ref for DF containing fragments of the selected ROI
	hiroTFDetectStim()
	DFREF dfr=hiroTFAlignStim(iROI)
	
	Variable x1=ksTFBeforeTo
	Variable x2=ksTFAfterFrom
	
	Variable range1=ksTFBeforeFrom
	Variable range2=ksTFAfterTo
	
	// Save params on the control for each ROI
	WAVE selBefore
	selBefore=1
	WAVE selSD
	selSD=kDefaultSDMultiple
	WAVE selRange1
	selRange1=range1
	WAVE selX1
	selX1=x1
	WAVE selX2
	selX2=x2
	WAVE selRange2
	selRange2=range2
	
	WAVE w=dfr:w0
	
	// refine baseline: analyze pre-stim of the first instance (because it is uncontaminated by any stimuli)
	Duplicate/FREE/R=(range1,x1) w,wFree
	Redimension/N=-1 wFree
	Variable base=StatsMedian(wFree)
	//Print "Refined baseline",base
	
	Variable sd=sqrt(Variance(wFree))
	//Print "SD",sd
	
	// wZExclude to gray-out trace from about 0 s to 1 s
	Duplicate/O w,wZExclude
	
	hiroTFUpdateZExclude(range1,x1,x2,range2)
	
	DoWindow GraphStep0
	if (V_Flag)
		KillWindow GraphStep0
	endif
	Display/N=GraphStep0 as "Evoked Responses Superimposed"
	//ModifyGraph/W=GraphStep0 margin(top)=40
	
	String nameW
	
	Variable i
	for(i=0;i<CountObjectsDFR(dfr,1);i+=1)
		nameW="w"+num2str(i)
		
		WAVE w=dfr:$nameW
		
		AppendToGraph/W=GraphStep0 w
		ModifyGraph/W=GraphStep0 zColor($nameW)={wZExclude,*,*,RedWhiteBlue,0}
	endfor
	
	hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
	
	ModifyGraph/W=GraphStep0 standoff=0
	ResizeWindow(1280,400)
	ControlBar/L 110
	
	Variable thresh
	
	// init
	thresh=base+kDefaultSDMultiple*sd	// e.g., 3.5 sd above the median of the first pre-stim
	
	SetVariable setvarTFStep0Thresh title="SD",size={75,20},pos={1,140}
	SetVariable setvarTFStep0Thresh proc=SetVarProcTFStep0Thresh
	SetVariable setvarTFStep0Thresh value= _NUM:kDefaultSDMultiple,limits={0,kTFThreshHighLimit,0.5},live=1
	
	Slider sliderTFStep0Thresh proc=SliderProcTFStep0Thresh,pos={1,160}
	Slider sliderTFStep0Thresh size={53,100},value=kDefaultSDMultiple,limits={0,kTFThreshHighLimit,0.5}
	
	// Custom label for the slider
	Make/O/N=3 :Controls:sliderTFTicValue
	Make/T/O/N=3 :Controls:sliderTFTicLabel
	
	WAVE wP=:Controls:sliderTFTicValue
	WAVE/T wT=:Controls:sliderTFTicLabel
	
	wP=(kTFThreshHighLimit/2)*x
	wT[0]="Low"
	wT[2]="High"
	
	Slider sliderTFStep0Thresh userTicks={wP,wT}
	
	// Draw dotted line across threshold
	SetDrawEnv ycoord= left,dash= 2
	DrawLine 0,thresh,1,thresh
	
	// Set a range for pre-stim
	//TitleBox titleBefore title="Pre-stim (s)",frame=0,pos={1,280}
	CheckBox checkTFBeforeStim pos={1,280},size={62,15},title="Before (s)",side=1
	CheckBox checkTFBeforeStim proc=CheckProcTFBeforeStim,value=1
	
	SetVariable setvarBeforeFrom title="",size={50,20},pos={1,295}
	SetVariable setvarBeforeFrom proc=SetVarProcBeforeFrom
	SetVariable setvarBeforeFrom value= _NUM:ksTFBeforeFrom,limits={leftx(wZExclude),0,0.01},live=1
	
	TitleBox title0 title="Ð",frame=0,pos={50,295}
	
	SetVariable setvarBeforeTo title="",size={50,20},pos={58,295}
	SetVariable setvarBeforeTo proc=SetVarProcBeforeTo
	SetVariable setvarBeforeTo value= _NUM:ksTFBeforeTo,limits={-ksTFDefaultBefore,0,0.01},live=1
	
	// Set a range for post-stim
	TitleBox titleAfter title="After (s)",frame=0,pos={1,320}
	
	SetVariable setvarAfterFrom title="",size={50,20},pos={1,335}
	SetVariable setvarAfterFrom proc=SetVarProcAfterFrom
	SetVariable setvarAfterFrom value= _NUM:ksTFAfterFrom,limits={0,ksTFDefaultAfter,0.01},live=1
	
	TitleBox title1 title="Ð",frame=0,pos={50,335}
	
	SetVariable setvarAfterTo title="",size={50,20},pos={58,335}
	SetVariable setvarAfterTo proc=SetVarProcAfterTo
	SetVariable setvarAfterTo value= _NUM:ksTFAfterTo,limits={0,rightx(wZExclude),0.01},live=1
	
	// ROI selector
	SetVariable setvarTFROI title="ROI",size={60,20},pos={1,365},proc=SetVarProcTFROI
	SetVariable setvarTFROI value= _NUM:1,limits={1,nRegions,1},live=1
	
	CheckBox checkTFIncludeROI title="Include"
	CheckBox checkTFIncludeROI proc=CheckProcTFIncludeROI,value=1
	CheckBox checkTFIncludeROI pos={1,382}
	
	Button buttonTFShowCount title="Show Data",size={100,20},pos={1155,15}
	Button buttonTFShowCount proc=ButtonProcTFShowCount
	
	hiroTFCountSuprathresh(thresh,iROI)
	
	// Show overview
	WAVE M0
	Duplicate/O/R=[*][iROI] M0,wSel
	
	DoWindow GraphTFOverview
	if (V_Flag)
		KillWindow GraphTFOverview
	endif
	Display/N=GraphTFOverview wSel as "Overview"
	ResizeWindow(1280,200)
	AutoPositionWindow/E/M=1
	
	DoWindow/F GraphStep0
	
End


Function ButtonProcTFShowCount(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			WAVE wData
			WAVE wStim
			
			Edit/K=1 wData.ld,wStim.d
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliderProcTFStep0Thresh(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				SetVariable setvarTFStep0Thresh value=_NUM:curval
				
				ControlInfo/W=GraphStep0 setvarTFROI
				Variable iROI=V_Value-1
				hiroTFUpdateStep0Thresh(curval,iROI)
				
				// Save
				WAVE selSD
				selSD[iROI]=curval
				
				// Apply this to all not-yet-analyzed ROIs
				hiroTFinheritControlParams()
				
			endif
			break
	endswitch

	return 0
End


Function SetVarProcTFStep0Thresh(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Slider sliderTFStep0Thresh value=dval
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			hiroTFUpdateStep0Thresh(dval,iROI)
			
			// Save
			WAVE selSD
			selSD[iROI]=dval
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroTFUpdateStep0Thresh(v,iROI)
	
	Variable v
	Variable iROI	// 0-based
	
	String nameDF="ROI_Frags"+num2str(iROI+1)
	DFREF dfr=:$nameDF
	WAVE w=dfr:w0
	
	Variable x1,x2
	
	ControlInfo/W=GraphStep0 setvarBeforeFrom
	x1=V_Value
	
	ControlInfo/W=GraphStep0 setvarBeforeTo
	x2=V_Value
	
	Duplicate/FREE/R=(x1,x2) w,wFree
	Redimension/N=-1 wFree
	Variable base=StatsMedian(wFree)
	//Print "Refined baseline",base
	//Print "avg",mean(wFree)
	
	Variable sd=sqrt(Variance(wFree))
	
	Variable thresh=base+v*sd
	
	DrawAction/W=GraphStep0 delete
	SetDrawEnv ycoord= left,dash= 2
	DrawLine 0,thresh,1,thresh
	
	hiroTFCountSuprathresh(thresh,iROI)
	
End


Function hiroTFUpdateZExclude(range1,x1,x2,range2)
	
	Variable range1
	Variable x1
	Variable x2
	Variable range2
	
	WAVE wZExclude
	
	// init
	wZExclude=1
	
	Variable p1=x2pnt(wZExclude,x1)
	Variable p2=x2pnt(wZExclude,x2)
	
	wZExclude[p1,p2]=0
	
	ControlInfo/W=GraphStep0 checkTFBeforeStim	// this control doesn't exist initially
	if (V_Flag)
		if (!V_Value)
			range1=x1	// override if pre-stim doesn't matter
		endif
	endif
	
	Variable p3=x2pnt(wZExclude,range1)
	Variable p4=x2pnt(wZExclude,range2)
	Variable pEnd=numpnts(wZExclude)-1
	
	if (p3)
		wZExclude[0,p3]=0
	endif
	
	if (p4<pEnd)
		wZExclude[p4,pEnd]=0
	endif
	
End


Function hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
	
	Variable x1
	Variable x2
	Variable range1
	Variable range2
	
	WAVE wZExclude
	
	DrawAction/W=GraphStep0/L=ProgBack delete
	SetDrawLayer/W=GraphStep0 ProgBack
	
	SetDrawEnv xcoord= bottom,fillpat=4,linethick= 0.00,fillfgc=(0,0,0)
	DrawRect x1,0,x2,1
	
	Variable xLeft=leftx(wZExclude)
	Variable xRight=rightx(wZExclude)
	
	ControlInfo/W=GraphStep0 checkTFBeforeStim	// this control doesn't exist initially
	if (V_Flag)
		if (!V_Value)
			range1=x1	// override if pre-stim doesn't matter
		endif
	endif
	
	if (range1>xLeft)
		SetDrawEnv xcoord= bottom,fillpat=4,linethick= 0.00,fillfgc=(0,0,0)
		DrawRect xLeft,0,range1,1
	endif
	
	if (range2<xRight)
		SetDrawEnv xcoord= bottom,fillpat=4,linethick= 0.00,fillfgc=(0,0,0)
		DrawRect range2,0,xRight,1
	endif
	
	SetDrawLayer/W=GraphStep0 UserFront
	
End


Function SetVarProcBeforeTo(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable x1,x2,range1,range2
			
			x1=dval
			
			ControlInfo/W=GraphStep0 setvarAfterFrom
			x2=V_Value
			
			ControlInfo/W=GraphStep0 setvarBeforeFrom
			range1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterTo
			range2=V_Value
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			// Save
			WAVE selX1
			selX1[iROI]=x1
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcAfterFrom(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable x1,x2,range1,range2
			
			ControlInfo/W=GraphStep0 setvarBeforeTo
			x1=V_Value
			
			x2=dval
			
			ControlInfo/W=GraphStep0 setvarBeforeFrom
			range1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterTo
			range2=V_Value
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			// Save
			WAVE selX2
			selX2[iROI]=x2
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcBeforeFrom(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable x1,x2,range1,range2
			
			ControlInfo/W=GraphStep0 setvarBeforeTo
			x1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterFrom
			x2=V_Value
			
			range1=dval
			
			ControlInfo/W=GraphStep0 setvarAfterTo
			range2=V_Value
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			// Save
			WAVE selRange1
			selRange1[iROI]=range1
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProcAfterTo(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable x1,x2,range1,range2
			
			ControlInfo/W=GraphStep0 setvarBeforeTo
			x1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterFrom
			x2=V_Value
			
			ControlInfo/W=GraphStep0 setvarBeforeFrom
			range1=V_Value
			
			range2=dval
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			// Save
			WAVE selRange2
			selRange2[iROI]=range2
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcTFBeforeStim(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1
			
			WAVE selBefore
			if (checked)
				selBefore[iROI]=1
			else
				selBefore[iROI]=0
			endif
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			if (checked)
				SetVariable setvarBeforeFrom disable=0
			else
				SetVariable setvarBeforeFrom disable=2
			endif
			
			Variable x1,x2,range1,range2
			
			ControlInfo/W=GraphStep0 setvarBeforeTo
			x1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterFrom
			x2=V_Value
			
			ControlInfo/W=GraphStep0 setvarBeforeFrom
			range1=V_Value
			
			if (!checked)
				range1=x1	// override
			endif
			
			ControlInfo/W=GraphStep0 setvarAfterTo
			range2=V_Value
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			// Apply this to all not-yet-analyzed ROIs
			hiroTFinheritControlParams()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroTFLoadControlParams(iROI)
	// reload parameters on the control for the selected ROI
	
	Variable iROI
	
	WAVE selSD
	SetVariable setvarTFStep0Thresh value=_NUM:selSD[iROI]
	Slider sliderTFStep0Thresh value=selSD[iROI]
	
	WAVE selBefore
	if (selBefore[iROI])
		CheckBox checkTFBeforeStim value=1
		SetVariable setvarBeforeFrom disable=0
	else
		CheckBox checkTFBeforeStim value=0
		SetVariable setvarBeforeFrom disable=2
	endif
	
	WAVE selRange1
	SetVariable setvarBeforeFrom value=_NUM:selRange1[iROI]
	
	WAVE selX1
	SetVariable setvarBeforeTo value=_NUM:selX1[iROI]
	
	WAVE selX2
	SetVariable setvarAfterFrom value=_NUM:selX2[iROI]
	
	WAVE selRange2
	SetVariable setvarAfterTo value=_NUM:selRange2[iROI]
	
	WAVE selROI
	if (selROI[iROI])
		CheckBox checkTFIncludeROI value=1
	else
		CheckBox checkTFIncludeROI value=0
	endif
	
End


Function SetVarProcTFROI(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable iROI=floor(dval)-1
			//Print "iROI",iROI
			
			// Check if this ROI has already been analyzed before
			String nameDF="ROI_Frags"+num2str(iROI+1)
			String strDF=":"+nameDF
			if (!DataFolderExists(strDF))
				//DFREF dfr=hiroTFDetectAlignStim(iROI)
				DFREF dfr=hiroTFAlignStim(iROI)
				
				// Assume this ROI is included
				CheckBox checkTFIncludeROI value=1
			else
				DFREF dfr=:$nameDF
				// reload parameters on the control for this ROI
				hiroTFLoadControlParams(iROI)
			endif
			
			Variable x1,x2,range1,range2
			
			ControlInfo/W=GraphStep0 setvarBeforeFrom
			range1=V_Value
			
			ControlInfo/W=GraphStep0 setvarBeforeTo
			x1=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterFrom
			x2=V_Value
			
			ControlInfo/W=GraphStep0 setvarAfterTo
			range2=V_Value
			
			WAVE w=dfr:w0
			
//			// refine baseline: analyze pre-stim of the first instance (because it is uncontaminated by any stimuli)
//			Duplicate/FREE/R=(range1,x1) w,wFree
//			Redimension/N=-1 wFree
//			Variable base=StatsMedian(wFree)
//			//Print "Refined baseline",base
//			
//			Variable sd=sqrt(Variance(wFree))
//			//Print "SD",sd
			
			// wZExclude to gray-out trace from about 0 s to 1 s
			Duplicate/O w,wZExclude
			
			hiroTFUpdateZExclude(range1,x1,x2,range2)
			
			DFREF dfrSaved=GetDataFolderDFR()
				
				SetDataFolder dfr
				ReplaceWave/W=GraphStep0 allinCDF
				
			SetDataFolder dfrSaved
			
			hiroTFUpdateZExcludeOnGraph(range1,x1,x2,range2)
			
			ControlInfo/W=GraphStep0 sliderTFStep0Thresh
			hiroTFUpdateStep0Thresh(V_Value,iROI)
			
			// Update the overview
			WAVE M0
			Duplicate/O/R=[*][iROI] M0,wSel
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcTFIncludeROI(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			WAVE selROI
			
			ControlInfo/W=GraphStep0 setvarTFROI
			Variable iROI=V_Value-1	// 0-based ROI
			
			if (checked)
				selROI[iROI]=1
			else
				selROI[iROI]=0
			endif
			
			// Update graph and data
			ControlInfo/W=GraphStep0 checkTFBeforeStim
			hiroTFUpdateGraphStep0(V_Value,iROI)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function hiroTFCountSuprathresh(thresh,iROI)
	
	// Count number of responses that are above suprathreshold
	
	Variable thresh
	Variable iROI	// 0-based
	
	String nameDF="ROI_Frags"+num2str(iROI+1)
	
	DFREF dfr=:$nameDF
	
	WAVE M_StimLoc
	Duplicate/FREE/R=[][][iROI] M_StimLoc,wStimLoc
	
	Duplicate/FREE wStimLoc,wSupra
	//WAVE wSupra
	// init
	wSupra=0
	
	Variable n=CountObjectsDFR(dfr,1)
	String nameW
	
	Variable maxBefore,maxAfter,x1,x2,x3,x4
	
	// Before (e.g., from -2 to 0 s)
	//x1=-ksTFDefaultBefore
	ControlInfo/W=GraphStep0 setvarBeforeFrom
	x1=V_Value
	
	ControlInfo/W=GraphStep0 setvarBeforeTo
	x2=V_Value
	
	// After (e.g., from 1 to 5 s)
	ControlInfo/W=GraphStep0 setvarAfterFrom
	x3=V_Value
	
	//x4=ksTFDefaultAfter
	ControlInfo/W=GraphStep0 setvarAfterTo
	x4=V_Value
	
	Variable i
	for(i=0;i<n;i+=1)
		nameW="w"+num2str(i)
		WAVE w=dfr:$nameW
		
		maxBefore=WaveMax(w,x1,x2)
		maxAfter=WaveMax(w,x3,x4)
		
		if (thresh<maxBefore)
			//Print i,"Before"
			wSupra[0][i]=1
		endif
		if (thresh<maxAfter)
			//Print i,x3,x4,"After"
			wSupra[1][i]=1
		endif
		
	endfor
	
	// Store M_Supra
	WAVE M_Supra
	Variable nStim=DimSize(wSupra,1)
	
	Variable k
	for(k=0;k<nStim;k+=1)
		M_Supra[][k][iROI]=wSupra[p][k][0]
	endfor
	
	// Update graph and data
	ControlInfo/W=GraphStep0 checkTFBeforeStim
	hiroTFUpdateGraphStep0(V_Value,iROI)
	
End


Function hiroTFUpdateGraphStep0(mode,iROI)
	
	// Update GraphStep0 based on wSupra
	Variable mode	// 0 if response before stim does not matter, 1 if it does
	
	Variable iROI
	
	// Check if this ROI is included in the analysis
	WAVE selROI
	Variable includeThisROI=selROI[iROI]
	
	WAVE M_Supra
	Duplicate/FREE/R=[][][iROI] M_Supra,wSupra
	
	Variable nCols=DimSize(wSupra,1)
	String nameW
	WAVE wZExclude
	
	if (includeThisROI)
		ModifyGraph/W=GraphStep0 rgb=(65535,0,0)		// red
	else
		ModifyGraph/W=GraphStep0 rgb=(34952,34952,34952)		// gray
	endif
	
	Variable thisCounts,i
	Variable k
	for(k=0;k<nCols;k+=1)
		nameW="w"+num2str(k)
		thisCounts=0
		if (mode)
			if (wSupra[1][k]-wSupra[0][k]>0)
				thisCounts=1
			endif
		else
			if (wSupra[1][k])
				thisCounts=1
			endif
		endif
		
		if (includeThisROI)
			if (thisCounts)
				// turn on z-color
				ModifyGraph/W=GraphStep0 zColor($nameW)={wZExclude,*,*,RedWhiteBlue256,0}
				i+=1
			else
				ModifyGraph/W=GraphStep0 zColor($nameW)=0
			endif
		else
			ModifyGraph/W=GraphStep0 zColor($nameW)=0
		endif
		
	endfor
	
	WAVE wStim
	String str=num2str(i)+" of "+num2str(wStim[iROI])
	TitleBox titleResponseCounter title=str,pos={5,5},fSize=12
	
	// Update count data for this ROI
	WAVE wData	// store response number
	WAVE selROI	// check if this ROI is included
	if (includeThisROI)
		wData[iROI][1]=i
	else
		wData[iROI][1]=NaN
	endif
	
	// Reorder traces so that the counted ones come forward
	Duplicate/FREE/R=[0][*] wSupra,wBefore
	Duplicate/FREE/R=[1][*] wSupra,wAfter
	if (mode)
		wAfter-=wBefore
	endif
	
	Extract/FREE/INDX wAfter,wINDX,wAfter==1
	if (numpnts(wINDX))
		Variable kAnchor=wINDX[0]	// index of the youngest (NaN if empty)
		
		String listW=""
		Extract/FREE/INDX wAfter,wINDX,wAfter<=0		// indeces of the unchosen responses...
		for(k=0;k<numpnts(wINDX);k+=1)
			listW+="w"+num2str(wINDX[k])+","
		endfor
		
		String anchorW="w"+num2str(kAnchor)
		listW=RemoveEnding(listW)
		
		// Reorder if there are waves in the list
		if (strlen(listW))
			//ReorderTraces $anchorW, {$listW}	// doesn't work...
			String cmd
			sprintf cmd, "ReorderTraces %s,{%s}",anchorW,listW
			Execute cmd
			//Print anchorW
			//Print listW
		endif
		
	endif
	
End


Function/DF hiroTFDetectAlignStim(col)
	
	Variable col
	
	// Assume this ROI is "included" (this function is evoked for the first time on this ROI)
	CheckBox checkTFIncludeROI value=1
	
	WAVE M0
	
	Variable n=DimSize(M0,0)
	Variable nROIs=DimSize(M0,1)
	
	Duplicate/FREE/R=[][col] M0, w0
	Redimension/N=-1 w0
	
	// Estimate baseline
	Variable base=StatsMedian(w0)
	//Print "Estimated baseline (crude)",base
	
	// Estimate peak of the stim artifact
	Variable peakStim=WaveMin(w0)
	//Print peakStim
	
	DFREF dfrFree=NewFreeDataFolder()
	
	String nameW
	
	Variable fracLevel=0.9		// level threshold as a fraction from the baseline (90% works better than 10%)
	
	// find the onset of the first stim artifact (negative deflection)
	PulseStats/F=(fracLevel)/L=(base,peakStim)/P/Q w0
	if (!V_Flag)
		nameW="wStim"+num2str(0)
		Make/N=(2) dfrFree:$nameW /WAVE=w
		
		w[0]=round(V_PulseLoc1)	// onset of shutter (points)
		w[1]=round(V_PulseLoc2)	// offset of shutter
		
		Variable startP=w[1]
		Variable i
		
		do
			startP+=15	// 15 points to the right of the pervious offset
			PulseStats/F=(fracLevel)/L=(base,peakStim)/P/Q/R=[startP] w0
			if (V_Flag>1)
				break
			else
				i+=1
				nameW="wStim"+num2str(i)
				Make/N=(2) dfrFree:$nameW /WAVE=w
				
				w[0]=round(V_PulseLoc1)	// onset of shutter (points)
				w[1]=round(V_PulseLoc2)	// offset of shutter
				startP=w[1]
			endif
		while(startP<n)
		
		DFREF dfrSaved=GetDataFolderDFR()
		
		SetDataFolder dfrFree
		String strList=WaveList("*",";","")
		Variable numList=ItemsInList(strList)
		
		Concatenate/O strList, dfrSaved:wStimLoc
				
		SetDataFolder dfrSaved
	else
		Abort "No shutter artifact found."
	endif
	
	// Slice trace and align to shutter onset
	String nameDF="ROI_Frags"+num2str(col+1)
	//String nameDF="ROI_Frags"
	NewDataFolder/O :$nameDF
	DFREF dfr=:$nameDF
	
	// Check if the number of stim matches that of the previous ROI
	NVAR/Z nStimPrevious
	if (NVAR_Exists(nStimPrevious))
		if (nStimPrevious)
			if (numList!=nStimPrevious)
				String strErr="Only "+num2str(numList)+" stimuli are found in ROI "+num2str(col+1)+" (expected "+num2str(nStimPrevious)+").\r\rCan the program use the stimulus locations detected in ROI "+num2str(col)+"?\rClicking 'No' may lead to erroneous results."
				DoAlert/T="WARNING for ROI "+num2str(col+1) 1,strErr
				if (V_flag==1)
					// Optionally replace stim location with that of the previous ROI (permitted by the user)
					WAVE M_StimLoc
					Duplicate/O/R=[][][col-1] M_StimLoc,wStimLoc
					Redimension/N=(2,nStimPrevious) wStimLoc
					numList=nStimPrevious
				endif
			endif
		endif
	else
		Variable/G nStimPrevious
	endif
	
	nStimPrevious=numList
	
	// slice 2 s before and 5 s after the onset
	WAVE wStimLoc
	Variable nStim=DimSize(wStimLoc,1)
	Variable onP
	
	// Save number of detected shutters
	WAVE wStim
	wStim[col]=nStim
	//Print "-ROI",col+1,": Detected", nStim,"shutters"
	
	Variable dx=deltax(w0)
	String xUnits=WaveUnits(w0,0)
	Variable fs=1/dx
	Variable beforeP=ksTFDefaultBefore*fs
	Variable afterP=ksTFDefaultAfter*fs
	
	for(i=0;i<nStim;i+=1)
		nameW="w"+num2str(i)
		onP=wStimLoc[0][i]
		Duplicate/O/R=[onP-beforeP,onP+afterP] w0, dfr:$nameW /WAVE=wFrag
		Redimension/N=-1 wFrag
		
		// force x-scaling to the shutter peak (-2 to 5 s)
		SetScale/P x -ksTFDefaultBefore,dx,xUnits wFrag
	endfor
	
	// Store stim loc in a matrix.  Also make M_Supra because it's the same dimension
	WAVE/Z M_StimLoc
	if (!WaveExists(M_StimLoc))
		Make/N=(2,nStim,nROIs) M_StimLoc,M_Supra
		WAVE M_StimLoc
	endif
	
	Variable k
	for(k=0;k<nStim;k+=1)
		M_StimLoc[][k][col]=wStimLoc[p][k]
	endfor
	
	// Delete wStimLoc (prevents unwanted concatenation when the ROI changes)
	KillWaves wStimLoc
	
	return dfr
	
End


Function hiroTFDetectStim()
	
	// simplified version of hiroTFDetectAlignStim() with a modified fracLevel
	// it merely detects stim onsets; no alignment will be done.
	// It uses a small signal processing to improve detection of all stim artifacts.
	// It assumes that stim location is conserved among all ROIs.
	// The fragments that results may be misaligned because stim location cannot be done per ROI basis
	
	WAVE M0
	
	Variable n=DimSize(M0,0)
	Variable nROIs=DimSize(M0,1)
	
	if (nROIs>1)
		MatrixOp wSum=sumRows(M0)	// Note that all wave scaling is lost in MatrixOp
		
		// Reapply wave scaling
		Variable startX=DimOffset(M0,0)
		Variable dx=DimDelta(M0,0)
		String xUnits=WaveUnits(M0,0)
		String yUnits=WaveUnits(M0,-1)
		SetScale/P x startX,dx,xUnits, wSum
		SetScale d 0,0,yUnits, wSum
	else
		Duplicate M0,wSum
	endif
	
	WAVE w0=wSum
	
	// Estimate baseline
	Variable base=StatsMedian(w0)
	//Print "Estimated baseline (crude)",base
	
	// Estimate peak of the stim artifact
	Variable peakStim=WaveMin(w0)
	//Print peakStim
	
	DFREF dfrFree=NewFreeDataFolder()
	
	String nameW
	
	Variable fracLevel=0.5		// level threshold as a fraction from the baseline (25% works better than 50% or 90%)
	
	// find the onset of the first stim artifact (negative deflection)
	PulseStats/F=(fracLevel)/L=(base,peakStim)/P/Q w0
	if (!V_Flag)
		nameW="wStim"+num2str(0)
		Make/N=(2) dfrFree:$nameW /WAVE=w
		
		w[0]=round(V_PulseLoc1)-1	// onset of shutter (points)
		w[1]=round(V_PulseLoc2)-1	// offset of shutter
		
		Variable startP=w[1]
		Variable i
		
		do
			startP+=15	// 15 points to the right of the pervious offset
			PulseStats/F=(fracLevel)/L=(base,peakStim)/P/Q/R=[startP] w0
			if (V_Flag>1)
				break
			else
				i+=1
				nameW="wStim"+num2str(i)
				Make/N=(2) dfrFree:$nameW /WAVE=w
				
				w[0]=round(V_PulseLoc1)-1	// onset of shutter (points)
				w[1]=round(V_PulseLoc2)-1	// offset of shutter
				
				startP=w[1]
			endif
		while(startP<n)
		
		DFREF dfrSaved=GetDataFolderDFR()
		
		SetDataFolder dfrFree
		String strList=WaveList("*",";","")
		Variable numList=ItemsInList(strList)
		
		Concatenate/O strList, dfrSaved:wStimLoc
				
		SetDataFolder dfrSaved
	else
		Abort "No shutter artifact found."
	endif
	
End


Function/DF hiroTFAlignStim(iROI)
	
	Variable iROI
	
	// Slice trace and align to shutter onset
	String nameDF="ROI_Frags"+num2str(iROI+1)
	NewDataFolder/O :$nameDF
	DFREF dfr=:$nameDF
	
	// slice 2 s before and 5 s after the onset
	WAVE wStimLoc
	Variable nStim=DimSize(wStimLoc,1)
	Variable onP
	
	// Save number of detected shutters
	WAVE wStim
	wStim[iROI]=nStim
	//Print "-ROI",col+1,": Detected", nStim,"shutters"
	
	WAVE M0
	Duplicate/FREE/R=[][iROI] M0,w0
	
	Variable nROIs=DimSize(M0,1)
	
	Variable dx=deltax(w0)
	String xUnits=WaveUnits(w0,0)
	Variable beforeP=ksTFDefaultBefore/dx
	Variable afterP=ksTFDefaultAfter/dx
	
	String nameW
	Variable i
	
	for(i=0;i<nStim;i+=1)
		nameW="w"+num2str(i)
		onP=wStimLoc[0][i]
		Duplicate/O/R=[onP-beforeP,onP+afterP] w0, dfr:$nameW /WAVE=wFrag
		Redimension/N=-1 wFrag
		
		// force x-scaling to the shutter peak (-2 to 5 s)
		SetScale/P x -ksTFDefaultBefore,dx,xUnits wFrag
	endfor
	
	// Store stim loc in a matrix.  Also make M_Supra because it's the same dimension
	WAVE/Z M_StimLoc
	if (!WaveExists(M_StimLoc))
		Make/N=(2,nStim,nROIs) M_StimLoc,M_Supra
		WAVE M_StimLoc
	endif
	
	for(i=0;i<nStim;i+=1)
		M_StimLoc[][i][iROI]=wStimLoc[p][i]
	endfor
	
	// Delete wStimLoc (prevents unwanted concatenation when the ROI changes)
	//?KillWaves wStimLoc
	
	// Flag this ROI as analyzed
	WAVE selVirgin
	selVirgin[iROI]=0
	
	return dfr
	
End


Function hiroTFinheritControlParams()
	
	WAVE selVirgin
	
	// Other not-yet-analyzed ROIs will inherit parameters of this ROI
	Extract/FREE/INDX selVirgin, wINDX, selVirgin==1
	
	WAVE selBefore
	ControlInfo checkTFBeforeStim
	Variable before=V_Value
	
	WAVE selRange1
	ControlInfo setvarBeforeFrom
	Variable range1=V_Value
	
	WAVE selRange2
	ControlInfo setvarAfterTo
	Variable range2=V_Value
	
	WAVE selSD
	ControlInfo setvarTFStep0Thresh
	Variable sd=V_Value
	
	WAVE selX1
	ControlInfo setvarBeforeTo
	Variable x1=V_Value
	
	WAVE selX2
	ControlInfo setvarAfterFrom
	Variable x2=V_Value
	
	Variable i,k
	for(i=0;i<numpnts(wINDX);i+=1)
		k=wINDX[i]
		selBefore[k]=before
		selRange1[k]=range1
		selRange2[k]=range2
		selSD[k]=sd
		selX1[k]=x1
		selX2[k]=x2
	endfor
	
End