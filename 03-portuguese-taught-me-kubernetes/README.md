# Portuguese Taught Me Kubernetes

I am sitting at my desk going over a lesson in Kubernetes and I was struggling on how to truly understand how I can memorize these commands. Mischa asked a question on this particular KubeCraft lesson saying what is the command to edit a deployment. I have done this command several times but I could not put it together, and I had this memory of how this happens when I started to put together a sentence in Portuguese. I had the first part but everything in between was rearranged and wrong. At this point a light bulb went off. This is like putting a sentence together. who knew.

A command is a sentence.

Every command has the same shape:

```
kubectl [verb] [resource] [name] [flags]
```

That's not something to memorize. That's subject, verb, object, description. The same thing I already do in another language.

If you do not think about grammar much, here is what those words mean. The subject is who is doing it. The verb is the action. The object is the thing the action happens to. The description is the extra part that says which one, or how.

## The one that started it

Here is the command Mischa asked about, dropped into those slots, next to a Portuguese sentence with the same parts:

```
Eu       edito  a foto        antiga
kubectl  edit   deployment    test
```

*Antiga* says which photo, the old one. `test` says which deployment. Same job.

## The slot-for-slot match

Add a flag and you fill every slot:

```
Eu como a maçã vermelha rapidamente
```

| Portuguese grammar part | in the sentence | kubectl slot | example |
| --- | --- | --- | --- |
| **Sujeito** (subject/doer) | Eu | `kubectl` | the one acting |
| **Verbo** (verb/action) | como | `[verb]` | `delete` |
| **Substantivo** (noun/object) | maçã | `[resource]` | `deployments` |
| **Adjetivo** (which specific one) | vermelha | `[name]` | `test` |
| **Advérbio** (modifier/how) | rapidamente | `[flags]` | `-n dev` |

Reading across, part by part:

1. **Sujeito -> `kubectl`.** Every sentence has a doer. In Portuguese it's *Eu*. In the command it's `kubectl` itself, the thing carrying out the order.
2. **Verbo -> `[verb]`.** *Como* is the action. `[verb]` is the action. No verb, no sentence.
3. **Substantivo -> `[resource]`.** *Maçã* is the thing being acted on. So is `[resource]`. The object.
4. **Adjetivo -> `[name]`.** *Vermelha* narrows it to the red one. `[name]` narrows it to the one called `test`.
5. **Advérbio -> `[flags]`.** *Rapidamente* tunes how it happens. `[flags]` tune how the command runs.

## Swap the verb, keep the sentence

Once you see the shape, you stop learning commands one at a time. You change the verb and the rest holds.

```
kubectl get pods
kubectl delete deployment test
kubectl apply -f app.yaml
```

Get, delete, apply. Same sentence, different verb. Portuguese does the same thing. *Eu como*, *eu edito*, *eu vejo*. One structure, you just swap the action into it.

## Leave off the name and you mean all of them

```
Eu vejo os pássaros
kubectl get pods
```

No specific one. Just the whole group. In Portuguese a plural with no name is the whole set, the birds, not one bird. In kubectl, drop the name and you get every pod. Same rule, both places.

## Why this proves my point

The template *is* a grammar. `[verb] [resource] [name] [flags]` is nothing but subject-verb-object-modifier wearing technical clothes. When you learn Portuguese, you learn to fill those slots with the right word in the right order. When you learn Kubernetes, you learn to fill the same slots with the right word in the right order. That's why the second one came faster: my brain already knew the shape.

I wasn't learning a new skill. I was reusing an old one.

## The research

Turns out this is not just a feeling. People have studied it.

A team at the University of Washington taught Python to adults who had never written a line of code. They measured two things first: how good each person was at learning languages, and how good they were at math. Language ability predicted who learned to code fastest. It beat math. Math explained almost nothing. Their models accounted for between 50 and 72 percent of the difference in how fast people learned, and language aptitude carried weight in every part of it.

> **The study:** Prat et al., "Relating Natural Language Aptitude to Individual Differences in Learning Programming Languages." Scientific Reports, 2020.
> https://www.nature.com/articles/s41598-020-60661-8

Portuguese taught me the shape. Kubernetes just handed me new words to pour into it.

---

*Also on the blog: [projectpattie.com](https://projectpattie.com)*
