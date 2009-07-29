use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'Alister::Base::Hosts',
   VERSION_FROM => 'lib/Alister/Base/Hosts.pm',
   

   # gen /usr/bin/pmused by Wed Jul 29 10:16:42 EDT 2009 
   PREREQ_PM => {
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'Exporter'                          => '5',
      'LEOCHARRE::Debug'                  => '1.02',
      'Test::Simple'                      => '0',
      'YAML::DBH'                         => '1.06',
   },

   
   LICENSE => 'perl',
   
   
   
   EXE_FILES => [],
);


