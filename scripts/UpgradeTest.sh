#!/bin/bash
PROG=$(basename $0)

RUN=
PUBLICDIR=${PUBLICDIR:-/Volumes/public/Software_Releases}
UPDATER=${UPDATER:-$HOME/xTuple/Updater_2.4.0.app/Contents/MacOS/updater}

PGHOST=${PGHOST:-192.168.33.20}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-admin}
PGPASSWORD=${PGPASSWORD:-admin}
TMPDIR=${TMPDIR:-/tmp}
export PGOPTIONS="-c client_min_messages=warning"

export PGHOST PGPORT PGUSER PGPASSWORD

for SCRIPTDIR in . scripts/output xtuple/scripts/output * ; do
  if ls $SCRIPTDIR/enterprise-upgrade-*.gz > /dev/null 2>&1 ; then
    break;
  fi
done
DESTVER=$(basename $SCRIPTDIR/enterprise-upgrade-*.gz .gz | sed -e "s/enterprise-upgrade-//")

usage() {
cat <<USAGE
usage:
$PROG [ options ]

--help          print this usage message
-h, --host      hostname or IP address where the database server is running [ $PGHOST ]
-p, --port      port on which the database server is listening [ $PGPORT ]
-U, --user      PostgreSQL user to log in as [ $PGUSER ]
--passwd, --password PostgreSQL user's password [ am I really that stupid\? ]
-u, --updater   path to the Updater [ $UPDATER ]
-n, --no-run    show what $PROG would do without actually doing it [ $RUN ]
-P, --public    path to the Software_Releases directory [ $PUBLICDIR ]
USAGE
}

ERRS=""
logErr() {
  if [ $# -gt 0 ] ; then
    ERRS="$ERRS
    $*"
  else
    ERRS="$ERRS
    an undescribed error occurred"
  fi
}

applyUpdate() {
  local DB="$1"
  local FILE="$2"
  $RUN $UPDATER -h $PGHOST -p $PGPORT -d $DB -U $PGUSER -passwd=$PGPASS -D -autorun -f $FILE
}

getValueArg() {
  local KEY="$1"
  local VALUE="$2"
  if [ -n "$KEY" -a -n "$VALUE" ] ; then
    eval $KEY="$VALUE"
    return 0
  fi
  return 1
}

# -h is handled as either --host if it has an arg or --help if not
while [ $# -gt 0 ] ; do
  case "$1" in
    --help)        usage ; exit 0 ;;
    -n|--no-run*)  RUN=echo       ;;
    -h|--host*)    if getValueArg PGHOST     $2 ; then shift ; else usage ; exit 0 ; fi ;;
    -p|--port*)    if getValueArg PGPORT     $2 ; then shift ; else usage ; exit 1 ; fi ;;
    -U|--user*)    if getValueArg PGUSER     $2 ; then shift ; else usage ; exit 1 ; fi ;;
    --pass*)       if getValueArg PGPASSWORD $2 ; then shift ; else usage ; exit 1 ; fi ;;
    -u|--updater*) if getValueArg UPDATER    $2 ; then shift ; else usage ; exit 1 ; fi ;;
    -P|--public*)  if getValueArg PUBLICDIR  $2 ; then shift ; else usage ; exit 1 ; fi ;;
    *)             usage ; exit 1 ;;
  esac
  shift
done

ls ${PUBLICDIR}/4.[5-9].[0-9]/*.backup ${PUBLICDIR}/[5-9].[0-9][0-9].[0-9]/*.backup | cat -n
for FILE in $(ls ${PUBLICDIR}/4.[5-9].[0-9]/*.backup ${PUBLICDIR}/[5-9].[0-9][0-9].[0-9]/*.backup) ; do
    STARTVER=$(basename $(dirname $FILE))
    DB=$(basename $FILE -${STARTVER}.backup)_to${DESTVER}
    case $DB in
      dist*|stand*)
        if [[ "$STARTVER" =~ ^4.[45].[0-9] ]] ; then
           echo skipping $STARTVER distribution since some distribution databases are broken
           continue
        fi
        GZ=$SCRIPTDIR/distribution-upgrade-*.gz
        ;;
      mfg*|manu*)
        GZ=$SCRIPTDIR/manufacturing-upgrade-*.gz
        ;;
      mast*)
        GZ=$SCRIPTDIR/enterprise-upgrade-*.gz
        ;;
      post*|demo*|empty*|quick*)
        GZ=$SCRIPTDIR/postbooks-upgrade-*.gz
        ;;
      *)
        logErr Do not know how to process upgrade test $STARTVER to $DESTVER for $DB = $FILE
        ;;
    esac

    echo ===== $(date) $STARTVER to $DESTVER for $DB =================================
    $RUN dropdb --if-exists $DB
    $RUN createdb $DB
    $RUN pg_restore -d $DB $FILE
    echo ===== starting upgrade ---------------------------------------------------------------
    applyUpdate $DB $GZ || logErr error upgrading from $STARTVER to $DESTVER for $DB = $FILE using $GZ
    $RUN psql -t -d $DB -c "SELECT fetchMetricText('ServerVersion') = '$DESTVER';" | tee $TMPDIR/$PROG.$$
    [ -n "$RUN" -o "$(tr -d [:space:] < $TMPDIR/$PROG.$$)" = 't' ] || logErr ServerVersion in $DB does not match $DESTVER
    $RUN psql -t -d $DB -c "SELECT COUNT(*) = 0 OR BOOL_AND(pkghead_version = '$DESTVER') \
                           FROM pkghead WHERE pkghead_name in ('xtcore', 'xtmfg', 'xwd');" | tee $TMPDIR/$PROG.$$
    [ -n "$RUN" -o "$(tr -d [:space:] < $TMPDIR/$PROG.$$)" = 't' ] || logErr Core extensions in $DB do not match $DESTVER
    echo ===== reapplying upgrade -------------------------------------------------------------
    applyUpdate $DB $GZ || logErr error reapplying upgrade to $DESTVER for $DB = $FILE using $GZ
    case $DB in
      dist*|stand*)
        echo ===== upgrading $DB to enterprise ---------------------------------------------------
        applyUpdate $DB $SCRIPTDIR/add-manufacturing-to-distribution-*.gz || logErr error upgrading $DB to enterprise
        ;;
    esac

    echo ===== $(date) $STARTVER to $DESTVER for $DB finished ========================
done

if [ -n "$ERRS" ] ; then
  echo "$ERRS"
  exit 1
fi

echo "Congratulations: No apparent upgrade errors"
exit 0
