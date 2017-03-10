# Controle de permissão a funções no prothues em ADVPL
  Controle de permissão a funções padrão e customizadas de forma mais pratica no protheus na linguagem ADVPL



# Objetivo
  Essa rotina tem por objetivo, controlar de forma mais pratica, os acessos de usuários a funções tanto padrão como customizadas, através do menu.

#Atenção
  Muito cuidado ao querer utilizar os fontes em seu projeto, pois ao importar os dados, ou até mesmo os sx's, cuidado para não subscrever o que já tem pronto sem seu ERP. Sempre verifique antes de fazer qualquer procedimento.

#Observações

* INFORMAÇÕES IMPORTANTES ABAIXO:

    1) Não crie compatibilizadores, para criação de campos, pois isso depende da disponibilidade de tabela de cada usuário.
    
    2) A leitura dos arquivos .XNU, está sendo somente dos que estão na pasta system, caso desejar modificar os caminhos de leitura para outra(s) pasta(s), basta modificar a classe NameFun, que está no fonte NameFun.PRW. Isso é exclusivo de cada base, pois cada um configura da forma que achar melhor, por enquanto só pega o que está no padrão(SYSTEM).

#Aplicação
  Compile todos os três fontes (CHKEXEC.prw,NameFun.prw,PRT99A01.prw), e crie os dados no dicionário do Protheus, iguais os sx's do projeto.

  Depois de feito isso, basta chamar a função no menu do modulo de sua preferencia, no meu caso eu coloquei no 99.

				<MenuItem Status="Enable">
					<Title lang="pt">Lib/Blq de Rotinas</Title>
					<Title lang="es">Lib/Blq de Rotinas</Title>
					<Title lang="en">Lib/Blq de Rotinas</Title>
					<Function>PRT99A01</Function>
					<Type>03</Type>
					<Access>xxxxxxxxxx</Access>
					<Module>05</Module>
					<Owner>2</Owner>
					<KeyWord>
						<KeyWord lang="pt"></KeyWord>
						<KeyWord lang="es"></KeyWord>
						<KeyWord lang="en"></KeyWord>
					</KeyWord>
				</MenuItem>	
        
#Utilização     

* Além da exclusão da permissão, existem outras formas de ativar ou desativar e dar manutenção a permissão.

  1) A rotina permite dois tipos de controles (Tipo de Cont = Z04_TIPO):
    
      Liberativa: Libera acesso a função somente aos usuários que estão cadastrados, e bloqueia o acesso a todos os que não têm cadastro.
  
      Restritiva: Bloqueia o acesso à função dos usuários cadastrados, e libera para todos os que não têm cadastro na rotina.
   
  2) Desabilitar/habilitar rotina por completo:    

      É possível desabilitar/habilitar a rotina para não executar mais nenhuma validação, basta alterar o parâmetro PRT_CTRLRT, para false, e a rotina ficara desabilitada/habilitada até a próxima alteração.

  3) Desabilitar/habilitar somente uma função:

      Caso queira desabilitar a permissão de uma função somente. Basta editar a permissão e alterar o campo <b>Bloqueado<u>(Z04_MSBLQ)</u></b> para <b><i>1=Sim</i></b>, e a validação não será mais executada para aquela função.

  4) Desabilitar/habilitar somente um usuário para uma determinada validação de permissão:
      
      É possível remover o usuário de uma determinada permissão, de forma muita simples, alterando o campo <b>Bloqueado(Z05_MSBLQ)</b> para <i>1=Sim</i>, desta forma rotina irá tratar que o usuário não tem cadastro na permissão.
      
  5) Controle de permissão por período:
      
      Caso você deseje que uma permissão seja valida para um determinado usuário somente por um período de tempo, enquanto ele cobre as ferias para uma determinada pessoa, por exemplo, basta informar nesse usuário a data/hora de inicio e a data/hora final, e desta forma a permissão ou bloqueio dele ira valer somente para aquele período cadastrado.
      
      
# Melhorias futuras
  
  1) Criar controle de data/hora inicio/fim por função, e não somente por usuários.
  2) Criar uma opção de copiar permissão, fazer um clone de usuário para outro, com todos os acessos e bloqueado iguais a de outro usuário.
  
  
  
*** Nunca execute nenhum procedimento se não tem certeza de como aplica-lo, sempre solicite ajuda a um profissional qualificado, para melhor solução!
