package Web;
use Moose;
use Data::Dumper;
use Plack::Request;
use base 'Plack::Component';
use DBI;

has 'log' => ( is => 'ro', isa => 'Log::Log4perl::Logger', required => 1 );
has 'conf' => ( is => 'ro', isa => 'Config::JSON', required => 1 );
has 'db' => ( is => 'rw', isa => 'Object', required => 0 );

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
