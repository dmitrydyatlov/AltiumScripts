// Function extrcts prefix from a designator
function extractPrefixFromDesignator( designator  : string): string;
var
   i  : integer;
begin
  result := '';
  for i := 1 to length(designator) do
  begin
    if ((designator[i] >= 'A') and (designator[i] <= 'Z')) then
    begin
      result := result + designator[i];
    end
       else
    begin
         break;
    end;
  end;
end;

// Function extracts numeric part of designator
function extractIndexFromDesignator( designator : string) : integer;
var
  i                 : integer;
  k                 : integer;
  numberString      : string;
begin
    k := 1;
    while ((designator[k] < '0') or (designator[k] > '9')) do inc(k);
    for i := k to length(designator) do
    begin
      if ((designator[i] >= '0') and (designator[i] <= '9')) then
      begin
         numberString := numberString + designator[i];
       end
        else
       begin
            break;
       end;
    end;
    result := StrToInt(numberString);
end;

// Function compares two designators. Prefix and numeric parts are compared separately
function compareDesignators(designator1 : string; designator2 : string) : integer;
var

  desPrefix1, desPrefix2         : String;
  desNumber1, desNumber2         : Integer;

  i: integer;
  f: boolean;
  a, b: string;
begin
  desPrefix1 := extractPrefixFromDesignator(designator1);
  desPrefix2 := extractPrefixFromDesignator(designator2);

  desNumber1 := extractIndexFromDesignator(designator1);
  desNumber2 := extractIndexFromDesignator(designator2);

  result := 0;
  if (desPrefix1 > desPrefix2) then result := 1
  else if (desPrefix1 < desPrefix2) then result := -1
  else
    begin
      if (desNumber1 > desNumber2) then result := 1
      else if (desNumber1 < desNumber2) then result := -1;
    end;
end;

// Sorts StringList with designators
procedure sortList(listToSort: TStringList);
var
   sorted  : boolean;
   i       : integer;
   r       : integer;
begin
   sorted := false;
   while not sorted do
   begin
       sorted := true;
       for i := 0 to listToSort.Count - 2 do
       begin
           r := compareDesignators(listToSort[i], listToSort[i + 1]);
           if (r = 1) then
           begin
               sorted := false;
               listToSort.Exchange(i, i+1);
           end;
       end;
   end;
end;

function ListSelectedPcbComponents(PcbDocList : TStringList) : TStringList;
var
  component                          : IPcb_component;
  componentIterator                  : IPcb_iterator;
  i                                  : integer;
  board                              : IPcb_Board;
begin
  result := TStringList.Create;
  for i := 0 to PcbDocList.Count - 1 do
  begin
      board := PcbServer.LoadPCBBoardByPath(PcbDocList[i]);
      if (board <> nil) then
      begin
        componentIterator := board.BoardIterator_Create;
        componentIterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        component := componentIterator.FirstPcbObject;
        while (component <> nil) do
        begin
          if (component.selected) then result.Add(Component.Name.Text);
          component := componentiterator.NextPcbObject;
        end;
      end;
  end;
end;

function ListSelectedSchComponents(SchDocList : TStringList) : TList;
var
  component                          : ISch_component;
  componentIterator                  : ISch_iterator;
  i                                  : integer;
  sheet                              : ISch_Scheet;
begin
  result := TStringList.Create;
  for i := 0 to schDocList.Count - 1 do
  begin
      sheet := SchServer.LoadSchDocumentByPath(SchDocList[i]);
      if (sheet <> nil) then
      begin
        componentIterator := sheet.SchIterator_Create;
        componentIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
        component := componentIterator.FirstSchObject;
        while (component <> nil) do
        begin
          if (component.selection) then result.Add(Component.Designator.Text);
          component := componentiterator.NextSchObject;
        end;
      end;
  end;
end;

function checkListsCorrespondence(SchDesignatorsList : TStringList; PcbDesignatorsStringList: TStringList) : boolean;
var
   i : integer;
begin
     result := true;
     if ((SchDesignatorsList.Count = 0) or (PcbDesignatorsStringList.Count = 0)) then
     begin
       result := false;
     end
       else
     if (SchDesignatorsList.Count <> PcbDesignatorsStringList.Count) then
     begin
       result := false;
     end
        else
     begin
          for i := 0 to SchDesignatorsList.Count - 1 do
          begin
            if (extractPrefixFromDesignator(SchDesignatorsList[i]) <> extractPrefixFromDesignator(PcbDesignatorsStringList[i])) then
            begin
                 result := false;
                 break;
            end;
          end;
     end;
end;

function reannotatePcbComponents(PcbDocList : TStringList; SchDesignatorsList : TStringList; PcbDesignatorsList: TStringList) : boolean;
var
   i                  : integer;
   componentIdx       : integer;
   board              : IPcb_Board;
   componentIterator  : IPcb_iterator;
   component          : IPcb_component;
begin
  result := true;
  for i := 0 to PcbDocList.Count - 1 do
  begin
      board := PcbServer.LoadPCBBoardByPath(PcbDocList[i]);
      if (board <> nil) then
      begin
        componentIterator := board.BoardIterator_Create;
        componentIterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        PCBServer.PreProcess;
        component := componentIterator.FirstPCBObject;
        while (component <> nil) do
        begin
          if (component.selected) then
          begin
            componentIdx := PcbDesignatorsList.IndexOf(component.name.text);
            if (componentIdx <> -1) then
            begin
                 component.name.text := SchDesignatorsList[componentIdx];
            end;
          end;
          PCBServer.SendMessageToRobots(component.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);
          component := componentiterator.NextPcbObject;
        end;
        PCBServer.PostProcess;
        Client.SendMessage('PCB:Zoom', 'Action=Redraw' , 255, Client.CurrentView);
      end;
  end;
end;

procedure deleteDuplicatesOfSelectedPcbComponents(PcbDocList : TStringList);
 var
   i                        : integer;
   componentIdx             : integer;
   board                    : IPcb_Board;
   componentIterator        : IPcb_iterator;
   component                : IPcb_component;
   selectedPcbComponents    : TStringList;
begin

  selectedPcbComponents := TStringList.Create;

  for i := 0 to PcbDocList.Count - 1 do
  begin
      board := PcbServer.LoadPCBBoardByPath(PcbDocList[i]);
      if (board <> nil) then
      begin
        componentIterator := board.BoardIterator_Create;
        componentIterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        component := componentIterator.FirstPCBObject;
        while (component <> nil) do
        begin
          if (component.selected) then
          begin
            selectedPcbComponents.Add(component.name.text);
          end;
          component := componentiterator.NextPcbObject;
        end;
      end;
  end;

  for i := 0 to PcbDocList.Count - 1 do
  begin
      board := PcbServer.LoadPCBBoardByPath(PcbDocList[i]);
      if (board <> nil) then
      begin
        componentIterator := board.BoardIterator_Create;
        componentIterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        PCBServer.PreProcess;
        component := componentIterator.FirstPCBObject;
        while (component <> nil) do
        begin
          if (not component.selected) then
          begin
            componentIdx := selectedPcbComponents.IndexOf(component.name.text);
            if (componentIdx <> -1) then
            begin
              board.RemovePCBObject(component);
            end;
          end;
          PCBServer.SendMessageToRobots(component.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);
          component := componentiterator.NextPcbObject;
        end;
        PCBServer.PostProcess;
        Client.SendMessage('PCB:Zoom', 'Action=Redraw' , 255, Client.CurrentView);
      end;
  end;

  selectedPcbComponents.Free;
end;

procedure Run();
var
   project : IProject;
   i       : integer;
   doc     : IDocument;

   schDocList : TStringList;
   pcbDocList : TStringList;

   selectedSchComponentList : TStringList;
   selectedPcbComponentList : TStringList;
begin
    schDocList := TStringList.Create;
    pcbDocList := TStringList.Create;

    // Get current project
    project := GetWorkspace.DM_FocusedProject;

    // List all schematic and PCB documents of current project
    for i := 0 to project.DM_LogicalDocumentCount - 1 do
    begin
      doc := project.DM_LogicalDocuments(i);
      if doc.DM_DocumentKind = 'SCH' then schDocList.Add(doc.DM_FullPath);
      if doc.DM_DocumentKind = 'PCB' then pcbDocList.Add(doc.DM_FullPath);
    end;

    // List all selected SCH and PCB components
    selectedSchComponentList := ListSelectedSchComponents(schDocList);
    selectedPcbComponentList := ListSelectedPcbComponents(pcbDocList);

    // Sort the both lists by designator
    sortList(selectedSchComponentList);
    sortList(selectedPcbComponentList);

    if (checkListsCorrespondence(selectedSchComponentList, selectedPcbComponentList)) then  // Check if selected PCB components correspond to their SCH instances
    begin
      reannotatePcbComponents(pcbDocList, selectedSchComponentList, selectedPcbComponentList); // Copy designators from SCH components to corresponding PCB components
      deleteDuplicatesOfSelectedPcbComponents(pcbDocList);
    end
       else
    begin
      ShowMessage('Please, select the same components on the SCH and the PCB before running this script.');
    end;
    schDocList.Free;
    pcbDocList.Free;
    selectedSchComponentList.Free;
    selectedPcbComponentList.Free;
end;
