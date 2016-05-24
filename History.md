### 1.11 / 2016-05-24

*   1 minor enhancement:

    *   If the controller instance does not respond to the 'respond_to' method,
        then we want to default to rendering a JSON response.

*   2 minor configuration changes:

    *   Add a .hoerc file so that we don't have errors on Travis CI.

    *   Add dependency_decisions.yml to whitelist dependencies by license.

*   1 governance change:

    *   kinetic_cafe_error is now governed under the Kinetic Cafe Open Source
        [Code of Conduct][kccoc].

### 1.10 / 2016-03-25

*   1 bug fix:

    *   Protect against names with punctuation in them.

*   1 testing change:

    *   Add Appraisals to test against both Rack 1.6 and Rack 2.0.

### 1.9 / 2015-11-30

*   2 bug fixes:

    *   The #stringify method needed to be moved to KineticCafe::ErrorModule so
        that hierarchies *not* built from KineticCafe::Error can properly use
        query parameter parsing.

    *   kinetic_cafe_error has required Ruby 2.1 or higher since version 1.5
        because of the inclusion of i18n-tasks as a dependency. This is now
        reflected in the dependencies.

### 1.8.1 / 2015-10-26

*   Re-release because 1.8 was yanked

### 1.8 / 2015-10-26

*   1 minor enhancement:

    *   Add `kinetic_cafe_error_handle_post_error` to allow for capturing or
        post-processing of errors after logging and handling.

### 1.7 / 2015-08-05

*   1 minor enhancement:

    *   Add a `params` parameter to the `kcerror:defined` task that
        will show the parameter names the exception expects.

*   1 bug fix:

    *   RubyMine does not fully initialize the project when running RSpec,
        meaning that while Rake is defined, Rake::DSL is not. As such, we need
        to prevent the Rake task from loading unless Rake::DSL is present.

### 1.6 / 2015-07-30

*   2 minor enhancements:

    *   Improve the Minitest and RSpec test helpers so that they ignore the
        error `cause` if it is not included as part of the assertion. The
        specification of the `cause` is recommended if you have specific values
        you want to compare.

    *   Improve `kinetic_cafe_error_handler` so that if it is called with an
        error class instead of an instance of an error, it will construct the
        error instance with the provided parameters. This makes custom
        `rescue_from` constructions cleaner.

### 1.5 / 2015-07-29

*   2 bug fixes:

    *   Handle error causes correctly for Ruby 2.1 or later, where `raise
        Exception, cause: RuntimeError.new` does not pass the `cause` the
        exception constructor, but it still sets the cause correctly on the
        exception. These changes make this correct for both `raise`
        construction and normal construction.

    *   The RSpec helpers did not work because they spelled the class `Rspec`,
        not `RSpec`. This has been fixed.

*   2 development changes:

    *   Fixed some test typos.

    *   Add i18n-tasks for CSV exports.

### 1.4.1 / 2015-07-08

*   1 bug fix

    *   Fixed an error with loading error_tasks.rake from the Rails engine.

### 1.4 / 2015-07-07

*   2 minor enhancements

    *   Changed how kcerror:translations generates the translation YAML for
        consistent comparison (it no longer uses the YAML library to do this).
        The file generated will always be for language `kc` so that this can be
        used with i18n-tasks.

*   4 bug fixes

    *   Task kcerror:defined would error out if there were no defined
        descendants.
    *   Task kcerror:translations would error out if there were no defined
        descendants.
    *   Made task loading more reliable and automatic.
    *   Removed some defaulted, unused parameters for
        `assert_response_kc_error_html` (Minitest) and `be_kc_error_html`
        (RSpec).

*   Notes:

    *   Applied Rubocop to enforce the KineticCafe house style.

### 1.3 / 2015-06-18

*   3 minor enhancements

    *   Added a controller method, `kinetic_cafe_error_handler_log_error`, in
        KineticCafe::ErrorHandler that will log the given error in the default
        logging language, and its cause, if any.

    *   Added a controller class method to change the default logging language
        for `kinetic_cafe_error_handler_log_error`. A locale may be provided
        with `kinetic_cafe_error_handler_log_locale`. Fixes
        [#2]{https://github.com/KineticCafe/kinetic_cafe_error/issues/2}.

    *   Added an optional `locale` parameter to
        KineticCafe::ErrorModule#message and
        KineticCafe::ErrorModule::#i18n_message. If I18n is present and
        `locale` is provided, the translation will *not* be cached and the
        translation will be performed using the provided locale.

*   1 bug fixed

    *   The Minitest assertion, `assert_kc_error`, could not work because it
        was looking for descendants of KineticCafe::ErrorDSL, not
        KineticCafe::ErrorModule. Reported by @richardsondx as
        [#3]{https://github.com/KineticCafe/kinetic_cafe_error/issues/3} during
        a pairing session.

### 1.2 / 2015-06-08

*   1 major enhancement

    *   Changed the preferred way of creating an error hierarchy from just
        extending the error class with KineticCafe::ErrorDSL to calling
        KineticCafe.create_hierarchy. Among other options this provides, the
        automatic creation of helper methods and errors based on Rack::Utils
        status codes can be controlled.

*   5 minor enhancements

    *   Renamed KineticCafe#header_only? to KineticCafe#header? The old version
        is still present but deprecated. Similarly, the option to
        KineticCafe::ErrorDSL#define_error is now called `header`, but
        `header_only` also works.

    *   Added an option, `i18n_params` to KineticCafe::ErrorDSL#define_error,
        used to describe the I18n parameters that are expected to be provided
        to the error for translations. This gets defined as a class method on
        the new error. This should be passed as an array.

    *   Extracted most of the 'magic' functionality to KineticCafe::ErrorModule
        so that useful hierarchies can be generated without inheriting directly
        from KineticCafe::Error.

    *   Added a class method to the Rails controller concern to generate a new
        rescue_from for a non-KineticCafe::Error-derived exception.

    *   Added a pair of rake tasks, kcerror:defined (shows defined errors) and
        kcerror:translations (generates a sample translation key file).
        Automatically inserted for Rails applications.

### 1.1 / 2015-06-05

*   7 minor enhancements

    *   Added Minitest assertions and expectations.
    *   Added Rspec expectation matchers.
    *   Changed the error table to be a partial and renamed keys to support
        this change (kinetic_cafe_error/_table.html.*). Removed the previous
        key. Now an error is nominally embeddable in your own views without
        being a full page.
    *   Added HAML templates.
    *   Added Slim templates.
    *   Move error page to `kinetic_cafe_error/page.html.*` instead of
        `kinetic_cafe/error/page.html.*`. This could be a breaking change, but
        I consider it low risk.
    *   Added KineticCafe::Error#code as an alias for KineticCafe::Error#i18n_key.

*   2 minor bugfixes:

    *   The en and fr translation files were reporting en-CA and fr-CA as their
        locales, which is incorrect.

    *   Renamed locale files to better match their names to their locales. The
        locale is not en_ca, but en-CA.

### 1.0.1 / 2015-05-27

*   1 minor bugfix

    *   Mac OS X is not case-sensitive and I do not currently have
        Rails-specific tests.

### 1.0.0 / 2015-05-27

*   1 major enhancement

    *   Birthday!

[kccoc]: https://github.com/KineticCafe/code-of-conduct
