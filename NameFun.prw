#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NameFun ºAutor ³Fernando Barbosa	      Data ³  01/02/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe responsavel por retornar o nome da funcao, no caso   º±±
±±º          ³ a descricao da mesma			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

#Define NAMEMAX 10
#Define DIR	'\system\'
#Define EXT	'XNU'

Class NameFun
*************
	
	Data Funcao
	Data Nome
	Data Warnning
	Data Ret
	
	Method New()
	Method Search()
	
	Method SetFuncao(cFuncao)
	
	Method GetName() 
	Method GetWarnning()
	
	//+------------------+
	//| INTERNOS/PRIVADO |
	//+------------------+
	Method __Valida() 

EndClass


//+---------+
//|CONTRUTOR|
//+---------+
Method New() Class NameFun
**************************
Self:Funcao 	:= ""
Self:Nome 	:= ""
Self:Warnning	:= ""
Self:Ret	:= .F.
Return Self


//+----------------+
//| SETAR A FUNCAO |
//+----------------+
Method SetFuncao(cFuncao) Class NameFun
****************************************
Default cFuncao := ""
Self:Funcao := AllTrim(cFuncao) 
Return


//+-----------------------+
//| PEGA O NOME DA FUNCAO |
//+-----------------------+
Method GetName() Class NameFun
******************************
Return IIF(Self:Ret , Self:Nome, "")


//+------------------------+
//| PEGA A MESAGEM DE ERRO |
//+------------------------+
Method GetWarnning() Class NameFun
**********************************
Return IIF(!Self:Ret , Self:Warnning, "")


//+------------------------+
//| BUSCA O NOME DA FUNCAO |
//+------------------------+
Method Search() Class NameFun
***************************** 
Local aFiles 	:= {}
Local cLinha	:= ""
Local cFile	:= ""
Local nCont	:= 0 
Local cProg	:= ""
Local cNome	:= ""

Self:Ret  	:= .F.
Self:Nome 	:= ""
Self:Warnning 	:= "Funcao " + AllTrim(Self:Funcao) + " não foi localizada"

If Self:__Valida()
	
	aFiles := Directory(DIR + "*." + EXT)
	nCont  := Len(aFiles)
	
	//+-------------------------------+	
	//| VALIDA SE ACHOU ALGUM ARQUIVO |
	//+-------------------------------+	
	If nCont > 0
		
		For nF := 1 To nCont	
			
			cFile 		:= DIR + AllTrim(aFiles[nF,1])
			cProg 		:= ""
			cNome 		:= ""
			Self:Ret  	:= .F.
							
			If File(cFile)	
					
				FT_FUSE(cFile)
				FT_FGOTOP()
				
				While !FT_FEOF()					
					cLinha := AllTrim(StrTran(FT_FREADLN(),CHR(9)))		
					
					// +-------------+
					// | PEGA O NOME |
					// +-------------+
					If At('<Title lang="pt">',cLinha) > 0
						cNome := SubStr(cLinha, At(">", cLinha) + 1, Rat("<", cLinha) - At(">", cLinha) -1 )
					EndIf
					
					//+-------------------------+					
					//| VALIDA O NOME DA FUNCAO |
					//+-------------------------+	
					If At("<Function>", cLinha) > 0					
						cProg := SubStr(cLinha, At(">",cLinha)+1, Rat("<",cLinha) - At(">",cLinha) -1 )
						cProg := IIF(AllTrim(Upper(cProg)) == AllTrim(Upper(Self:Funcao)) , cProg, "") 					
					EndIf					
					
					If !Empty(cProg) .And. !Empty(cNome)
						Self:Ret  	:= .T.
						Self:Nome 	:= AllTrim(cNome)
						Exit
					EndIf		 	
									
					FT_FSKIP()					 
				EndDo
				
				FT_FUSE()			
			
			EndIf	
			
			If Self:Ret
				Self:Warnning := ""  
				Exit
			EndIf	
			
		Next nf		
		 	
	Else
		Self:Warnning := "Arquivos de funções não localizado"
			
	EndIf

EndIf 

Return Self:Ret


//+-------------------------------+
//| REALIZA A VALIDACAO DOS DADOS |
//+-------------------------------+
Method __Valida() Class NameFun
*******************************
Local lRet := .T.

If Empty(Self:Funcao)
	Self:Warnning := "Funcao não foi informada"
	lRet := .F.
	
ElseIf  Len(AllTrim(Self:Funcao)) > NAMEMAX
	Self:Warnning := "Funcao não pode conter mais de " + cValToChar(NAMEMAX) + " caracteres"
	lRet := .F.
	
EndIf
 
Return lRet
