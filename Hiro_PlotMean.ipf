#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.05		// version of procedure
#pragma IgorVersion=6.2

#include <WaveSelectorWidget>
#include <PopupWaveSelector>

// Written by Hiro Watari © 2010-2015
// This ipf is shared among BosmaEphys.ipf and BosmaImaging.ipf.  It plots means and does ANOVA or t-test
// Requires BosmaCoreServices.ipf

// What's new in Hiro_PlotMean 1.05 (2015-08-28);Supports STEM on automated plots of means;---
// What's new in Hiro_PlotMean 1.04 (2015-08-18);Supports cleaner report in the history for automated stats;---
// What's new in Hiro_PlotMean 1.03 (2015-07-31);Supports fully automated graph and stats;---
// What's new in Hiro_PlotMean 1.02 (2015-07-30);Supports alphanumeric sort that sorts p9 before p10;Supports two new plot styles;---
// What's new in Hiro_PlotMean 1.01 (2014-07-10);Supports semi-automated plotting of a mean±STE graph;---
// What's new in Hiro_PlotMean 1.00 (2010-10-24);Initial release;---

static constant kPanelHeight=255
static constant kPanelWidth=300
static constant kButtonAddYPos=210
static constant kButtonDoItYPos=225
static constant kPopupWavesPos=60
static constant kMovePosBy=30

// copied from PopupWaveSelector.ipf
static StrConstant MenuArrowString = "\\W623"
static StrConstant Font9String="\\Z09"
static StrConstant RightJustString="\\JR"


Function PlotMeanMono(list, matchStr, skipprompt)
	// Simplified plot with no color.  For color, see PlotMean()
	// This version is easier to make and edit
	
	String list
	String matchStr // e.g., "*c V1 Stim10"; it is used to parse this out from labels
	Variable skipprompt	// 0=prompt as usual; 1=skip prompt, the first wave in the list is the control, 2=skip, the first is not the control
	
	matchStr=ReplaceString("*",matchStr," ")
	
	// Save ref to current DF
	DFREF savedDFR = GetDataFolderDFR()
	String pDF = GetDataFolder(1)
	
	//Find number of groups to plot
	Variable i = ItemsInList(list)
	
	//Prompt for group name and create a new data folder.
	String nameDF = GetDataFolder(0), pathDF
	nameDF = ReplaceString("'",nameDF,"")
	//String yLabel="Replace this text. See Help to learn how to make a word into a subscript"
	String yLabel=nameDF
	nameDF = findNameThatDoesNotExist(savedDFR,nameDF)
	if (!skipprompt)
		Prompt yLabel, "Y-Axis Label (e.g., \"Frequency (Hz)\")"
		Prompt nameDF, "Graph Name"
		
		DoPrompt/help="If you want to make a word into a subscript, type \"\\B\" before and \"\\M\" after the word.\r\re.g., \"V\\Brev\\M (mV)\"" "Y-Axis label and Graph Name",yLabel,nameDF
		
		if (V_flag == 1)
			Print "User Canceled Procedure"
			return -1	//quit if cancel button was clicked
		endif
	endif
	
	if (i == 0)
		String strAlert = "Plot Mean Error in "+nameDF+": There must be at least one group"
		LogError(strAlert)
		DoAlert 0, strAlert
		return -1
	endif
	
	Print nameDF+":"
	pathDF = pDF + "'>" + nameDF + "'"
	NewDataFolder/O/S $pathDF
	
	Make/O/N=(i)/T labels
	Make/O/N=(i) wXloc=x		// new
	Make/O wVertHolder		// new, assumes you have less than n=128 in each group
	Make/N=(i) wAvg, wStem
	Variable k
	//String strGraphName = "dummyGraphName"
	String SelectedWave
	String strN	// sample size
	
	for (k=0;k<i;k+=1)
		SetDataFolder savedDFR
		
		SelectedWave = StringFromList(k,list)
		
		// Write label to be used on the graph
		//labels[k] = SelectedWave		//? potentially parse out portion of the string that are identical (e.g., "p9" instead of "p9 c V1 Stim10")
		labels[k] = ReplaceString(matchStr,SelectedWave,"")
		labels[k] = ReplaceString("p",labels[k],"")
		
		String strDupWavePathDF
		strDupWavePathDF = pathDF + ":'" + SelectedWave + "'"
		
		Duplicate/O $SelectedWave, $strDupWavePathDF
		
		SetDataFolder $pathDF
		
		// Find mean and standard error of mean
		WaveStats/Q $SelectedWave; wAvg[k]=V_avg; wStem[k]=V_sdev/sqrt(V_npnts)
		
		strN = num2istr(V_npnts)
		
		if (V_npnts>128)
			// allow more than 128 data points to show vertically for each group
			Redimension/N=(V_npnts) wVertHolder
		endif
		
		Print num2istr(k+1) + ": " + ReplaceString(matchStr,SelectedWave,"") + ", n=" + strN
		
		if (k==0)
			//Variable x0,y0
			//Variable width = 110*i
			//Variable height = 250
			
			//CenterObjScreen(x0,y0,width,height)
			
			//Display/K=1/W=(x0,y0,x0+width,y0+height) wAvg as nameDF		// modified vers
			Display/K=1 wAvg as nameDF
			AutoPositionWindow/E
			ModifyGraph rgb(wAvg)=(0,0,0)
			ModifyGraph mode(wAvg)=0,marker(wAvg)=8
			ModifyGraph highTrip(left)=100000,lowTrip(left)=0.01
			
			//strGraphName = WinName(0,1)	//Store name of the graph
			//DoWindow/T $strGraphName, nameDF
			//SetAxis/A/E=1 left
			Label left yLabel
			//if (i>13)	// Put bottom labels at an angle if there's more than 13 groups
			//	ModifyGraph lblRot=0,tkLblRot(bottom)=45
			//endif
			ErrorBars wAvg Y,wave=(wStem,wStem)
		endif
		
		// Tag sample size
		//Tag/B=1/F=0/I=0/L=0/X=0/Y=2 bottom, k+0.5, strN	// for positive mean values
		
		AppendToGraph $SelectedWave vs wVertHolder		// a new approach
		ModifyGraph rgb($SelectedWave)=(34952,34952,34952)
		ModifyGraph mode($SelectedWave)=3,marker($SelectedWave)=8,offset($SelectedWave)={k,0}
		
	endfor
	
	// Disable standoff for bottom axis
	ModifyGraph standoff(bottom)=1
	
	ModifyGraph userticks(bottom)={wXloc,labels}
	
	DoUpdate
	
	// Do stats
	Print "Stats:"
	StatsOnDemand(list,skipprompt,matchStr,nameDF)	// Shows significant differences in history area
	
	SetDataFolder savedDFR
	
End


Function PlotMean(list)
	
	String list
	
	// Save ref to current DF
	DFREF savedDFR = GetDataFolderDFR()
	String pDF = GetDataFolder(1)
	
	//Find number of groups to plot
	Variable i = ItemsInList(list)
	
	//Prompt for group name and create a new data folder.
	String nameDF = GetDataFolder(0), pathDF
	nameDF = ReplaceString("'",nameDF,"")
	//String yLabel="Replace this text. See Help to learn how to make a word into a subscript"
	String yLabel=nameDF
	nameDF = findNameThatDoesNotExist(savedDFR,nameDF)
	Prompt yLabel, "Y-Axis Label (e.g., \"Frequency (Hz)\")"
	Prompt nameDF, "Graph Name"
	
	DoPrompt/help="If you want to make a word into a subscript, type \"\\B\" before and \"\\M\" after the word.\r\re.g., \"V\\Brev\\M (mV)\"" "Y-Axis label and Graph Name",yLabel,nameDF
	
	if (V_flag == 1)
		Print "User Canceled Procedure"
		return -1	//quit if cancel button was clicked
	endif

	if (i == 0)
		String strAlert = "Plot Mean Error: There must be at least one group"
		LogError(strAlert)
		DoAlert 0, strAlert
		return -1
	endif
	
	Print nameDF+":"
	pathDF = pDF + "'x" + nameDF + "'"
	NewDataFolder/O/S $pathDF

	Make/O/N=(i)/T labels
	Make/N=(i) wAvg, wStem
	Variable k=0
	String strGraphName = "dummyGraphName"
	String SelectedWave
	String strN	// sample size
	
	do
		SetDataFolder savedDFR
		
		SelectedWave = StringFromList(k,list)
		
		// Write label to be used on the graph
		labels[k] = SelectedWave
	
		String strDupWavePathDF
		strDupWavePathDF = pathDF + ":'" + SelectedWave + "'"

		Duplicate/O $SelectedWave, $strDupWavePathDF

		SetDataFolder $pathDF
		
		// Find mean and standard error of mean
		WaveStats/Q $SelectedWave; wAvg[k]=V_avg; wStem[k]=V_sdev/sqrt(V_npnts)
		
		strN = num2istr(V_npnts)
		Print num2istr(k+1) + ": " + SelectedWave + ", n=" + strN
		
		// Make x waves that are the same number of points as each
		// wave containing individual mini size measurements.  The
		// X values should be .5, 1.5 2.5, etc. because category plot
		// bars are centered between 0 and 1, 1 and 2, etc.
		// Make a name of wave for individual data points
		String SelectedWave_X = SelectedWave + "_x"

		// Make individual data plot
		Make/O/N=(numpnts($SelectedWave)) $SelectedWave_X = k+1
		
		if (k==0)
			Variable x0,y0
			Variable width = 110*i
			Variable height = 250
			
			CenterObjScreen(x0,y0,width,height)
			
			Display/K=1/W=(x0,y0,x0+width,y0+height) wAvg vs labels
			strGraphName = WinName(0,1)	//Store name of the graph
			DoWindow/T $strGraphName, nameDF
			SetAxis/A/E=1 left
			Label left yLabel
			if (i>13)	// Put bottom labels at an angle if there's more than 13 groups
				ModifyGraph lblRot=0,tkLblRot(bottom)=45
			endif
			ErrorBars wAvg Y,wave=(wStem,wStem)
		endif
		
		// Tag sample size
		Tag/B=1/F=0/I=0/L=0/X=0/Y=2 bottom, k+0.5, strN	// for positive mean values
		
		// Append three traces, one for each group, to the graph.  Each
		// is plotted as an XY pair.  Note that these are plotted
		// on a new free axis named bottom2, since we can't
		// plot numerical data like this against an axis that is
		// being used as a category plot axis.
		AppendToGraph/b=bottom2 $SelectedWave vs $SelectedWave_X
		
		// Set the mode to markers.
		ModifyGraph mode($SelectedWave)=3,marker($SelectedWave)=1
		
		k+=1
	while (k < i)
	
	DoWindow/F strGraphName		//Bring  graph to the top
	
	// Make the bottom2 axis disappear.
	ModifyGraph nticks(bottom2)=0,noLabel(bottom2)=2,axThick(bottom2)=0
	
	// Make the bottom2 axis overlap the regular bottom axis.
	ModifyGraph freePos(bottom2)={0,left}

	// Disable standoff for axes
	ModifyGraph standoff=0
	
	// Set the range of the bottom2 axis to be the same as the
	// regular bottom axis so the bars and data points line up
	// properly.
	SetAxis bottom2 0,i
	
//	Colors[][0] = {0,3,65535}
//	Colors[][1] = {0,52428,0}
//	Colors[][2] = {0,1,0}
	
	// Change colors of the data points
//	ModifyGraph rgb(g1)=(0,0,0),rgb(g2)=(3,52428,1),rgb(g3)=(65535,0,0)
	
	ColorizeData()
	
	DoUpdate
	
	// Do stats
	Print "Stats:"
	StatsOnDemand(list,0,"",nameDF)	// Shows significant differences in history area
	
	SetDataFolder savedDFR

End


Function ColorizeData()
	
	NVAR i=root:Packages:PlotMean:id
	String popCtrlName
	Variable k=0
	
	// Make a color wave
	Make/N=(i+1,3,0)/D Colors
	
	do
		popCtrlName="popcolor"+num2str(k)
		ControlInfo/W=PanelPlotMean $popCtrlName
		Colors[k][0] = V_Red
		Colors[k][1] = V_Green
		Colors[k][2] = V_Blue
		
		popCtrlName="popup"+num2str(k)
		ControlInfo/W=PanelPlotMean $popCtrlName
		ModifyGraph rgb($S_Value)=(V_Red,V_Green,V_Blue)
//		Print k,S_Value,V_Red,V_Green,V_Blue
		k+=1
	while(k<=i)

	// Change the color of the bars
	ModifyGraph zColor(wAvg)={Colors,*,*,directRGB}
	
End


Function/S ListWaves()	// in current DF
	
	DFREF dfr = GetDataFolderDFR()
	
	String objName,list=""
	Variable i=0
	
	do
		objName = GetIndexedObjNameDFR(dfr, 1, i)
		if (strlen(objName) == 0)
			break
		endif
		list+=objName + ";"
		i+=1
	while(1)
	
	return list
	
End


Function CreatePanelPlotMean()
	
	String pDF = GetDataFolder(1)
	String strTitle = RightJustString+ReplaceString("'",GetDataFolder(0),"")+Font9String+MenuArrowString
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:PlotMean
	Variable/G root:Packages:PlotMean:id

	// Get Screen size
	Variable x0,y0
	Variable width = kPanelWidth
	Variable height = kPanelHeight
	
	CenterObjScreen(x0,y0,width,height)
	
	NewPanel/N=PanelPlotMean/K=1/W=(x0,y0,x0+width,y0+height) as "New Plot Mean"
	
	Button popupDF,pos={80,10},size={195,20}
	Button popupDF help={"Find the Data Folder that contains your data"}
	MakeButtonIntoWSPopupButton("PanelPlotMean", "popupDF", "PopupDFSelectorNotify", initialSelection=pDF,options=PopupWS_OptionFloat, content=WMWS_DataFolders)
	Button popupDF title=strTitle
	TitleBox WSPopupTitle1,pos={20,13},size={115,20},title="Data Folder:"
	TitleBox WSPopupTitle1,frame=0
	
	Button buttonDoIt title="Plot",pos={225,kButtonDoItYPos},size={50,20},proc=ButtonDoIt
	Button buttonDoIt help={"Click this button when everything is ready"}
	Button buttonCancel title="Cancel",pos={155,kButtonDoItYPos},size={60,20},proc=ButtonCancelProc
	Button buttonCancel help={"Click this button to cancel"}
	
	// Check if there is at least two waves in the current DF
	if (CountObjects("",1) > 1)
		ShowFirstTwoWaves(GetDataFolder(0))
	else
		Button buttonDoIt disable=2
	endif
	
End


Function PopupDFSelectorNotify(event, path, windowName, ctrlName)
	Variable event
	String path
	String windowName
	String ctrlName
	
	NVAR i=root:Packages:PlotMean:id
	
	if (cmpstr(path,"root") == 0)
		path = "root:"	// avoid error by adding a colon
	endif
	
	// Set current DF
	SetDataFolder path
	
	String strTitle = RightJustString+ReplaceString("'",GetDataFolder(0),"")+Font9String+MenuArrowString
	
	Button popupDF title=strTitle
	
	// Check if there is at least two waves in the current DF
	Variable count = CountObjects("",1)
	
	KillAllPopMenus()
	
	if (count > 1)
		if (count - i > 1)
			Button buttonAdd title="+",size={20,20},pos={10,kButtonAddYPos},proc=ButtonAdd
			Button buttonAdd help={"Click this button to add another group"}
			Button buttonSubtract title="-",size={20,20},pos={35,kButtonAddYPos},proc=ButtonSubtract
			Button buttonSubtract help={"Click this button to remove a group"}
		endif
		ShowFirstTwoWaves(GetDataFolder(0))
		Button buttonDoIt disable=0
	else
		KillControl/W=PanelPlotMean buttonAdd
		KillControl/W=PanelPlotMean buttonSubtract
		Button buttonDoIt disable=2
	endif
	
	// Reset panel size
	ResizeWindow(kPanelWidth,kPanelHeight)
	Button buttonDoIt pos={225,kButtonDoItYPos}
	Button buttonCancel pos={155,kButtonDoItYPos}
	
End


Function KillAllPopMenus()
	
	String popCtrlName
	
	NVAR i=root:Packages:PlotMean:id
	
	// Check if there is at least two waves in the current DF
	Variable count = CountObjects("",1)
	
	do
		popCtrlName = "popup"+num2str(i)
		KillControl/W=PanelPlotMean $popCtrlName
		popCtrlName = "popcolor"+num2str(i)
		KillControl/W=PanelPlotMean $popCtrlName
		i-=1
	while(i>=0)
	
End


Function ShowFirstTwoWaves(popStr)
	
	String popStr
	
//	SVAR list=root:Packages:PlotMean:listWaves
	NVAR i=root:Packages:PlotMean:id
	
	// reset global variables
	i=0
	
	String popCtrlName="popup"+num2str(i)
	
	PopupMenu $popCtrlName title=num2str(i+1)+FormatGroupLabel(),pos={20,kPopupWavesPos+(i*kMovePosBy)},mode=1
	PopupMenu $popCtrlName value=PopupList()
	
	Variable r,g,b
	ChooseFrom10PresetColors(i, r, g, b)
	
	popCtrlName = "popcolor"+num2str(i)
	PopupMenu $popCtrlName pos={230,kPopupWavesPos+(i*kMovePosBy)},size={96,20}
	PopupMenu $popCtrlName mode=1,popColor=(r,g,b),value= "*COLORPOP*"
	
	AddNewPopupWave()
	
	Variable count = CountObjects("",1)
	if (count - i > 1)
		Button buttonAdd title="+",size={20,20},pos={10,kButtonAddYPos},proc=ButtonAdd
		Button buttonAdd help={"Click this button to add another group"}
		Button buttonSubtract title="-",size={20,20},pos={35,kButtonAddYPos},proc=ButtonSubtract
		Button buttonSubtract help={"Click this button to remove a group"},disable=2
	endif
	
End


Function/S PopupList()
// Returns a list of waves to display in the popup menu
	
	//SVAR list=root:Packages:PlotMean:listWaves
	String list=SortList(WaveList("*",";",""),";",16)
	
	return list
	
End


Function/S FormatGroupLabel()
	
	NVAR i=root:Packages:PlotMean:id
	
	switch(i+1)
		case 1:
			return "st Group: "
			break
		case 2:
			return "nd Group: "
			break
		case 3:
			return "rd Group: "
			break
		default:
			return "th Group: "
	endswitch
	
End


Function AddNewPopupWave()
	
	NVAR i=root:Packages:PlotMean:id
	
	String popCtrlName="popup"+num2str(i)
	ControlInfo/W=PanelPlotMean $popCtrlName

	i+=1
	popCtrlName="popup"+num2str(i)
	
	PopupMenu $popCtrlName title=num2str(i+1)+FormatGroupLabel(),pos={20,kPopupWavesPos+(i*kMovePosBy)},mode=V_value+1
	PopupMenu $popCtrlName value=PopupList()
	
	Variable r,g,b
	ChooseFrom10PresetColors(i, r, g, b)
	
	popCtrlName = "popcolor"+num2str(i)
	PopupMenu $popCtrlName pos={230,kPopupWavesPos+(i*kMovePosBy)},size={96,20}
	PopupMenu $popCtrlName mode=1,popColor=(r,g,b),value= "*COLORPOP*"
	
	if (i>4)
		// move buttons and resize window to make room
		ResizeWindow(300,kPanelHeight+(i-4)*kMovePosBy)
		Button buttonAdd pos={10,kButtonAddYPos+(i-4)*kMovePosBy}
		Button buttonSubtract pos={35,kButtonAddYPos+(i-4)*kMovePosBy}
		Button buttonDoIt pos={225,kButtonDoItYPos+(i-4)*kMovePosBy}
		Button buttonCancel pos={155,kButtonDoItYPos+(i-4)*kMovePosBy}
	endif
	
	Button buttonSubtract disable=0
	
End


Function/S ListSelectedWavesFromPopups()
	
	String list=""
	
	NVAR i=root:Packages:PlotMean:id
	String popCtrlName
	Variable k=0
	do
		popCtrlName="popup"+num2str(k)
		ControlInfo/W=PanelPlotMean $popCtrlName
		list+=S_value+";"
		k+=1
	while(k<=i)
	
	return list
	
End


Function ButtonAdd(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			NVAR i=root:Packages:PlotMean:id
			Variable count=CountObjects("",1)
			if (i+1 < count)
				AddNewPopupWave()
				if (i+1==count)
					Button buttonAdd disable=2	// visible and disabled
				endif
			endif
			break
	endswitch

	return 0
End


Function ButtonSubtract(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			NVAR i=root:Packages:PlotMean:id
			if (i > 1)
				String popCtrlName="popup"+num2str(i)
				KillControl/W=PanelPlotMean $popCtrlName
				popCtrlName="popcolor"+num2str(i)
				KillControl/W=PanelPlotMean $popCtrlName
				i-=1
				if (i>1)
					Button buttonSubtract disable=0
				else
					Button buttonSubtract disable=2
				endif
			else
				Button buttonSubtract disable=2
			endif
			
			break
	endswitch

	return 0
End


Function ButtonDoIt(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			String list=ListSelectedWavesFromPopups()
			//PlotMean(list)
			PlotMeanMono(list,"*c V1 Stim10",0)
			DoWindow/K PanelPlotMean
			break
	endswitch

	return 0
End


Function ButtonCancelProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			DoWindow/K PanelPlotMean
			break
	endswitch

	return 0
End


Function PlotMeanSTEwLabels(mode)
	// Plot a custom graph of mean ± STE
	
	Variable mode	// 4 for lines and markers, 5 for bars
	
	// Conditions:
	// The DF contains at least two waves with the prefix "mean_".
	// The DF contains the same number of waves with the prefix "ste_"
	// Each wave contains the same number of points (i.e., experimental groups)
	
	DFREF thisDFR = GetDataFolderDFR()
	String nameDF = GetDataFolder(0, thisDFR)
	
	Variable nWaves = CountObjectsDFR(thisDFR,1)
	if (nWaves == 0)
		Print "This data folder,",nameDF,"contains no waves!"
	elseif (nWaves < 4)
		Print nameDF,"does not contain enough waves! You need at least two waves for the means and two waves for the STEs"
	endif
	
	String wName,mean_1, mean_2
	Variable i=0,k=0
	
	String list = WaveList("*", ";", "")
	String listMeans = ""
	String steName
	
	String strLabelError = ""
	
	do
		wName = StringFromList(i,list)
		if (strlen(wName) == 0)
			break
		endif
		if (strsearch(wName,"mean_",0) == 0)
			steName = ReplaceString("mean_",wName,"ste_")
			listMeans = listMeans + wName + ";"	// just for record keeping
			if (k == 0)
				// Check if a wave called "labels" exists
				WAVE w=labels
				if (WaveExists(w) == 0)
					Make/N=(numpnts($wName))/T labels
					strLabelError = "Labels are blank. Please enter them in the table after clicking OK"
				endif
				Display/K=1 $wName vs labels
				if (mode == 4)
					ModifyGraph marker($wName)=8
				elseif (mode == 5)
					ModifyGraph rgb($wName)=(30583,30583,30583)
				endif
			else
				AppendToGraph $wName vs labels
				if (mode == 4)
					ModifyGraph marker($wName)=19
				elseif (mode == 5)
					ModifyGraph rgb($wName)=(0,0,0)
				endif
			endif
			// Check if a wave with the appropriate ste_ prefix exists
			WAVE w=$steName
			if (WaveExists(w) == 1)
				if (mode == 4)
					ErrorBars $wName Y,wave=(,$steName)
				elseif (mode == 5)
					ErrorBars $wName Y,wave=($steName,$steName)
				endif
			else
				Print "An STE wave for",wName,"cannot be found. Please append STE manually to this mean."
			endif
			k+=1
		endif
		i+=1
	while(i<nWaves)
	
	//Print listMeans
	
	ModifyGraph mode=mode
	if (mode == 4)
		ModifyGraph opaque=1,rgb=(0,0,0),msize=5
		ModifyGraph catGap(bottom)=1,barGap(bottom)=0
		Legend/C/N=text0/F=0/A=MC
	endif
	
	if (strlen(strLabelError) > 0)
		DoAlert/T="Labels needed" 0, strLabelError
		Edit/K=1 labels
	endif
End


Function PlotMeanWavesInThisDF()
	// After running Average Waves, plot mean waves with stem
	// works in current DF
	
	String listMean=WaveList("mean_*",";","")
	
	if (!strlen(listMean))
		DoAlert/T="Try again" 0,"Select a Data Folder containing waves with name 'mean_'\rand try again."
		return -1
	endif
	
	listMean=SortList(listMean,";",16)		// make sure p9 comes before p10
	
	Variable n=ItemsInList(listMean)
	
	String nameW,nameSTEM
	
	Make/O/T/N=(n) wAxisYText
	Make/O/N=(n) wAxisYIndx
	
	WAVE/T wT=wAxisYText
	WAVE wINDX=wAxisYIndx
	
	Display
	
	Variable pad,maxPad
	
	Variable i
	for (i=0;i<n;i+=1)
		nameW=StringFromList(i,listMean)
		
		AppendToGraph $nameW
		
		nameSTEM=ReplaceString("mean_",nameW,"ste_")
		
		ErrorBars $nameW Y,wave=(,$nameSTEM)
		
		pad=WaveMax($nameW)
		
		if (pad>maxPad)
			maxPad=pad
		endif
		
		wT[i]=ReplaceString("mean_",nameW,"")
	endfor
	
	Variable offset
	for (i=0;i<n;i+=1)
		nameW=StringFromList(i,listMean)
		
		offset=-i*maxPad
		
		ModifyGraph offset($nameW)={0,offset}
		
		wINDX[i]=offset
	endfor
	
	// Custom label on y-axis
	ModifyGraph userticks(left)={wAxisYIndx,wAxisYText}
End