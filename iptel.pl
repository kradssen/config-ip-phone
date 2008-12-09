#!/usr/bin/perl
#
# This script performs the password change of a IP phone, using as input parameters:
#The username
#The new password
#The IP phone.
#

#Compulsive module loading
use strict;
use warnings;
use Net::Telnet;
use Getopt::Std;
use Config::Simple;

#Our main options:
our($opt_i);
# u = User
# p = password
# i = ip phone.
# 


getopts('i:');

# My vars
my @out;  #my generic out
my $lineout;  #my generic line
my @version;
my %user_conf;   #array of config
#import adress of the file config
my $user_file = "/home/kradssen/Programacion/Perl/config-ip-phone/user.conf";
#import data form config file to array of config
Config::Simple->import_from($user_file, \%user_conf);

#get de data
my $username =  $user_conf{"ipphone.user"};
my $password = $user_conf{"ipphone.password1"};
my $password2 = $user_conf{"ipphone.password2"};

#start and open session
my $session = Net::Telnet->new(Host=>$opt_i);

#firs try to login
@out = $session->login(NAME => $username, Password => $password, Errmode => "return");
if(@out != 1) {
        print "LOGIN FAILED in the first try\n";
        $session->open($opt_i);
        @out = $session->login($username, $password2);
        }
$lineout = $session->last_prompt;
if($lineout =~ m/\#/) { print "Login OK\n";}


#first see the soft version 
print "The software version is: ";
@version = $session->cmd("show version");
print "@version\n";

#Check if the version is new or old
if (@version = 'VOIP PHONE  V1.6.4.5  Aug 13 2007 15:36:17') {
	print "The version is new\nThen, the command to use is:\n\n";
	print "Show Sip Status: show sip\n";
	print "Change config the register: config voip sip server register -ip <domain> _user <user> _password <pass> _port <port> _expiretime <time>\n";
	
	#Now show the sip status before of the change
	@out = $session->cmd("show sip");
	print "@out\n";
	#Go change
	#@out = $session->cmd("config voip sip server register -ip $opt_d _user $opt_u _password $opt_p _port 5060 _expiretime 60");
	#If @out is 1, then the change was performed successfully
	#if (@out =1) { print "the change was performed successfully"; } else { print "the change is failed"; }
	#Save the new config
	#$session->cmd("save");
	#Reload ip phone
	#$session->cmd("reload");
	}
  else {
	print "The Version is old\nThen, the command to use is:\n";
	print "Change config for the register: config SIP server -ip <domain> _user <user> _password <pass> -number <port?> _port <port> _expire <time>\n";
	#go change
        #@out = $session->cmd("config SIP server -ip $opt_d _user $opt_u _password $opt_p -number 5060 _port 5060 _expire 60");
        #If @out is 1, then the change was performed successfully
        #if (@out =1) { print "the change was performed successfully"; } else { print "the change is failed"; }
	#Save the new config
        #$session->cmd("save");
	#reload ip phone"
	#$session->cmd("reboot");
	}
#Now close the session
@out = $session->close;
if(@out = 1) { print "Session closed correctly.\n"; } else { print "Warning: problem while closed session.\n";}

