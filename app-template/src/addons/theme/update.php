<?php
/**
 * Theme
 *
 * @author Daniel Weitenauer
 */

rex_autoload::addDirectory(__DIR__.'/lib');
theme_compat::syncConfig();

/**
 * Rename folder yform_emails to yform_email to ensure compatibility with developer addon
 * @version 1.3.0
 */
if (rex_addon::get('developer')->isAvailable() &&
    rex_string::versionCompare(rex_addon::get('developer')->getVersion(), '3.6.0', '>=') &&
    file_exists(theme_path::base('private/redaxo/yform_emails'))) {
    rename(theme_path::base('private/redaxo/yform_emails'), theme_path::base('private/redaxo/yform_email'));
}
