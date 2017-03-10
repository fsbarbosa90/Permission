#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRT99A01 ºAutor ³Fernando Barbosa	      Data ³  01/02/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de acesso a rotinas, permite liberar ou bloquear  º±±
±±º          ³ acessos, de forma periodica, ou definitiva                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

#Define POSCAMPO  2
#Define TAMUSER   6
#Define TAMFUNCAO 10
#Define CLRF      CHR(13)+CHR(10)

User Function PRT99A01()
************************
Local aColors		:= {}

Private cAlias       	:= "Z04"
Private aRotina 	:= {}
Private cCadastro 	:= "Controle de acesso a funções"

aAdd(aColors,    { "Z04->Z04_MSBLQ == '1'" , "DISABLE"    	})
aAdd(aColors,    { "Z04->Z04_TIPO  == 'L'" , "OK_15"    	})
aAdd(aColors,    { "Z04->Z04_TIPO  == 'B'" , "BR_CANCEL"    	}) 

aAdd(aRotina, {"&Pesquisar" , "AxPesqui"     , 0, 1})
aAdd(aRotina, {"&Visualizar", "U_CAD99A01"   , 0, 2})
aAdd(aRotina, {"&Incluir"   , "U_CAD99A01"   , 0, 3})
aAdd(aRotina, {"&Alterar"   , "U_CAD99A01"   , 0, 4})
aAdd(aRotina, {"&Excluir"   , "U_CAD99A01"   , 0, 5}) 
aAdd(aRotina, {"&Legenda"   , "U_LEG99A01"   , 0, 6}) 

mBrowse(06,01,22,75,cAlias,,,,,,aColors)

Return

// +---------+
// | LEGENDA |
// +---------+
User Function LEG99A01()
************************
Local aLegenda := {}

aAdd(aLegenda,    { "OK_15"	, "Liberar acesso"   	})
aAdd(aLegenda,    { "BR_CANCEL"	, "Bloquear acesso"  	})
aAdd(aLegenda,    { "DISABLE"	, "Desativado"		})

BrwLegenda('Legenda','Legendas',aLegenda)

Return

// +--------------------------------+
// | REALIZA MANUTENCAO NO CADASTRO |
// +--------------------------------+			
User Function CAD99A01(cAlias, nReg, nOpcao)
******************************************** 
Local cFiltro		:= ""
Local nHeader		:= 0
Local nColsAtu		:= 0
Local cField		:= ""

Private nOpc 		:= nOpcao
Private aHeader		:= apBuildHeader("Z05")
Private aCols		:= {}

Private INCLUI	:= nOpc == 3
Private ALTERA	:= nOpc == 4
Private EXCLUI	:= nOpc == 5

// +--------------------------------------------------------+
// | NOTIFICA AO USUARIO QUE O PARAMENTRO ESTA DESABILITADO |
// +--------------------------------------------------------+
If !IsUtilized()
	MsgInfo("Atenção rotina de controle de acesso está desabilitada. Favor verificar o parâmetro 'PRT_CTRLRT'.")
EndIf

CursorWait() 

nHeader := Len(aHeader)

RegToMemory("Z04",nOpc == 3) 

// +---------------+
// | CARREGA ACOLS |
// +---------------+
cFiltro := xFilial("Z05") + M->Z04_ROTINA
Z05->(dbSetOrder(1))
Z05->(dbSeek(cFiltro))
While !Z05->(Eof()) .And. Z05->(Z05_FILIAL + Z05_ROTINA) == cFiltro
	
	aAdd(aCols,Array(nHeader + 1))
	nColsAtu := Len(aCols)
	
	For i := 1 To nHeader
		cField	:= AllTrim(aHeader[i, POSCAMPO])
		
		If cField $ "Z05_NOME"
			aCols[nColsAtu,i] := UsrFullName(Z05->Z05_USER)
		Else
			aCols[nColsAtu,i] := Z05->&(cField)
		EndIf
			
	Next i
	
	aCols[nColsAtu, nHeader + 1] := .F.
	
	Z05->(dbSkip())
EndDo

CursorArrow()	

// +-------------------------------------------------------------------------+
// | VALIDA SE NÃO TEM NADA, PERGUNTA SE DESEJA RECARREGAR TODOS OS USUARIOS |
// +-------------------------------------------------------------------------+
If Len(aCols) == 0 .And. MsgNoYes("Deseja carregar todos os usuários?","Usuários")
	Processa({||aCols  := LoadUser()}, "Aguarde...", "Aguarde, carregando...")
EndIf

If Modelo3(cCadastro,"Z04","Z05",,"AllwaysTrue()","U_TOK99A01()",nOpc,nOpc,"AllwaysTrue()") .And. nOpc != 2 
	
	CursorWait() 
	
	Begin Transaction
	
		// +---------------------------+
		// | APAGA OS DADOS ANTERIORES |
		// +---------------------------+
		If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5
			MsgRun("Aguarde..., atualizando informações",cCadastro,{|| DelData()} )
		EndIf
		
		If nOpc == 3 .Or. nOpc == 4
			MsgRun("Aguarde..., gravando informações",cCadastro,{|| RecData()} )
			
		ElseIf nOpc == 5
			RecLock("Z04",.F.)
			Z04->(dbDelete())		
			Z04->(MsUnLock())		
		EndIf
	
	End Transaction
	
	CursorArrow()
		
Endif

Return			

// +-------------------------+
// | GRAVA OS DADOS NO BANCO |
// +-------------------------+
Static Function RecData()
*************************
Local nContZ04 	:= fCount()
Local cField	:= ""
Local nCols	:= Len(aCols)
Local nHeader	:= Len(aHeader)
	
RecLock("Z04",(nOpc == 3))
Z04->Z04_FILIAL := xFilial("Z04")

For i := 1 To nContZ04
	cField := "M->" + Alltrim(FieldName(i))
	If AllTrim(cField) != "M->Z04_FILIAL" .And. Type(cField) != "U"
		FieldPut(i,&(cField))
	EndIf
Next i

Z04->(MsUnLock())

For j := 1 To nCols 

	If !aCols[j,nHeader+1]
	
		RecLock("Z05",.T.)		
		Z05->Z05_FILIAL := xFilial("Z05")	
		Z05->Z05_ROTINA := M->Z04_ROTINA	
		For k := 1 To nHeader			
			Z05->&(aHeader[k,POSCAMPO]) := aCols[j,k]			
		Next k		
		Z05->(MsUnLock()) 
	
	EndIf

Next j
	
Return

// +----------------------------+
// | APAGA OS REGISTRO DO ACOLS |
// +----------------------------+
Static Function DelData()
*************************
Local cFiltro := xFilial("Z05") + M->Z04_ROTINA

Z05->(dbSetOrder(1))
Z05->(dbSeek(cFiltro))
While !Z05->(Eof()) .And. Z05->(Z05_FILIAL + Z05_ROTINA) == cFiltro

	RecLock("Z05",.F.)
	Z05->(dbDelete())
	Z05->(MsUnLock())
		
	Z05->(dbSkip())
EndDo

Return

/*------------------------------------+
| FUNCAO PARA VALIDAR SE ESTA TUDO OK |
+-------------------------------------+*/
User Function TOK99A01()
************************
Local lRet := .T.

Processa({||lRet  := Validar()},"Aguarde...","Aguarde, validando...")

Return lRet


// +------------------------------------------------------------------+
// | FUNCAO PARA EXECUTAR A VALIDACAO PARA MOSTRAR EM TELA O PROGRESS |
// +------------------------------------------------------------------+
Static Function Validar()
*************************
Local lRet 	:= .T.
Local nCont	:= 0 
Local nCols	:= Len(aCols)
Local nHeader 	:= Len(aHeader)
Local nPosUser	:= GdFieldPos("Z05_USER",aHeader)
Local nPosDtIni	:= GdFieldPos("Z05_DTINI",aHeader)
Local nPosDtFim	:= GdFieldPos("Z05_DTFIM",aHeader)
Local nPosHrIni	:= GdFieldPos("Z05_HRINI",aHeader)
Local nPosHrFim	:= GdFieldPos("Z05_HRFIM",aHeader)

ProcRegua(nCols)

For nX := 1 To nCols

	If !aCols[nX,nHeader+1]

		// +---------------------------------------------------------+
		// | VALIDA SE TODOS OS CAMPOS OBRIGATORIO ESTÃO PREENCHIDOS |
		// +---------------------------------------------------------+
		If !U_ChkObgCl(aHeader,aCols[nX],"Z05")
			lRet := .F.
			
		// +------------------+
		// | DATA DE VIGENCIA |
		// +------------------+			
		ElseIf aCols[nX,nPosDtIni] >  aCols[nX,nPosDtFim]
			MsgStop("Data inicial na linha " + cValToChar(nX) + " está maior que a data final!")
			lRet := .F.
			
		// +------------------+
		// | HORA DA VIGENCIA |
		// +------------------+	
		ElseIf aCols[nX,nPosHrIni] >  aCols[nX,nPosHrFim]
			MsgStop("Hora inicial na linha " + cValToChar(nX) + " está maior que a Hora final!")
			lRet := .F.
			
		// +------------------------------------------------------------+
		// | VERIFICA SE FOI INCLUIDO ALGUM USER QUE TEM PERMISSAO FULL |
		// +------------------------------------------------------------+
		ElseIf AllTrim(aCols[nX,nPosUser]) $ AccessFull()
			MsgStop("Não é permitido incluir usuários com permissão FULL. Linha " + cValToChar(nX))
			lRet := .F.		
		Else
			
			// +-----------------------------------+
			// | VERIFICA SE TEM USUARIO DUPLICADO |
			// +-----------------------------------+
			For nZ := 1 To nCols
			
				If !aCols[nZ,nHeader + 1] .And. nZ != nX 
					
					If AllTrim(aCols[nZ,nPosUser]) == AllTrim(aCols[nX,nPosUser])
						MsgStop("Usuário duplicado na linha " + cValToChar(nX) + " e " + cValToChar(nZ))	
						lRet := .F.
						Exit 
					
					EndIf
					
				EndIf	
						
			Next nZ
					
		EndIf		
		
		// +----------------------------+
		// | SE DEU ERRADO, PARA O LOOP |
		// +----------------------------+
		If !lRet			
			Exit
		EndIf
		
		nCont++
	
	EndIf	
	
	IncProc("Processando..." + Transform(nX * 100 / nCols,"@E 99999%") + " Concluído")    	
	
Next nX

// +-----------------------------------------------+
// | VALIDA SE PELO MENOS UM USUARIO FOI INFORMADO |
// +-----------------------------------------------+
If lRet .And. nCont <= 0
	MsgStop("Nenhum usuário foi informado")
	lRet := .F.
EndIf

Return lRet

// +-------------------------------------------------------------------------------+
// | CARREGA TODOS OS USUÁRIOS DO SISTEMA, PARA PREENCHER AUTOMATICAMENTE O BROWSE |
// +-------------------------------------------------------------------------------+
Static Function LoadUser()
**************************
Local cUserNew	:= ""
Local aColsLoad := {}
Local nHeader	:= Len(aHeader)
Local nAcolsAtu	:= 0
Local aUsers	:= AllUsers()
Local nUsers	:= Len(aUsers)
Local nPosUser	:= GdFieldPos("Z05_USER",aHeader)
Local nPosNome	:= GdFieldPos("Z05_NOME",aHeader)

ProcRegua(nUsers)

For i := 1 To nUsers

	cUserNew := AllTrim(aUsers[i,1,1])
	
	/*-------------------------------------------+
	| NÃO INCLUI USUARIOS QUE TEM PERMISSÃO FULL |
	+--------------------------------------------+*/
	If !(cUserNew $ AccessFull())
	
		aAdd(aColsLoad, Array(nHeader +1))
		nAcolsAtu := Len(aColsLoad)
		
		aColsLoad[nAcolsAtu, nPosUser] 	:= cUserNew
		aColsLoad[nAcolsAtu, nPosNome] 	:= aUsers[i,1,4]
		
		For j := 1 To nHeader
			
			If !(AllTrim(aHeader[j,POSCAMPO]) $ "Z05_USER|Z05_NOME")
				aColsLoad[nAcolsAtu, j] := U_GetX3Prd(aHeader[j,POSCAMPO])
			EndIf	
		Next j 
		
		aColsLoad[nAcolsAtu,  nHeader +1] 	:= .F.
		
	EndIf
	
	IncProc("Processando..." + Transform(i * 100 / nUsers,"@E 99999%") + " Concluído")  

Next i

Return aColsLoad

// +-----------------------------------------+
// | VERIFICA OS USUARIOS COM PERMISSAO FULL |
// +-----------------------------------------+
Static Function AccessFull()
****************************
Return AllTrim(GetMv("PRT_ROTFUL"))

// +----------------------------------+
// | VERIFICA SE A FUNCAO ESTA EM USO |
// +----------------------------------+
Static Function IsUtilized()
****************************
Return GetMv("PRT_CTRLRT") 

// +--------------------------------------------------------------------+
// | VERIFICA SE A FUNCAO POSSUI CONTROLE, E SE O USUARIO TEM PERMISSAO |
// +--------------------------------------------------------------------+
User Function ACC99A01(cFuncaoSol,cUserSol, lShowMsg)
*****************************************************
Local lLocaliz		:= .F.
Local lRet 		:= .T.
Local dDateAtu 		:= Date()
Local cTimeAtu		:= Time()
Local aArea		:= GetArea()

Default cFuncaoSol	:= ""
Default cUserSol	:= __cUserId
Default lShowMsg	:= .T.

// +---------------------------------------------------------------------------------------+
// | VERIFICA SE INFORMOU OS PARAMETRO, E SE NAO ACESSO FULL E SE A ROTINA ESTA HABILITADA |
// +---------------------------------------------------------------------------------------+
If IsUtilized() .And. !Empty(cUserSol) .And. !Empty(cFuncaoSol) .And. !(AllTrim(cUserSol)$AccessFull())

	// +---------------------------------+
	// | AJUSTA OS TAMANHO DAS VARIAVEIS |
	// +---------------------------------+
	cFuncaoSol 	:= PadR(AllTrim(StrTran(StrTran(cFuncaoSol,"(",""),")","")), TAMFUNCAO) 
	cUserSol	:= PadR(AllTrim(cUserSol), TAMUSER) 
	
	Z04->(dbSetOrder(1))
	If Z04->(dbSeek(xFilial("Z04") + cFuncaoSol)) .And. AllTrim(Z04->Z04_MSBLQ) != '1'
	
		// +--------------------------------------------------+
		// | VERIFICA SE O USUARIO ESTA INFORMADO NO CADASTRO |
		// +--------------------------------------------------+
		Z05->(dbSetOrder(1))
		lLocaliz := (Z05->(dbSeek(xFilial("Z05") + cFuncaoSol + cUserSol)) .And. AllTrim(Z05->Z05_MSBLQ) != '1' .And. ;
		(Z05->Z05_DTINI <= dDateAtu .And. Z05->Z05_DTFIM >= dDateAtu) .And. (Z05->Z05_HRINI <= cTimeAtu .And. Z05->Z05_HRFIM >= cTimeAtu))
		
		// +------------+
		// | LIBERATIVO |
		// +------------+
		If AllTrim(Z04->Z04_TIPO) == "L" .And. !lLocaliz
			lRet := .F.
		
		// +------------+
		// | RESTRITIVO |
		// +------------+
		ElseIf AllTrim(Z04->Z04_TIPO) == "B" .And. lLocaliz	
			lRet := .F.
			
		EndIf
		
		// +----------------------------------------------------+
		// | VALIDA SE TEM PERMISSAO, CASO NÃO EXIBE A MENSAGEM |
		// +----------------------------------------------------+		 
		If !lRet .And. lShowMsg			
			Help(" ",1,"ACC99A01",,Upper("Usuário sem permissão para acessar a rotina de " + CLRF + CLRF + AllTrim(Z04->Z04_DESCRI)) +".",2,1)
		EndIf	
	
	EndIf

EndIf 

RestArea(aArea)

Return lRet

// +---------------------------------------------------------------------------------------------------------------------+
// | FUNCAO PARA VALIDAR SE TODOS OS CAMPOS FORAM PRECHIDOS CORRETAMENTE DENTRO DE UMA ACOLS PASSANDO OS ARRAYS DA LINHA |
// +---------------------------------------------------------------------------------------------------------------------+
User Function ChkObgCl(aHeader,aCols,cAlias)
********************************************
Local lRet      := .T.
Local aAreaX3   := SX3->(GetArea()) 
 
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(Eof()) .And. AllTrim(SX3->X3_ARQUIVO) == cAlias 
   If  X3Uso(SX3->X3_USADO) .And. X3Obrigat(SX3->X3_CAMPO) .And. Empty(aCols[GdFieldPos(AllTrim(SX3->X3_CAMPO),aHeader)])	
   	   MsgStop("Favor informar todos os campos obrigatórios. Campo "+AllTrim(SX3->X3_CAMPO)+" está em branco.")
   	   lRet := .F.
   	   exit
   EndIf	
   SX3->(dbSkip())
EndDo

RestArea(aAreaX3)

Return lRet

// +-------------------------------------+
// | PEGA O INICIALIZADO PADRÃO DO CAMPO |
// +-------------------------------------+
User Function GetX3Prd(cCampo)
******************************
Local xDefault	 
Local aAreaSX3 := SX3->(GetArea()) 

SX3->(dbSetOrder(2))
If SX3->(dbSeek(cCampo)) .And. !Empty(AllTrim(SX3->X3_RELACAO))
	xDefault :=  &(AllTrim(SX3->X3_RELACAO))
EndIf

RestArea(aAreaSX3)

Return xDefault

// +-------------------------------+
// | RETORNA A DESCRICAO DA FUNCAO |
// +-------------------------------+*/ 
User Function DescName(cFuncao)
*******************************
Local cName	:= ""
Local oFuncao 	:= NameFun():New()

Default cFuncao := ""

CursorWait()

oFuncao:SetFuncao(cFuncao)

If oFuncao:Search()
	cName := oFuncao:GetName()
Else
	MsgStop(oFuncao:getWarnning())
EndIf

CursorArrow()

Return cName

