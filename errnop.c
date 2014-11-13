#include "EXTERN.h"
#define PERL_IN_ERRNOP_C
#include "perl.h"

SV *
Perl_errno2sv(pTHX_ SV *sv)
{
    dSAVE_ERRNO;

    PERL_ARGS_ASSERT_ERRNO2SV;

    #ifdef VMS
        sv_setnv(sv, (NV)((errno == EVMSERR) ? vaxc$errno : errno));
    #else
        sv_setnv(sv, (NV)errno);
    #endif

    #ifdef OS2
        if (errno == errno_isOS2 || errno == errno_isOS2_set)
            sv_setpv(sv, os2error(Perl_rc));
        else
    #endif
    if (! errno) {
        sv_setpvs(sv, "");
    }
    else {
        /* Strerror can return NULL on some platforms, which will
         * result in 'sv' not being considered SvOK.  The SvNOK_on()
         * below will cause just the number part to be valid */
        sv_setpv(sv, my_strerror(errno));
        if (SvOK(sv)) {
            fixup_errno_string(sv);
        }
    }
    RESTORE_ERRNO;

    SvRTRIM(sv);
    SvNOK_on(sv);	/* what a wonderful hack! */

    return sv;
}

void
Perl_fixup_errno_string(pTHX_ SV* sv)
{
    /* Do what is necessary to fixup the non-empty string in 'sv' for return to
     * Perl space. */

    PERL_ARGS_ASSERT_FIXUP_ERRNO_STRING;

    assert(SvOK(sv));

    if(strEQ(SvPVX(sv), "")) {
        sv_catpv(sv, UNKNOWN_ERRNO_MSG);
    }
    else {

        /* In some locales the error string may come back as UTF-8, in which
         * case we should turn on that flag.  This didn't use to happen, and to
         * avoid as many possible backward compatibility issues as possible, we
         * don't turn on the flag unless we have to.  So the flag stays off for
         * an entirely invariant string.  We assume that if the string looks
         * like UTF-8, it really is UTF-8:  "text in any other encoding that
         * uses bytes with the high bit set is extremely unlikely to pass a
         * UTF-8 validity test"
         * (http://en.wikipedia.org/wiki/Charset_detection).  There is a
         * potential that we will get it wrong however, especially on short
         * error message text.  (If it turns out to be necessary, we could also
         * keep track if the current LC_MESSAGES locale is UTF-8) */
        if (! IN_BYTES  /* respect 'use bytes' */
            && ! is_invariant_string((U8*) SvPVX_const(sv), SvCUR(sv))
            && is_utf8_string((U8*) SvPVX_const(sv), SvCUR(sv)))
        {
            SvUTF8_on(sv);
        }
    }
}
