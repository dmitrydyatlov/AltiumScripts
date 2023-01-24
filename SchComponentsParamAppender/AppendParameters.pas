var

   components                   : TList;
   componentClasses             : TStringList;
   componentParametersLists     : TList;

procedure loadComponentsParametersIni(iniFilename : string);
var
   i      : integer;
   Ini    : TIniFile;
   val    : TStringList;
begin
     if (componentClasses <> nil) then
     begin
          componentClasses := TStringList.Create;
          componentParametersLists := TList.Create;
     end
        else
     begin
          componentClasses.Clear;
          componentParametersLists.Clear;
     end;

     Ini := TIniFile.Create(iniFileName);
     Ini.ReadSections(componentClasses);
     for i := 0 to componentClasses.Count - 1 do
     begin
          val := TStringList.Create;
          Ini.ReadSectionValues(componentClasses[i], val);
          componentParametersLists.Add(val);
     end;
     ShowComponentParametersToAdd(componentClasses, componentParametersLists);
end;


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

function fillSchFileList : TStringList;
var
 project : IProject;
 doc     : IDocument;
 sheet   : ISch_sheet;
 i       : integer;
 list    : TStringList;
begin
    list := TStringList.Create;
    project := GetWorkspace.DM_FocusedProject;
    for i := 0 to project.DM_LogicalDocumentCount - 1 do
    begin
      doc := project.DM_LogicalDocuments(i);
      if doc.DM_DocumentKind ='SCH' then
      begin
           sheet := SchServer.LoadSchDocumentByPath(doc.DM_FullPath);
           if (sheet <> nil) then
           begin
             list.Add(doc.DM_FullPath);
           end;
      end;
    end;
    result := list;
end;


procedure addParametersToComponent(component : ISch_component);
var


  parameter                          : ISch_parameter;
  parameterIterator                  : ISch_iterator;
  i, j                               : integer;
  param                              : ISch_Parameter;
  desPrefix                          : String;
  componentExistingparameterNames    : TStringList;
  idx                                : integer;
  step                               : integer;
begin
         // Extracting the existing parameters of the component
         parameterIterator := component.SchIterator_Create;
         parameterIterator.AddFilter_ObjectSet(MkSet(eParameter));
         parameter := parameterIterator.FirstSchObject;
         componentExistingParameterNames := TStringList.Create;
         while (parameter <> nil) do
         begin
              componentExistingParameterNames.Add(parameter.name);
              parameter := parameterIterator.NextSchObject;
         end;

         desPrefix := extractPrefixFromDesignator(component.Designator.Text);
         for step := 0 to 1 do
         begin
                case step of
                     0 : idx := componentClasses.IndexOf(desPrefix);                // Define parameter set by designator prefix
                     1 : idx := componentClasses.IndexOf('All');                    // Define common parameter set
                end;
                if (idx <> -1) then
                begin
                       for j := 0 to componentParametersLists[idx].Count - 1 do
                       begin
                            if (componentExistingParameterNames.IndexOf(componentParametersLists[idx].Names[j]) = -1) then
                            begin
                                 componentExistingParameterNames.Add(componentParametersLists[idx].Names[j]);
                                 param := SchServer.SchObjectFactory(eParameter, eCreate_Default);
                                 param.Name := componentParametersLists[idx].Names[j];
                                 param.ShowName := false;
                                 param.text := componentParametersLists[idx].ValueFromIndex(j);
                                 param.isHidden := true;
                                 param.Location := Point(Component.Location.X, Component.Location.Y + DxpsToCoord(0.1));
                                 component.AddSchObject(param);
                                 SchServer.RobotManager.SendMessage(  component.I_ObjectAddress,
                                                                      c_BroadCast,
                                                                      SCHM_PrimitiveRegistration,
                                                                      param.I_ObjectAddress);
                            end
                       end;
                end;
         end;
         componentExistingParameterNames.Free;
end;

procedure addParametersToSheet(  componentIterator : ISch_iterator;
                                 componentClasses : TStringList;
                                 componentParametersLists : TList;
                                 selectedOnly             : boolean);
var

  component                          : ISch_component;
begin
    component := componentIterator.FirstSchObject;
    while (component <> nil) do  // Iterate all schematic components
    begin
         if (selectedOnly and not component.selection) then
         begin
           component := componentiterator.NextSchObject;
           continue;
         end;
         addParametersToComponent(component);
         component := componentiterator.NextSchObject;
    end;
end;


procedure AddParametersToProjectDocuments (
                             componentClasses         : TStringList;
                             componentParametersLists : TList;
                             selectionOnly            : boolean;
                        );
var
  projectDocuments : TStringList;
  sheet                              : ISch_sheet;
  componentIterator                  : ISch_iterator;
  i, j                               : integer;
begin
  projectDocuments := fillSchFileList();
  for i := 0 to projectDocuments.Count - 1 do //
  begin
    sheet := SchServer.LoadSchDocumentByPath(projectDocuments[i]);
    SchServer.ProcessControl.PreProcess(sheet, '');
    componentIterator := sheet.SchIterator_Create;
    componentIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
    addParametersToSheet(componentIterator, componentClasses, componentParametersLists, selectionOnly);
    SchServer.ProcessControl.PostProcess(sheet, '');
  end;
  projectDocuments.Free;
end;

procedure AddParameters(selectionOnly : boolean);
var
    CurrentLib      : ISch_Lib;
    LibraryIterator : ISch_Iterator;
    AnIndex         : Integer;
    LibComp         : ISch_Component;
    projectDocuments : TStringList;
begin
    If SchServer = Nil Then Exit;
    CurrentLib := SchServer.GetCurrentSchDocument;

    If CurrentLib = Nil Then Exit;

    // Check if the document is a schematic library
    If CurrentLib.ObjectID = eSchLib Then
    Begin

      if (selectionOnly) then
      begin
        LibComp := CurrentLib.CurrentSchComponent;
        addParametersToComponent(LibComp);
      end
         else
      begin
        LibraryIterator := CurrentLib.SchLibIterator_Create;
        LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
        SchServer.ProcessControl.PreProcess(CurrentLib, '');
        addParametersToSheet(LibraryIterator, componentClasses, componentParametersLists, false);
        SchServer.ProcessControl.PostProcess(CurrentLib, '');
      end;

    End
     else // If current document is not a schematic library
    Begin
       addParametersToProjectDocuments (componentClasses, componentParametersLists, selectionOnly);
    End;
end;


procedure ListComponentParameters(componentIterator : ISch_iterator);
var
  paramList                          : TStringList;
  component                          : ISch_component;
  parameter                          : ISch_parameter;
  parameterIterator                  : ISch_iterator;
  i, j                               : integer;
  param                              : ISch_Parameter;
  desPrefix                          : String;

  idx                                : integer;
  step                               : integer;
begin
    component := componentIterator.FirstSchObject;
    while (component <> nil) do
    begin
         if (component.selection) then
         begin
           paramList := TStringList.Create;
           paramList.Add('UniqueId=' + component.UniqueId);
           parameterIterator := component.SchIterator_Create();
           parameterIterator.AddFilter_ObjectSet(MkSet(eParameter));
           param := parameterIterator.FirstSchObject();
           while (param <> nil) do
           begin
                paramList.Add(param.Name + '=' + param.Text);
                param := parameterIterator.NextSchObject();
           end;
           components.Add(paramList);
         end;
         component := componentiterator.NextSchObject;
    end;
   DisplayComponents(components);
end;
