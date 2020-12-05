package Web;
use Moose;
use Data::Dumper;
use Plack::Request;
use base 'Plack::Component';
use DBI;

has 'log' => ( is => 'ro', isa => 'Log::Log4perl::Logger', required => 1 );
has 'conf' => ( is => 'ro', isa => 'Config::JSON', required => 1 );
has 'db' => ( is => 'rw', isa => 'Object', required => 0 );

#our %Query_params = (
#	srcip => qr/^(?<not>\!?)(?<srcip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/,
#	dstip => qr/^(?<not>\!?)(?<dstip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/,
#	srcport => qr/^(?<not>\!?)(?<srcport>\d{1,5})$/,
#	dstport => qr/^(?<not>\!?)(?<dstport>\d{1,5})$/,
#	start => qr/(?<start>.+)/, # start/end will be run through a parser for sanitization
#	end => qr/(?<end>.+)/,
#	offset => qr/^(?<offset>\d+)$/,
#	limit => qr/^(?<limit>\d{1,5})$/,
#	pcre => qr/(?<pcre>.+)/,
#	as_hex => qr/^(?<as_hex>1)$/,
#	raw => qr/^(?<raw>1)$/,
#	sort => qr/^(?<sort>1)$/,
#	direction => qr/^(?<direction>[cs])$/,
#	quiet => qr/^(?<quiet>1)$/,
#	reason => qr/^(?<not>\!?)(?<reason>[crteli])$/,
#	filetype => qr/^(?<not>\!?)(?<filetype>[\w\s]+)/,
#	submit => qr/^(?<submit>[\w\s]+)/,
#	oid => qr/^(?<oid>\d+\-\d+\-\d+\-\d+)$/,
#	as_json => qr/^(?<as_json>1)$/,
#);

sub BUILD {
	my ($self, $params) = @_;
	
	$self->db(
			DBI->connect(
			'dbi:mysql:database='. 
				$self->conf->get('db/database') . 
			';host='. 
				$self->conf->get('db/host'), 
				$self->conf->get('db/username'), 
				$self->conf->get('db/password')
			)
	);	
	return $self;
}

sub call {
	my ($self, $env) = @_;
	my $req = Plack::Request->new($env);
	my $res = $req->new_response(200); # new Plack::Response
	my $ret;

	eval {
		if ($req->query_parameters->{show} eq 'req'){
			$res->content_type('text/plain');
			$ret = Dumper($req);
		}
      		elsif ($req->query_parameters->{show} eq 'env'){
      			$res->content_type('text/plain');
      			$ret = Dumper($env);
    		}
    		elsif ($req->query_parameters->{show} eq 'self'){
    			$res->content_type('text/plain');
      			$ret = Dumper($self);
    		}
    		else {
			$res->content_type('text/html');
			$ret  = '<a href="./?show=req">req</a><br>';
      			$ret .= '<a href="./?show=env">env</a><br>';
      			$ret .= '<a href="./?show=self">self</a><br>';
		}
	};
	if ($@){
		my $e = $@;
		$self->log->error($e);
		$ret = $e . "\n" . usage();
	}
    $res->body($ret);
    $res->finalize;
}

1;

__END__
