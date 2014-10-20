package PT::PostalCode;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	code_is_from_area code_is_from_subarea code_is_from
	range_from_subarea
	code_is_valid areas_of_code subareas_of_code
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	code_is_from_area code_is_from_subarea code_is_from
	range_from_subarea
	code_is_valid areas_of_code subareas_of_code
);

our $VERSION = '0.01';

=head1 NAME

PT::PostalCode - Validates Portuguese Postal Codes

=head1 SYNOPSIS

  use PT::PostalCode;

  validate($postalcode);

  code_is_from_area($postalcode,$city);
  code_is_from_subarea($postalcode,$district);

  code_is_from($postalcode,$district,$city);

  range_from_subarea($district);

  code_is_valid($code);
  areas_of_code($code);
  subareas_of_code($code);

=cut

my %range;

BEGIN {
  %range = (

        'Santar�m' => {
          'Santar�m'			 => [ '2000', '2150' ],
          'Goleg�'			 => [ '2150', '2150' ],
          'Rio Maior'			 => [ '2040', '2040' ],
          'Cartaxo'			 => [ '2070', '2070' ],
          'Ma��o'			 => [ '6120', '6120' ],
          'Torres Novas'		 => [ '2350', '2354' ],
          'Salvaterra de Magos'		 => [ '2120', '2125' ],
          'Sardoal'			 => [ '2230', '2230' ],
          'Ferreira do Z�zere'		 => [ '2240', '2240' ],
          'Almeirim'			 => [ '2080', '2080' ],
          'Alpiar�a'			 => [ '2090', '2090' ],
          'Const�ncia'			 => [ '2250', '2250' ],
          'Vila Nova da Barquinha'	 => [ '2260', '2260' ],
          'Alcanena'			 => [ '2380', '2395' ],
          'Chamusca'			 => [ '2140', '2140' ],
          'Benavente'			 => [ '2120', '2890' ],
          'Entroncamento'		 => [ '2330', '2330' ],
          'Tomar'			 => [ '2300', '2305' ],
          'Coruche'			 => [ '2100', '2100' ],
          'Abrantes'			 => [ '2200', '2230' ],
          'Our�m'			 => [ '2435', '2495' ],
        },

        'Lisboa' => {
          'Lisboa'			 => [ '1000', '1998' ],
          'Odivelas'			 => [ '1675', '2675' ],
          'Cadaval'			 => [ '2550', '2550' ],
          'Mafra'			 => [ '2640', '2669' ],
          'Sintra'			 => [ '2605', '2749' ],
          'Alenquer'			 => [ '2580', '2581' ],
          'Arruda dos Vinhos'		 => [ '2630', '2630' ],
          'Azambuja'			 => [ '2050', '2065' ],
          'Sobral Monte Agra�o'		 => [ '2590', '2590' ],
          'Oeiras'			 => [ '1495', '2799' ],
          'Lourinh�'			 => [ '2530', '2530' ],
          'Amadora'			 => [ '2610', '2724' ],
          'Vila Franca de Xira'		 => [ '2600', '2626' ],
          'Cascais'			 => [ '2645', '2789' ],
          'Torres Vedras'		 => [ '2560', '2565' ],
          'Loures'			 => [ '1885', '2699' ],
        },

        'Ilha da Madeira' => {
          'Ponta do Sol'		 => [ '9360', '9360' ],
          'Calheta (Madeira)'		 => [ '9370', '9385' ],
          'Santana'			 => [ '9230', '9230' ],
          'Santa Cruz'			 => [ '9100', '9135' ],
          'S�o Vicente'			 => [ '9240', '9240' ],
          'Machico'			 => [ '9200', '9225' ],
          'Ribeira Brava'		 => [ '9350', '9350' ],
          'C�mara de Lobos'		 => [ '9030', '9325' ],
          'Funchal'			 => [ '9000', '9064' ],
          'Porto Moniz'			 => [ '9270', '9270' ],
        },

        '�vora' => {
          'Portel'			 => [ '7220', '7220' ],
          'Arraiolos'			 => [ '7040', '7040' ],
          '�vora'			 => [ '7000', '7200' ],
          'Estremoz'			 => [ '7100', '7100' ],
          'Vila Vi�osa'			 => [ '7160', '7160' ],
          'Viana do Alentejo'		 => [ '7090', '7090' ],
          'Vendas Novas'		 => [ '2965', '7080' ],
          'Redondo'			 => [ '7170', '7200' ],
          'Borba'			 => [ '7150', '7150' ],
          'Alandroal'			 => [ '7200', '7250' ],
          'Reguengos de Monsaraz'	 => [ '7200', '7200' ],
          'Mour�o'			 => [ '7240', '7240' ],
          'Montemor-o-Novo'		 => [ '7050', '7050' ],
          'Mora'			 => [ '7490', '7490' ],
        },

        'Leiria' =>  {
           '�bidos'			 => [ '2510', '2510' ],
           'Nazar�'			 => [ '2450', '2450' ],
           'Leiria'			 => [ '2400', '2495' ],
           'Castanheira de P�ra'	 => [ '3280', '3280' ],
           'Bombarral'			 => [ '2540', '2540' ],
           'Alvai�zere'			 => [ '3250', '3260' ],
           'Pombal'			 => [ '3100', '3105' ],
           'Peniche'			 => [ '2520', '2525' ],
           'Alcoba�a'			 => [ '2445', '2475' ],
           'Marinha Grande'		 => [ '2430', '2445' ],
           'Porto de M�s'		 => [ '2480', '2485' ],
           'Batalha'			 => [ '2440', '2495' ],
           'Ansi�o'			 => [ '3240', '3240' ],
           'Pedr�g�o Grande'		 => [ '3270', '3270' ],
           'Figueir� dos Vinhos'	 => [ '3260', '3260' ],
           'Caldas da Rainha'		 => [ '2500', '2500' ],
         },

         'Ilha das Flores' =>  {
           'Lajes das Flores'		 => [ '9960', '9960' ],
           'Santa Cruz das Flores'	 => [ '9970', '9970' ],
         },

         'Ilha do Pico' =>  {
           'Lajes do Pico'		 => [ '9930', '9930' ],
           'S�o Roque do Pico'		 => [ '9940', '9940' ],
           'Madalena'			 => [ '9950', '9950' ],
         },

         'Aveiro' =>  {
           'Mealhada'			 => [ '3050', '3050' ],
           'Ovar'			 => [ '3880', '3885' ],
           'Murtosa'			 => [ '3870', '3870' ],
           'Oliveira de Azemeis'	 => [ '3700', '3720' ],
           'Aveiro'			 => [ '3800', '3814' ],
           'Albergaria-a-Velha'		 => [ '3850', '3850' ],
           'Oliveira do Bairro'		 => [ '3770', '3770' ],
           'Estarreja'			 => [ '3860', '3865' ],
           'S�o Jo�o da Madeira'	 => [ '3700', '3701' ],
           'Espinho'			 => [ '4500', '4504' ],
           'Vale de Cambra'		 => [ '3730', '3730' ],
           'Vagos'			 => [ '3840', '3840' ],
           '�lhavo'			 => [ '3830', '3830' ],
           'Anadia'			 => [ '3780', '3780' ],
           'Castelo de Paiva'		 => [ '4550', '4550' ],
           '�gueda'			 => [ '3750', '3750' ],
           'Sever do Vouga'		 => [ '3740', '3740' ],
           'Arouca'			 => [ '4540', '4540' ],
           'Santa Maria da Feira'	 => [ '3700', '4535' ],
         },

         'Bragan�a' =>  {
           'Vila Flor'			 => [ '5360', '5360' ],
           'Carrazeda de Ansi�es'	 => [ '5140', '5140' ],
           'Miranda do Douro'		 => [ '5210', '5225' ],
           'Bragan�a'			 => [ '5300', '5301' ],
           'Macedo de Cavaleiros'	 => [ '5340', '5340' ],
           'Torre de Moncorvo'		 => [ '5160', '5160' ],
           'Mirandela'			 => [ '5370', '5385' ],
           'Mogadouro'			 => [ '5200', '5350' ],
           'Vimioso'			 => [ '5230', '5230' ],
           'Freixo Espada � Cinta'	 => [ '5180', '5180' ],
           'Vinhais'			 => [ '5320', '5335' ],
           'Alfandega da F�'		 => [ '5350', '5350' ],
         },

         'Ilha de S�o Miguel' =>  {
           'Ribeira Grande'		 => [ '9600', '9625' ],
           'Vila Franca do Campo'	 => [ '9680', '9680' ],
           'Povoa��o'			 => [ '9650', '9675' ],
           'Ponta Delgada'		 => [ '9500', '9555' ],
           'Lagoa (S�o Miguel)'		 => [ '9560', '9560' ],
           'Nordeste'			 => [ '9630', '9630' ],
         },

         'Ilha do Corvo' =>  {
           'Corvo'			 => [ '9980', '9980' ],
         },

         'Ilha de S�o Jorge' =>  {
           'Calheta (S�o Jorge)'	 => [ '9850', '9875' ],
           'Velas'			 => [ '9800', '9800' ],
         },

         'Viana do Castelo' =>  {
           'Valen�a'			 => [ '4930', '4930' ],
           'Ponte de Lima'		 => [ '4990', '4990' ],
           'Mon��o'			 => [ '4950', '4950' ],
           'Vila Nova de Cerveira'	 => [ '4920', '4920' ],
           'Ponte da Barca'		 => [ '4980', '4980' ],
           'Caminha'			 => [ '4910', '4910' ],
           'Arcos de Valdevez'		 => [ '4970', '4974' ],
           'Paredes de Coura'		 => [ '4940', '4940' ],
           'Viana do Castelo'		 => [ '4900', '4935' ],
           'Melga�o'			 => [ '4960', '4960' ],
         },

         'Portalegre' =>  {
           'Castelo de Vide'		 => [ '7320', '7320' ],
           'Arronches'			 => [ '7340', '7340' ],
           'Monforte'			 => [ '7450', '7450' ],
           'Elvas'			 => [ '7350', '7350' ],
           'Sousel'			 => [ '7470', '7470' ],
           'Nisa'			 => [ '6050', '6050' ],
           'Crato'			 => [ '7430', '7430' ],
           'Gavi�o'			 => [ '6040', '6040' ],
           'Fronteira'			 => [ '7460', '7460' ],
           'Ponte de Sor'		 => [ '7400', '7425' ],
           'Campo Maior'		 => [ '7370', '7370' ],
           'Avis'			 => [ '7480', '7480' ],
           'Portalegre'			 => [ '7300', '7301' ],
           'Marv�o'			 => [ '7330', '7330' ],
           'Alter do Ch�o'		 => [ '7440', '7440' ],
         },

         'Beja' =>  {
           'Serpa'			 => [ '7830', '7830' ],
           'Almod�var'			 => [ '7700', '7700' ],
           'Ourique'			 => [ '7670', '7670' ],
           'M�rtola'			 => [ '7750', '7750' ],
           'Alvito'			 => [ '7920', '7920' ],
           'Vidigueira'			 => [ '7960', '7960' ],
           'Aljustrel'			 => [ '7600', '7600' ],
           'Ferreira do Alentejo'	 => [ '7900', '7900' ],
           'Barrancos'			 => [ '7230', '7230' ],
           'Cuba'			 => [ '7940', '7940' ],
           'Castro Verde'		 => [ '7780', '7780' ],
           'Moura'			 => [ '7860', '7885' ],
           'Beja'			 => [ '7800', '7801' ],
           'Odemira'			 => [ '7630', '7665' ],
         },

         'Viseu' =>  {
           'Penalva do Castelo'		 => [ '3550', '5385' ],
           'Mort�gua'			 => [ '3450', '3450' ],
           'Sernancelhe'		 => [ '3620', '3640' ],
           'Nelas'			 => [ '3520', '3525' ],
           'S�o Jo�o da Pesqueira'	 => [ '5130', '5130' ],
           'Castro Daire'		 => [ '3600', '3600' ],
           'Cinf�es'			 => [ '4690', '4690' ],
           'Mangualde'			 => [ '3530', '3534' ],
           'Santa Comba D�o'		 => [ '3440', '3440' ],
           'Armamar'			 => [ '5110', '5114' ],
           'Viseu'			 => [ '3500', '3519' ],
           'Tarouca'			 => [ '3515', '3610' ],
           'Vouzela'			 => [ '3670', '3670' ],
           'S�o Pedro do Sul'		 => [ '3660', '3660' ],
           'S�t�o'			 => [ '3560', '3650' ],
           'Lamego'			 => [ '5100', '5100' ],
           'Carregal do Sal'		 => [ '3430', '3430' ],
           'Moimenta da Beira'		 => [ '3620', '3620' ],
           'Penedono'			 => [ '3630', '3630' ],
           'Vila Nova de Paiva'		 => [ '3650', '3650' ],
           'Resende'			 => [ '4660', '4660' ],
           'Tondela'			 => [ '3460', '3475' ],
           'Tabua�o'			 => [ '5120', '5120' ],
           'Oliveira de Frades'		 => [ '3475', '3680' ],
         },

         'Ilha de Santa Maria' =>  {
           'Vila do Porto'		 => [ '9580', '9580' ],
         },

         'Faro' =>  {
           'Vila do Bispo'		 => [ '8650', '8650' ],
           'Albufeira'			 => [ '8200', '8201' ],
           'Portim�o'			 => [ '8500', '8501' ],
           'Tavira'			 => [ '8800', '8801' ],
           'Silves'			 => [ '8300', '8375' ],
           'Lagos'			 => [ '8600', '8601' ],
           'Aljezur'			 => [ '8670', '8670' ],
           'Vila Real de Santo Ant�nio'	 => [ '8900', '8900' ],
           'S�o Br�s de Alportel'	 => [ '8150', '8150' ],
           'Alcoutim'			 => [ '8970', '8970' ],
           'Castro Marim'		 => [ '8950', '8950' ],
           'Lagoa (Algarve)'		 => [ '8400', '8401' ],
           'Loul�'			 => [ '8100', '8135' ],
           'Faro'			 => [ '8000', '8700' ],
           'Monchique'			 => [ '8550', '8550' ],
           'Olh�o'			 => [ '8700', '8700' ],
         },

         'Coimbra' =>  {
           'Penacova'			 => [ '3360', '3360' ],
           'Figueira da Foz'		 => [ '3080', '3094' ],
           'Cantanhede'			 => [ '3060', '3060' ],
           'Pampilhosa da Serra'	 => [ '3320', '3320' ],
           'Penela'			 => [ '3230', '3230' ],
           'Soure'			 => [ '3130', '3130' ],
           'G�is'			 => [ '3330', '3330' ],
           'Lous�'			 => [ '3200', '3200' ],
           'Arganil'			 => [ '3300', '6285' ],
           'Coimbra'			 => [ '3000', '3049' ],
           'Montemor-o-Velho'		 => [ '3140', '3140' ],
           'Condeixa-a-Nova'		 => [ '3150', '3150' ],
           'Oliveira do Hospital'	 => [ '3400', '3405' ],
           'T�bua'			 => [ '3420', '3420' ],
           'Vila Nova de Poiares'	 => [ '3350', '3350' ],
           'Miranda do Corvo'		 => [ '3220', '3220' ],
           'Mira'			 => [ '3070', '3070' ],
         },

         'Ilha da Graciosa' =>  {
           'Santa Cruz da Graciosa'	 => [ '9880', '9880' ],
         },

         'Vila Real' =>  {
           'Montalegre'			 => [ '5470', '5470' ],
           'Boticas'			 => [ '5460', '5460' ],
           'Santa Marta de Penagui�o'	 => [ '5030', '5030' ],
           'Vila Real'			 => [ '5000', '5004' ],
           'Alij�'			 => [ '5070', '5085' ],
           'Ribeira de Pena'		 => [ '4870', '4870' ],
           'Chaves'			 => [ '5400', '5425' ],
           'Mes�o Frio'			 => [ '5040', '5040' ],
           'Vila Pouca de Aguiar'	 => [ '5450', '5450' ],
           'Peso da R�gua'		 => [ '5040', '5054' ],
           'Valpa�os'			 => [ '5430', '5445' ],
           'Mur�a'			 => [ '5090', '5090' ],
           'Sabrosa'			 => [ '5060', '5085' ],
           'Mondim de Basto'		 => [ '4880', '4880' ],
         },

         'Braga' =>  {
           'Terras de Bouro'		 => [ '4840', '4845' ],
           'Braga'			 => [ '4700', '4719' ],
           'Vizela'			 => [ '4620', '4815' ],
           'Vila Verde'			 => [ '4730', '4730' ],
           'Amares'			 => [ '4720', '4720' ],
           'Barcelos'			 => [ '4740', '4905' ],
           'Cabeceiras de Basto'	 => [ '4860', '4860' ],
           'Vieira do Minho'		 => [ '4850', '4850' ],
           'Vila Nova de Famalic�o'	 => [ '4760', '4775' ],
           'Esposende'			 => [ '4740', '4740' ],
           'P�voa de Lanhoso'		 => [ '4830', '4830' ],
           'Fafe'			 => [ '4820', '4824' ],
           'Guimar�es'			 => [ '4765', '4839' ],
           'Celorico de Basto'		 => [ '4615', '4890' ],
         },

         'Set�bal' =>  {
           'Moita'			 => [ '2835', '2864' ],
           'Set�bal'			 => [ '2900', '2925' ],
           'Sesimbra'			 => [ '2970', '2975' ],
           'Palmela'			 => [ '2950', '2965' ],
           'Alcochete'			 => [ '2890', '2894' ],
           'Sines'			 => [ '7520', '7555' ],
           'Seixal'			 => [ '2840', '2865' ],
           'Montijo'			 => [ '2100', '2985' ],
           'Alc�cer do Sal'		 => [ '7580', '7595' ],
           'Barreiro'			 => [ '2830', '2835' ],
           'Gr�ndola'			 => [ '7570', '7570' ],
           'Santiago do Cac�m'		 => [ '7500', '7565' ],
           'Almada'			 => [ '2800', '2829' ],
         },

         'Ilha do Faial' =>  {
           'Horta'			 => [ '9900', '9901' ],
         },

         'Ilha Terceira' =>  {
           'Angra do Hero�smo'		 => [ '9700', '9701' ],
           'Praia da Vit�ria'		 => [ '9760', '9760' ],
         },

         'Ilha de Porto Santo' =>  {
           'Porto Santo'		 => [ '9400', '9400' ],
         },

         'Porto' =>  {
           'Bai�o'			 => [ '4640', '5040' ],
           'P�voa de Varzim'		 => [ '4490', '4570' ],
           'Valongo'			 => [ '4440', '4445' ],
           'Santo Tirso'		 => [ '4780', '4825' ],
           'Trofa'			 => [ '4745', '4785' ],
           'Marco de Canaveses'		 => [ '4575', '4635' ],
           'Maia'			 => [ '4425', '4479' ],
           'Vila Nova de Gaia'		 => [ '4400', '4434' ],
           'Matosinhos'			 => [ '4450', '4465' ],
           'Amarante'			 => [ '4600', '4615' ],
           'Penafiel'			 => [ '4560', '4575' ],
           'Paredes'			 => [ '4580', '4585' ],
           'Gondomar'			 => [ '4420', '4515' ],
           'Pa�os de Ferreira'		 => [ '4590', '4595' ],
           'Vila do Conde'		 => [ '4480', '4486' ],
           'Felgueiras'			 => [ '4610', '4815' ],
           'Porto'			 => [ '4000', '4369' ],
           'Lousada'			 => [ '4620', '4620' ],
         },

         'Castelo Branco' =>  {
           'Vila de Rei'		 => [ '6110', '6110' ],
           'Proen�a-a-Nova'		 => [ '6150', '6150' ],
           'Oleiros'			 => [ '6160', '6185' ],
           'Vila Velha de Rod�o'	 => [ '6030', '6030' ],
           'Fund�o'			 => [ '6005', '6230' ],
           'Covilh�'			 => [ '6200', '6230' ],
           'Penamacor'			 => [ '6090', '6320' ],
           'Castelo Branco'		 => [ '6000', '6005' ],
           'Sert�'			 => [ '6100', '6100' ],
           'Belmonte'			 => [ '6250', '6250' ],
           'Idanha-a-Nova'		 => [ '6060', '6060' ],
         },

         'Guarda' =>  {
           'Pinhel'			 => [ '6400', '6400' ],
           'Meda'			 => [ '6430', '6430' ],
           'Sabugal'			 => [ '6250', '6324' ],
           'Gouveia'			 => [ '6290', '6290' ],
           'Seia'			 => [ '6270', '6285' ],
           'Fornos de Algodres'		 => [ '6370', '6370' ],
           'Vila Nova de Foz Coa'	 => [ '5150', '5155' ],
           'Aguiar da Beira'		 => [ '3570', '3570' ],
           'Celorico da Beira'		 => [ '6360', '6360' ],
           'Trancoso'			 => [ '3640', '6420' ],
           'Almeida'			 => [ '6350', '6355' ],
           'Guarda'			 => [ '6300', '6301' ],
           'Figueira de Castelo Rodrigo' => [ '6440', '6440' ],
           'Manteigas'			 => [ '6260', '6300' ],
         },

  );

}

sub code_is_from_area {
  my $code = shift || return undef;
  my $area = shift || return undef;
  defined $range{$area} || return undef;

  for (keys %{$range{$area}}) {
    if ($code >= ${$range{$area}{$_}}[0] && $code <= ${$range{$area}{$_}}[1]) {
      return 1;
    }
  }

  return 0;
}

sub code_is_from_subarea {
  my $code = shift || return undef;
  my $subarea = shift || return undef;

  for (keys %range) {
    defined $range{$_}{$subarea} || next;
    if ( $code >= ${$range{$_}{$subarea}}[0] &&
         $code <= ${$range{$_}{$subarea}}[1]    ) {
      return 1;
    }
    else {
      return 0;
    }
  }

  return undef;
}

sub code_is_from {
  my $code = shift || return undef;
  my $subarea = shift || return undef;
  my $area = shift || return undef;

  defined $range{$area}{$subarea} || return undef;

  if ( $code >= ${$range{$area}{$subarea}}[0] &&
       $code <= ${$range{$area}{$subarea}}[1]    ) {
    return 1;
  }
  else {
    return 0;
  }
}

sub range_from_subarea {
  my $subarea = shift || return undef;

  for (keys %range) {
    defined $range{$_}{$subarea} || next;
    return $range{$_}{$subarea};
  }

  return undef;
}

sub code_is_valid {
  my $code = shift || return undef;

  for my $a (keys %range) {
    for my $s (keys %{$range{$a}}) {
      if ($code >= ${$range{$a}{$s}}[0] && $code <= ${$range{$a}{$s}}[1]) {
        return 1;
      }
    }
  }

  return 0;
}

sub areas_of_code {
  my $code = shift || return undef;

  my @areas;

  for my $a (keys %range) {
    for my $s (keys %{$range{$a}}) {
      if ($code >= ${$range{$a}{$s}}[0] && $code <= ${$range{$a}{$s}}[1]) {
        push @areas, $a;
      }
    }
  }

  return @areas;
}

sub subareas_of_code {
  my $code = shift || return undef;

  my @subareas;

  for my $a (keys %range) {
    for my $s (keys %{$range{$a}}) {
      if ($code >= ${$range{$a}{$s}}[0] && $code <= ${$range{$a}{$s}}[1]) {
        push @subareas, $s;
      }
    }
  }

  return @subareas;
}

1;
__END__

=head1 DESCRIPTION

Validates Portuguese Postal Codes (that's the four digit code; in
order to validate the seven digit codes of the form xxxx-xxx we would
need a huge list of codes that would probably change every day).

=head1 PORTUGUESE POSTAL CODES

Regarding postal codes, Portugal is divided into areas and then into
subareas. This division does not correspond to the most expected one
(districts and then cities); instead, it was apparently made in a
way it would be easier to redirect mail.

Postal codes in Portugal do not seem to follow any particular rule
(but there was probably one in the beginning). There is no easy way of
saying where a given code belongs to.

Each subarea has a minimum and a maximum code. This means it only
allows for codes within that range. HOWEVER:

1) The existance of a range within a subarea does not imply the
existance of every single code in it.

2) The existance of a code within a subarea does not mean the code
does not exist in another area too.

THIS MEANS:

1) You can check if a code belongs to a certain area/subarea, but that
does not mean it doesn't also belong to other(s) area(s)/subarea(s).

2) Even if a code is within the range of a certain subarea, that does
not mean it is an existing code (that would need a huge list of codes,
which is always subject to alterations).

=head1 MESSAGE FROM THE AUTHOR

If you're using this module, please drop me a line to my e-mail. Tell
me what you're doing with it. Also, feel free to suggest new
bugs^H^H^H^H^H features.

=head1 AUTHOR

Jose Alves de Castro, E<lt>cog [at] cpan [dot] org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Jose Alves de Castro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
