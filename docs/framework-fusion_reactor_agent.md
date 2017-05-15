# Fusion Reactor Agent Framework
The Fusion Reactor Agent Framework causes an application to be automatically configured to work with a bound [Fusion Reactor Service][].

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td><td>Existence of a single bound Fusion Reactor service.
      <ul>
        <li>Existence of a Fusion Reactor service is defined as the <a href="http://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html#VCAP-SERVICES"><code>VCAP_SERVICES</code></a> payload containing a service who's name, label or tag has <code>fusionreactor</code> as a substring.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td>
    <td><tt>fusion-reactor-agent=&lt;version&gt;</tt></td>
  </tr>
</table>
Tags are printed to standard output by the buildpack detect script

## User-Provided Service (Optional)
Users may optionally provide their own Fusion Reactor service. A user-provided Fusion Reactor service must have a name or tag with `fusionreactor` in it so that the Fusion Reactor Agent Framework will automatically configure the application to work with the service.

The credential payload of the service may contain the following entries:

| Name | Description
| ---- | -----------
| `debug` | (Optional) Whether to attach the debug agent.  Defaults to `true`
| `instance_name` | (Optional) The name of the isntance.  Defaults to the application name.
| `instance_port` | (Optional) The port of the instance.  Defaults to `8088`.
| `license` | The license key
| `password` | The password

## Configuration
For general information on configuring the buildpack, including how to specify configuration values through environment variables, refer to [Configuration and Extension][].

The framework can be configured by modifying the [`config/fusion_reactor_agent.yml`][] file in the buildpack fork.  The framework uses the [`Repository` utility support][repositories] and so it supports the [version syntax][] defined there.

| Name | Description
| ---- | -----------
| `repository_root` | The URL of the Fusion Reactor repository index ([details][repositories]).
| `version` | The version of Fusion Reactor to use. Candidate versions can be found in [this listing][].

[Configuration and Extension]: ../README.md#configuration-and-extension
[`config/fusion_reactor_agent.yml`]: ../config/fusion_reactor_agent.yml
[Fusion Reactor Service]: https://www.fusion-reactor.com
[repositories]: extending-repositories.md
[this listing]: http://cloudfoundry.fusionreactor.io/index.yml
[version syntax]: extending-repositories.md#version-syntax-and-ordering
