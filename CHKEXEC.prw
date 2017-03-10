#Include 'Protheus.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CHKEXEC     �Autor  �Fernando Barbosa � Data �  12/02/2016  ���
�������������������������������������������������������������������������ͺ��
���Desc.     �PE EXECUTADO SEMPRE QUE UMA FUNCAO � CHAMADA PELO MENU	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function CHKEXEC()
*********************** 
Local lRet := .T.

// +--------------------------------------+
// | VERIFICA SE TEM PERMISSAO DE ACESSO  |
// +--------------------------------------+
If !U_ACC99A01(ParamIXB)
	lRet := .F.	
EndIf

Return lRet