
v19-RT.efi:     file format pei-x86-64


Disassembly of section .text:

0000000000004000 <_start>:
    4000:	48 83 ec 08          	sub    $0x8,%rsp
    4004:	51                   	push   %rcx
    4005:	52                   	push   %rdx
    4006:	48 8d 3d f3 bf ff ff 	lea    -0x400d(%rip),%rdi        # 0 <_start-0x4000>
    400d:	48 8d 35 ec 9f 01 00 	lea    0x19fec(%rip),%rsi        # 1e000 <_DYNAMIC>
    4014:	59                   	pop    %rcx
    4015:	5a                   	pop    %rdx
    4016:	51                   	push   %rcx
    4017:	52                   	push   %rdx
    4018:	e8 b3 27 00 00       	call   67d0 <_relocate>
    401d:	5f                   	pop    %rdi
    401e:	5e                   	pop    %rsi
    401f:	e8 0c 0f 00 00       	call   4f30 <efi_main>
    4024:	48 83 c4 08          	add    $0x8,%rsp

0000000000004028 <.exit>:
    4028:	c3                   	ret
    4029:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4030:	00 00 00 
    4033:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    403a:	00 00 00 
    403d:	0f 1f 00             	nopl   (%rax)

0000000000004040 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv>:
    4040:	8b 05 42 91 01 00    	mov    0x19142(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
    4046:	85 c0                	test   %eax,%eax
    4048:	74 0e                	je     4058 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x18>
    404a:	8b 05 58 91 01 00    	mov    0x19158(%rip),%eax        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    4050:	0b 05 36 91 01 00    	or     0x19136(%rip),%eax        # 1d18c <_ZN10UEFIBridge17g_kusd_probe_doneE>
    4056:	74 08                	je     4060 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x20>
    4058:	c3                   	ret
    4059:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4060:	48 83 ec 28          	sub    $0x28,%rsp
    4064:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4069:	c7 05 19 91 01 00 01 	movl   $0x1,0x19119(%rip)        # 1d18c <_ZN10UEFIBridge17g_kusd_probe_doneE>
    4070:	00 00 00 
    4073:	a1 60 02 00 00 80 f7 	movabs 0xfffff78000000260,%eax
    407a:	ff ff 
    407c:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
    4081:	41 89 c0             	mov    %eax,%r8d
    4084:	a1 08 03 00 00 80 f7 	movabs 0xfffff78000000308,%eax
    408b:	ff ff 
    408d:	4d 89 c1             	mov    %r8,%r9
    4090:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
    4095:	41 89 c2             	mov    %eax,%r10d
    4098:	b8 0d 00 00 00       	mov    $0xd,%eax
    409d:	ee                   	out    %al,(%dx)
    409e:	b8 0a 00 00 00       	mov    $0xa,%eax
    40a3:	ee                   	out    %al,(%dx)
    40a4:	b8 5b 00 00 00       	mov    $0x5b,%eax
    40a9:	48 8d 0d 50 ff 00 00 	lea    0xff50(%rip),%rcx        # 14000 <_data>
    40b0:	48 83 c1 01          	add    $0x1,%rcx
    40b4:	ee                   	out    %al,(%dx)
    40b5:	0f b6 01             	movzbl (%rcx),%eax
    40b8:	84 c0                	test   %al,%al
    40ba:	75 f4                	jne    40b0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x70>
    40bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    40c1:	ee                   	out    %al,(%dx)
    40c2:	b8 42 00 00 00       	mov    $0x42,%eax
    40c7:	48 8d 0d 38 ff 00 00 	lea    0xff38(%rip),%rcx        # 14006 <_data+0x6>
    40ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
    40d3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    40da:	00 00 00 00 
    40de:	66 90                	xchg   %ax,%ax
    40e0:	48 83 c1 01          	add    $0x1,%rcx
    40e4:	ee                   	out    %al,(%dx)
    40e5:	0f b6 01             	movzbl (%rcx),%eax
    40e8:	84 c0                	test   %al,%al
    40ea:	75 f4                	jne    40e0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0xa0>
    40ec:	b8 5d 00 00 00       	mov    $0x5d,%eax
    40f1:	ee                   	out    %al,(%dx)
    40f2:	b8 20 00 00 00       	mov    $0x20,%eax
    40f7:	ee                   	out    %al,(%dx)
    40f8:	b8 6b 00 00 00       	mov    $0x6b,%eax
    40fd:	48 8d 0d 06 ff 00 00 	lea    0xff06(%rip),%rcx        # 1400a <_data+0xa>
    4104:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4109:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4110:	48 83 c1 01          	add    $0x1,%rcx
    4114:	ee                   	out    %al,(%dx)
    4115:	0f b6 01             	movzbl (%rcx),%eax
    4118:	84 c0                	test   %al,%al
    411a:	75 f4                	jne    4110 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0xd0>
    411c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4121:	48 8d 0d 9e ff 00 00 	lea    0xff9e(%rip),%rcx        # 140c6 <_data+0xc6>
    4128:	ba f8 03 00 00       	mov    $0x3f8,%edx
    412d:	0f 1f 00             	nopl   (%rax)
    4130:	48 83 c1 01          	add    $0x1,%rcx
    4134:	ee                   	out    %al,(%dx)
    4135:	0f b6 01             	movzbl (%rcx),%eax
    4138:	84 c0                	test   %al,%al
    413a:	75 f4                	jne    4130 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0xf0>
    413c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4141:	48 8d 3d b8 0c 01 00 	lea    0x10cb8(%rip),%rdi        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    4148:	ba f8 03 00 00       	mov    $0x3f8,%edx
    414d:	0f 1f 00             	nopl   (%rax)
    4150:	4c 89 c6             	mov    %r8,%rsi
    4153:	48 d3 ee             	shr    %cl,%rsi
    4156:	83 e6 0f             	and    $0xf,%esi
    4159:	0f b6 04 37          	movzbl (%rdi,%rsi,1),%eax
    415d:	ee                   	out    %al,(%dx)
    415e:	83 e9 04             	sub    $0x4,%ecx
    4161:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4164:	75 ea                	jne    4150 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x110>
    4166:	45 89 d3             	mov    %r10d,%r11d
    4169:	b8 0d 00 00 00       	mov    $0xd,%eax
    416e:	ee                   	out    %al,(%dx)
    416f:	b8 0a 00 00 00       	mov    $0xa,%eax
    4174:	ee                   	out    %al,(%dx)
    4175:	b8 5b 00 00 00       	mov    $0x5b,%eax
    417a:	48 8d 0d 7f fe 00 00 	lea    0xfe7f(%rip),%rcx        # 14000 <_data>
    4181:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4186:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    418d:	00 00 00 
    4190:	48 83 c1 01          	add    $0x1,%rcx
    4194:	ee                   	out    %al,(%dx)
    4195:	0f b6 01             	movzbl (%rcx),%eax
    4198:	84 c0                	test   %al,%al
    419a:	75 f4                	jne    4190 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x150>
    419c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    41a1:	ee                   	out    %al,(%dx)
    41a2:	b8 42 00 00 00       	mov    $0x42,%eax
    41a7:	48 8d 0d 58 fe 00 00 	lea    0xfe58(%rip),%rcx        # 14006 <_data+0x6>
    41ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    41b3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    41ba:	00 00 00 00 
    41be:	66 90                	xchg   %ax,%ax
    41c0:	48 83 c1 01          	add    $0x1,%rcx
    41c4:	ee                   	out    %al,(%dx)
    41c5:	0f b6 01             	movzbl (%rcx),%eax
    41c8:	84 c0                	test   %al,%al
    41ca:	75 f4                	jne    41c0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x180>
    41cc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    41d1:	ee                   	out    %al,(%dx)
    41d2:	b8 20 00 00 00       	mov    $0x20,%eax
    41d7:	ee                   	out    %al,(%dx)
    41d8:	b8 6b 00 00 00       	mov    $0x6b,%eax
    41dd:	48 8d 0d 35 fe 00 00 	lea    0xfe35(%rip),%rcx        # 14019 <_data+0x19>
    41e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    41e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    41f0:	48 83 c1 01          	add    $0x1,%rcx
    41f4:	ee                   	out    %al,(%dx)
    41f5:	0f b6 01             	movzbl (%rcx),%eax
    41f8:	84 c0                	test   %al,%al
    41fa:	75 f4                	jne    41f0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x1b0>
    41fc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4201:	48 8d 0d be fe 00 00 	lea    0xfebe(%rip),%rcx        # 140c6 <_data+0xc6>
    4208:	ba f8 03 00 00       	mov    $0x3f8,%edx
    420d:	0f 1f 00             	nopl   (%rax)
    4210:	48 83 c1 01          	add    $0x1,%rcx
    4214:	ee                   	out    %al,(%dx)
    4215:	0f b6 01             	movzbl (%rcx),%eax
    4218:	84 c0                	test   %al,%al
    421a:	75 f4                	jne    4210 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x1d0>
    421c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4221:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4226:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    422d:	00 00 00 
    4230:	4c 89 de             	mov    %r11,%rsi
    4233:	48 d3 ee             	shr    %cl,%rsi
    4236:	83 e6 0f             	and    $0xf,%esi
    4239:	0f b6 04 37          	movzbl (%rdi,%rsi,1),%eax
    423d:	ee                   	out    %al,(%dx)
    423e:	83 e9 04             	sub    $0x4,%ecx
    4241:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4244:	75 ea                	jne    4230 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x1f0>
    4246:	41 8d 81 68 c5 ff ff 	lea    -0x3a98(%r9),%eax
    424d:	3d 06 4c 01 00       	cmp    $0x14c06,%eax
    4252:	0f 86 f0 01 00 00    	jbe    4448 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x408>
    4258:	41 8d 82 68 c5 ff ff 	lea    -0x3a98(%r10),%eax
    425f:	3d 06 4c 01 00       	cmp    $0x14c06,%eax
    4264:	0f 87 3e 01 00 00    	ja     43a8 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x368>
    426a:	44 89 15 37 8f 01 00 	mov    %r10d,0x18f37(%rip)        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    4271:	b8 0d 00 00 00       	mov    $0xd,%eax
    4276:	ee                   	out    %al,(%dx)
    4277:	b8 0a 00 00 00       	mov    $0xa,%eax
    427c:	ee                   	out    %al,(%dx)
    427d:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4282:	48 8d 0d 77 fd 00 00 	lea    0xfd77(%rip),%rcx        # 14000 <_data>
    4289:	ba f8 03 00 00       	mov    $0x3f8,%edx
    428e:	66 90                	xchg   %ax,%ax
    4290:	48 83 c1 01          	add    $0x1,%rcx
    4294:	ee                   	out    %al,(%dx)
    4295:	0f b6 01             	movzbl (%rcx),%eax
    4298:	84 c0                	test   %al,%al
    429a:	75 f4                	jne    4290 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x250>
    429c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    42a1:	ee                   	out    %al,(%dx)
    42a2:	b8 42 00 00 00       	mov    $0x42,%eax
    42a7:	48 8d 0d 58 fd 00 00 	lea    0xfd58(%rip),%rcx        # 14006 <_data+0x6>
    42ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    42b3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    42ba:	00 00 00 00 
    42be:	66 90                	xchg   %ax,%ax
    42c0:	48 83 c1 01          	add    $0x1,%rcx
    42c4:	ee                   	out    %al,(%dx)
    42c5:	0f b6 01             	movzbl (%rcx),%eax
    42c8:	84 c0                	test   %al,%al
    42ca:	75 f4                	jne    42c0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x280>
    42cc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    42d1:	ee                   	out    %al,(%dx)
    42d2:	b8 20 00 00 00       	mov    $0x20,%eax
    42d7:	ee                   	out    %al,(%dx)
    42d8:	b8 6c 00 00 00       	mov    $0x6c,%eax
    42dd:	48 8d 0d cc 01 01 00 	lea    0x101cc(%rip),%rcx        # 144b0 <_data+0x4b0>
    42e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    42e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    42f0:	48 83 c1 01          	add    $0x1,%rcx
    42f4:	ee                   	out    %al,(%dx)
    42f5:	0f b6 01             	movzbl (%rcx),%eax
    42f8:	84 c0                	test   %al,%al
    42fa:	75 f4                	jne    42f0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x2b0>
    42fc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4301:	ee                   	out    %al,(%dx)
    4302:	c6 44 24 14 00       	movb   $0x0,0x14(%rsp)
    4307:	be 13 00 00 00       	mov    $0x13,%esi
    430c:	48 89 e1             	mov    %rsp,%rcx
    430f:	49 b8 cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r8
    4316:	cc cc cc 
    4319:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4320:	00 00 00 00 
    4324:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    432b:	00 00 00 00 
    432f:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4336:	00 00 00 00 
    433a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    4340:	4c 89 d8             	mov    %r11,%rax
    4343:	49 89 f1             	mov    %rsi,%r9
    4346:	49 f7 e0             	mul    %r8
    4349:	4c 89 d8             	mov    %r11,%rax
    434c:	48 c1 ea 03          	shr    $0x3,%rdx
    4350:	48 8d 3c 92          	lea    (%rdx,%rdx,4),%rdi
    4354:	48 01 ff             	add    %rdi,%rdi
    4357:	48 29 f8             	sub    %rdi,%rax
    435a:	4c 89 df             	mov    %r11,%rdi
    435d:	49 89 d3             	mov    %rdx,%r11
    4360:	83 c0 30             	add    $0x30,%eax
    4363:	48 83 ff 09          	cmp    $0x9,%rdi
    4367:	40 0f 97 c7          	seta   %dil
    436b:	85 f6                	test   %esi,%esi
    436d:	88 04 31             	mov    %al,(%rcx,%rsi,1)
    4370:	0f 95 c2             	setne  %dl
    4373:	48 83 ee 01          	sub    $0x1,%rsi
    4377:	40 84 d7             	test   %dl,%dil
    437a:	75 c4                	jne    4340 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x300>
    437c:	4d 63 c9             	movslq %r9d,%r9
    437f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4384:	4c 01 c9             	add    %r9,%rcx
    4387:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    438e:	00 00 
    4390:	48 83 c1 01          	add    $0x1,%rcx
    4394:	ee                   	out    %al,(%dx)
    4395:	0f b6 01             	movzbl (%rcx),%eax
    4398:	84 c0                	test   %al,%al
    439a:	75 f4                	jne    4390 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x350>
    439c:	48 83 c4 28          	add    $0x28,%rsp
    43a0:	c3                   	ret
    43a1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    43a8:	b8 0d 00 00 00       	mov    $0xd,%eax
    43ad:	ee                   	out    %al,(%dx)
    43ae:	b8 0a 00 00 00       	mov    $0xa,%eax
    43b3:	ee                   	out    %al,(%dx)
    43b4:	b8 5b 00 00 00       	mov    $0x5b,%eax
    43b9:	48 8d 0d 40 fc 00 00 	lea    0xfc40(%rip),%rcx        # 14000 <_data>
    43c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
    43c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    43cc:	00 00 00 00 
    43d0:	48 83 c1 01          	add    $0x1,%rcx
    43d4:	ee                   	out    %al,(%dx)
    43d5:	0f b6 01             	movzbl (%rcx),%eax
    43d8:	84 c0                	test   %al,%al
    43da:	75 f4                	jne    43d0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x390>
    43dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    43e1:	ee                   	out    %al,(%dx)
    43e2:	b8 42 00 00 00       	mov    $0x42,%eax
    43e7:	48 8d 0d 18 fc 00 00 	lea    0xfc18(%rip),%rcx        # 14006 <_data+0x6>
    43ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    43f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    43fa:	00 00 00 00 
    43fe:	66 90                	xchg   %ax,%ax
    4400:	48 83 c1 01          	add    $0x1,%rcx
    4404:	ee                   	out    %al,(%dx)
    4405:	0f b6 01             	movzbl (%rcx),%eax
    4408:	84 c0                	test   %al,%al
    440a:	75 f4                	jne    4400 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x3c0>
    440c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4411:	ee                   	out    %al,(%dx)
    4412:	b8 20 00 00 00       	mov    $0x20,%eax
    4417:	ee                   	out    %al,(%dx)
    4418:	b8 6b 00 00 00       	mov    $0x6b,%eax
    441d:	48 8d 0d ac 00 01 00 	lea    0x100ac(%rip),%rcx        # 144d0 <_data+0x4d0>
    4424:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4429:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4430:	48 83 c1 01          	add    $0x1,%rcx
    4434:	ee                   	out    %al,(%dx)
    4435:	0f b6 01             	movzbl (%rcx),%eax
    4438:	84 c0                	test   %al,%al
    443a:	75 f4                	jne    4430 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x3f0>
    443c:	e9 5b ff ff ff       	jmp    439c <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x35c>
    4441:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4448:	44 89 0d 59 8d 01 00 	mov    %r9d,0x18d59(%rip)        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    444f:	b8 0d 00 00 00       	mov    $0xd,%eax
    4454:	ee                   	out    %al,(%dx)
    4455:	b8 0a 00 00 00       	mov    $0xa,%eax
    445a:	ee                   	out    %al,(%dx)
    445b:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4460:	48 8d 0d 99 fb 00 00 	lea    0xfb99(%rip),%rcx        # 14000 <_data>
    4467:	ba f8 03 00 00       	mov    $0x3f8,%edx
    446c:	0f 1f 40 00          	nopl   0x0(%rax)
    4470:	48 83 c1 01          	add    $0x1,%rcx
    4474:	ee                   	out    %al,(%dx)
    4475:	0f b6 01             	movzbl (%rcx),%eax
    4478:	84 c0                	test   %al,%al
    447a:	75 f4                	jne    4470 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x430>
    447c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4481:	ee                   	out    %al,(%dx)
    4482:	b8 42 00 00 00       	mov    $0x42,%eax
    4487:	48 8d 0d 78 fb 00 00 	lea    0xfb78(%rip),%rcx        # 14006 <_data+0x6>
    448e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4493:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    449a:	00 00 00 00 
    449e:	66 90                	xchg   %ax,%ax
    44a0:	48 83 c1 01          	add    $0x1,%rcx
    44a4:	ee                   	out    %al,(%dx)
    44a5:	0f b6 01             	movzbl (%rcx),%eax
    44a8:	84 c0                	test   %al,%al
    44aa:	75 f4                	jne    44a0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x460>
    44ac:	b8 5d 00 00 00       	mov    $0x5d,%eax
    44b1:	ee                   	out    %al,(%dx)
    44b2:	b8 20 00 00 00       	mov    $0x20,%eax
    44b7:	ee                   	out    %al,(%dx)
    44b8:	b8 6c 00 00 00       	mov    $0x6c,%eax
    44bd:	48 8d 0d c4 ff 00 00 	lea    0xffc4(%rip),%rcx        # 14488 <_data+0x488>
    44c4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    44c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    44d0:	48 83 c1 01          	add    $0x1,%rcx
    44d4:	ee                   	out    %al,(%dx)
    44d5:	0f b6 01             	movzbl (%rcx),%eax
    44d8:	84 c0                	test   %al,%al
    44da:	75 f4                	jne    44d0 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x490>
    44dc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    44e1:	ee                   	out    %al,(%dx)
    44e2:	c6 44 24 14 00       	movb   $0x0,0x14(%rsp)
    44e7:	be 13 00 00 00       	mov    $0x13,%esi
    44ec:	48 89 e1             	mov    %rsp,%rcx
    44ef:	49 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r10
    44f6:	cc cc cc 
    44f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4500:	4c 89 c0             	mov    %r8,%rax
    4503:	49 f7 e2             	mul    %r10
    4506:	4c 89 c0             	mov    %r8,%rax
    4509:	48 c1 ea 03          	shr    $0x3,%rdx
    450d:	48 8d 3c 92          	lea    (%rdx,%rdx,4),%rdi
    4511:	48 01 ff             	add    %rdi,%rdi
    4514:	48 29 f8             	sub    %rdi,%rax
    4517:	4c 89 c7             	mov    %r8,%rdi
    451a:	49 89 d0             	mov    %rdx,%r8
    451d:	48 89 f2             	mov    %rsi,%rdx
    4520:	83 c0 30             	add    $0x30,%eax
    4523:	48 83 ff 09          	cmp    $0x9,%rdi
    4527:	41 0f 97 c1          	seta   %r9b
    452b:	85 f6                	test   %esi,%esi
    452d:	88 04 31             	mov    %al,(%rcx,%rsi,1)
    4530:	40 0f 95 c7          	setne  %dil
    4534:	48 83 ee 01          	sub    $0x1,%rsi
    4538:	41 84 f9             	test   %dil,%r9b
    453b:	75 c3                	jne    4500 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x4c0>
    453d:	48 63 d2             	movslq %edx,%rdx
    4540:	48 01 d1             	add    %rdx,%rcx
    4543:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4548:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    454f:	00 
    4550:	48 83 c1 01          	add    $0x1,%rcx
    4554:	ee                   	out    %al,(%dx)
    4555:	0f b6 01             	movzbl (%rcx),%eax
    4558:	84 c0                	test   %al,%al
    455a:	75 f4                	jne    4550 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x510>
    455c:	e9 3b fe ff ff       	jmp    439c <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv+0x35c>
    4561:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4568:	00 00 00 00 
    456c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000004570 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_>:
    4570:	57                   	push   %rdi
    4571:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4576:	b8 0d 00 00 00       	mov    $0xd,%eax
    457b:	56                   	push   %rsi
    457c:	53                   	push   %rbx
    457d:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
    4584:	0f 29 34 24          	movaps %xmm6,(%rsp)
    4588:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
    458d:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
    4593:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
    4599:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
    459f:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
    45a5:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
    45ab:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
    45b1:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
    45b8:	00 00 
    45ba:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
    45c1:	00 00 
    45c3:	ee                   	out    %al,(%dx)
    45c4:	b8 0a 00 00 00       	mov    $0xa,%eax
    45c9:	ee                   	out    %al,(%dx)
    45ca:	b8 5b 00 00 00       	mov    $0x5b,%eax
    45cf:	48 8d 0d 2a fa 00 00 	lea    0xfa2a(%rip),%rcx        # 14000 <_data>
    45d6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    45dd:	00 00 00 
    45e0:	48 83 c1 01          	add    $0x1,%rcx
    45e4:	ee                   	out    %al,(%dx)
    45e5:	0f b6 01             	movzbl (%rcx),%eax
    45e8:	84 c0                	test   %al,%al
    45ea:	75 f4                	jne    45e0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x70>
    45ec:	b8 5b 00 00 00       	mov    $0x5b,%eax
    45f1:	ee                   	out    %al,(%dx)
    45f2:	b8 56 00 00 00       	mov    $0x56,%eax
    45f7:	48 8d 0d 2d fa 00 00 	lea    0xfa2d(%rip),%rcx        # 1402b <_data+0x2b>
    45fe:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4603:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    460a:	00 00 00 00 
    460e:	66 90                	xchg   %ax,%ax
    4610:	48 83 c1 01          	add    $0x1,%rcx
    4614:	ee                   	out    %al,(%dx)
    4615:	0f b6 01             	movzbl (%rcx),%eax
    4618:	84 c0                	test   %al,%al
    461a:	75 f4                	jne    4610 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0xa0>
    461c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4621:	ee                   	out    %al,(%dx)
    4622:	b8 20 00 00 00       	mov    $0x20,%eax
    4627:	ee                   	out    %al,(%dx)
    4628:	b8 53 00 00 00       	mov    $0x53,%eax
    462d:	48 8d 0d e4 fe 00 00 	lea    0xfee4(%rip),%rcx        # 14518 <_data+0x518>
    4634:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4639:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4640:	48 83 c1 01          	add    $0x1,%rcx
    4644:	ee                   	out    %al,(%dx)
    4645:	0f b6 01             	movzbl (%rcx),%eax
    4648:	84 c0                	test   %al,%al
    464a:	75 f4                	jne    4640 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0xd0>
    464c:	4c 8b 15 f5 74 01 00 	mov    0x174f5(%rip),%r10        # 1bb48 <_ZN10UEFIBridgeL10g_va_graphE+0x28>
    4653:	41 80 7a 30 00       	cmpb   $0x0,0x30(%r10)
    4658:	0f 85 28 08 00 00    	jne    4e86 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x916>
    465e:	48 8d 05 bb 8b 01 00 	lea    0x18bbb(%rip),%rax        # 1d220 <RT>
    4665:	4c 89 15 ac 86 01 00 	mov    %r10,0x186ac(%rip)        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
    466c:	4c 8b 08             	mov    (%rax),%r9
    466f:	49 8b 71 18          	mov    0x18(%r9),%rsi
    4673:	49 89 72 08          	mov    %rsi,0x8(%r10)
    4677:	49 8b 59 48          	mov    0x48(%r9),%rbx
    467b:	49 89 5a 10          	mov    %rbx,0x10(%r10)
    467f:	4d 8b 59 58          	mov    0x58(%r9),%r11
    4683:	4d 89 5a 18          	mov    %r11,0x18(%r10)
    4687:	49 8b 41 50          	mov    0x50(%r9),%rax
    468b:	49 89 42 20          	mov    %rax,0x20(%r10)
    468f:	49 8b 41 30          	mov    0x30(%r9),%rax
    4693:	49 89 42 28          	mov    %rax,0x28(%r10)
    4697:	b8 0d 00 00 00       	mov    $0xd,%eax
    469c:	ee                   	out    %al,(%dx)
    469d:	b8 0a 00 00 00       	mov    $0xa,%eax
    46a2:	ee                   	out    %al,(%dx)
    46a3:	b8 5b 00 00 00       	mov    $0x5b,%eax
    46a8:	48 8d 0d 51 f9 00 00 	lea    0xf951(%rip),%rcx        # 14000 <_data>
    46af:	ba f8 03 00 00       	mov    $0x3f8,%edx
    46b4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    46bb:	00 00 00 00 
    46bf:	90                   	nop
    46c0:	48 83 c1 01          	add    $0x1,%rcx
    46c4:	ee                   	out    %al,(%dx)
    46c5:	0f b6 01             	movzbl (%rcx),%eax
    46c8:	84 c0                	test   %al,%al
    46ca:	75 f4                	jne    46c0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x150>
    46cc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    46d1:	ee                   	out    %al,(%dx)
    46d2:	b8 52 00 00 00       	mov    $0x52,%eax
    46d7:	48 8d 0d 4f fc 00 00 	lea    0xfc4f(%rip),%rcx        # 1432d <_data+0x32d>
    46de:	ba f8 03 00 00       	mov    $0x3f8,%edx
    46e3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    46ea:	00 00 00 00 
    46ee:	66 90                	xchg   %ax,%ax
    46f0:	48 83 c1 01          	add    $0x1,%rcx
    46f4:	ee                   	out    %al,(%dx)
    46f5:	0f b6 01             	movzbl (%rcx),%eax
    46f8:	84 c0                	test   %al,%al
    46fa:	75 f4                	jne    46f0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x180>
    46fc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4701:	ee                   	out    %al,(%dx)
    4702:	b8 20 00 00 00       	mov    $0x20,%eax
    4707:	ee                   	out    %al,(%dx)
    4708:	b8 6f 00 00 00       	mov    $0x6f,%eax
    470d:	48 8d 0d 7c fb 00 00 	lea    0xfb7c(%rip),%rcx        # 14290 <_data+0x290>
    4714:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4719:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4720:	48 83 c1 01          	add    $0x1,%rcx
    4724:	ee                   	out    %al,(%dx)
    4725:	0f b6 01             	movzbl (%rcx),%eax
    4728:	84 c0                	test   %al,%al
    472a:	75 f4                	jne    4720 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x1b0>
    472c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4731:	48 8d 0d 8e f9 00 00 	lea    0xf98e(%rip),%rcx        # 140c6 <_data+0xc6>
    4738:	ba f8 03 00 00       	mov    $0x3f8,%edx
    473d:	0f 1f 00             	nopl   (%rax)
    4740:	48 83 c1 01          	add    $0x1,%rcx
    4744:	ee                   	out    %al,(%dx)
    4745:	0f b6 01             	movzbl (%rcx),%eax
    4748:	84 c0                	test   %al,%al
    474a:	75 f4                	jne    4740 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x1d0>
    474c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4751:	4c 8d 05 a8 06 01 00 	lea    0x106a8(%rip),%r8        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    4758:	ba f8 03 00 00       	mov    $0x3f8,%edx
    475d:	0f 1f 00             	nopl   (%rax)
    4760:	48 89 f0             	mov    %rsi,%rax
    4763:	48 d3 e8             	shr    %cl,%rax
    4766:	83 e0 0f             	and    $0xf,%eax
    4769:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    476e:	ee                   	out    %al,(%dx)
    476f:	83 e9 04             	sub    $0x4,%ecx
    4772:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4775:	75 e9                	jne    4760 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x1f0>
    4777:	b8 0d 00 00 00       	mov    $0xd,%eax
    477c:	ee                   	out    %al,(%dx)
    477d:	b8 0a 00 00 00       	mov    $0xa,%eax
    4782:	ee                   	out    %al,(%dx)
    4783:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4788:	48 8d 0d 71 f8 00 00 	lea    0xf871(%rip),%rcx        # 14000 <_data>
    478f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4794:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    479b:	00 00 00 00 
    479f:	90                   	nop
    47a0:	48 83 c1 01          	add    $0x1,%rcx
    47a4:	ee                   	out    %al,(%dx)
    47a5:	0f b6 01             	movzbl (%rcx),%eax
    47a8:	84 c0                	test   %al,%al
    47aa:	75 f4                	jne    47a0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x230>
    47ac:	b8 5b 00 00 00       	mov    $0x5b,%eax
    47b1:	ee                   	out    %al,(%dx)
    47b2:	b8 52 00 00 00       	mov    $0x52,%eax
    47b7:	48 8d 0d 6f fb 00 00 	lea    0xfb6f(%rip),%rcx        # 1432d <_data+0x32d>
    47be:	ba f8 03 00 00       	mov    $0x3f8,%edx
    47c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    47ca:	00 00 00 00 
    47ce:	66 90                	xchg   %ax,%ax
    47d0:	48 83 c1 01          	add    $0x1,%rcx
    47d4:	ee                   	out    %al,(%dx)
    47d5:	0f b6 01             	movzbl (%rcx),%eax
    47d8:	84 c0                	test   %al,%al
    47da:	75 f4                	jne    47d0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x260>
    47dc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    47e1:	ee                   	out    %al,(%dx)
    47e2:	b8 20 00 00 00       	mov    $0x20,%eax
    47e7:	ee                   	out    %al,(%dx)
    47e8:	b8 6f 00 00 00       	mov    $0x6f,%eax
    47ed:	48 8d 0d b1 fa 00 00 	lea    0xfab1(%rip),%rcx        # 142a5 <_data+0x2a5>
    47f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    47f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4800:	48 83 c1 01          	add    $0x1,%rcx
    4804:	ee                   	out    %al,(%dx)
    4805:	0f b6 01             	movzbl (%rcx),%eax
    4808:	84 c0                	test   %al,%al
    480a:	75 f4                	jne    4800 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x290>
    480c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4811:	48 8d 0d ae f8 00 00 	lea    0xf8ae(%rip),%rcx        # 140c6 <_data+0xc6>
    4818:	ba f8 03 00 00       	mov    $0x3f8,%edx
    481d:	0f 1f 00             	nopl   (%rax)
    4820:	48 83 c1 01          	add    $0x1,%rcx
    4824:	ee                   	out    %al,(%dx)
    4825:	0f b6 01             	movzbl (%rcx),%eax
    4828:	84 c0                	test   %al,%al
    482a:	75 f4                	jne    4820 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x2b0>
    482c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4831:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4836:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    483d:	00 00 00 
    4840:	48 89 d8             	mov    %rbx,%rax
    4843:	48 d3 e8             	shr    %cl,%rax
    4846:	83 e0 0f             	and    $0xf,%eax
    4849:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    484e:	ee                   	out    %al,(%dx)
    484f:	83 e9 04             	sub    $0x4,%ecx
    4852:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4855:	75 e9                	jne    4840 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x2d0>
    4857:	b8 0d 00 00 00       	mov    $0xd,%eax
    485c:	ee                   	out    %al,(%dx)
    485d:	b8 0a 00 00 00       	mov    $0xa,%eax
    4862:	ee                   	out    %al,(%dx)
    4863:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4868:	48 8d 0d 91 f7 00 00 	lea    0xf791(%rip),%rcx        # 14000 <_data>
    486f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4874:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    487b:	00 00 00 00 
    487f:	90                   	nop
    4880:	48 83 c1 01          	add    $0x1,%rcx
    4884:	ee                   	out    %al,(%dx)
    4885:	0f b6 01             	movzbl (%rcx),%eax
    4888:	84 c0                	test   %al,%al
    488a:	75 f4                	jne    4880 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x310>
    488c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4891:	ee                   	out    %al,(%dx)
    4892:	b8 52 00 00 00       	mov    $0x52,%eax
    4897:	48 8d 0d 8f fa 00 00 	lea    0xfa8f(%rip),%rcx        # 1432d <_data+0x32d>
    489e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    48a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    48aa:	00 00 00 00 
    48ae:	66 90                	xchg   %ax,%ax
    48b0:	48 83 c1 01          	add    $0x1,%rcx
    48b4:	ee                   	out    %al,(%dx)
    48b5:	0f b6 01             	movzbl (%rcx),%eax
    48b8:	84 c0                	test   %al,%al
    48ba:	75 f4                	jne    48b0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x340>
    48bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    48c1:	ee                   	out    %al,(%dx)
    48c2:	b8 20 00 00 00       	mov    $0x20,%eax
    48c7:	ee                   	out    %al,(%dx)
    48c8:	b8 6f 00 00 00       	mov    $0x6f,%eax
    48cd:	48 8d 0d e6 f9 00 00 	lea    0xf9e6(%rip),%rcx        # 142ba <_data+0x2ba>
    48d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    48d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    48e0:	48 83 c1 01          	add    $0x1,%rcx
    48e4:	ee                   	out    %al,(%dx)
    48e5:	0f b6 01             	movzbl (%rcx),%eax
    48e8:	84 c0                	test   %al,%al
    48ea:	75 f4                	jne    48e0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x370>
    48ec:	b8 3d 00 00 00       	mov    $0x3d,%eax
    48f1:	48 8d 0d ce f7 00 00 	lea    0xf7ce(%rip),%rcx        # 140c6 <_data+0xc6>
    48f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    48fd:	0f 1f 00             	nopl   (%rax)
    4900:	48 83 c1 01          	add    $0x1,%rcx
    4904:	ee                   	out    %al,(%dx)
    4905:	0f b6 01             	movzbl (%rcx),%eax
    4908:	84 c0                	test   %al,%al
    490a:	75 f4                	jne    4900 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x390>
    490c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4911:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4916:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    491d:	00 00 00 
    4920:	4c 89 d8             	mov    %r11,%rax
    4923:	48 d3 e8             	shr    %cl,%rax
    4926:	83 e0 0f             	and    $0xf,%eax
    4929:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    492e:	ee                   	out    %al,(%dx)
    492f:	83 e9 04             	sub    $0x4,%ecx
    4932:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4935:	75 e9                	jne    4920 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x3b0>
    4937:	48 8d 35 02 d7 00 00 	lea    0xd702(%rip),%rsi        # 12040 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES>
    493e:	48 8d 1d 8b cc 00 00 	lea    0xcc8b(%rip),%rbx        # 115d0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv>
    4945:	b8 0d 00 00 00       	mov    $0xd,%eax
    494a:	4c 8d 1d 7f c3 00 00 	lea    0xc37f(%rip),%r11        # 10cd0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv>
    4951:	49 89 71 18          	mov    %rsi,0x18(%r9)
    4955:	49 89 59 48          	mov    %rbx,0x48(%r9)
    4959:	4d 89 59 58          	mov    %r11,0x58(%r9)
    495d:	ee                   	out    %al,(%dx)
    495e:	b8 0a 00 00 00       	mov    $0xa,%eax
    4963:	ee                   	out    %al,(%dx)
    4964:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4969:	48 8d 0d 90 f6 00 00 	lea    0xf690(%rip),%rcx        # 14000 <_data>
    4970:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4975:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    497c:	00 00 00 00 
    4980:	48 83 c1 01          	add    $0x1,%rcx
    4984:	ee                   	out    %al,(%dx)
    4985:	0f b6 01             	movzbl (%rcx),%eax
    4988:	84 c0                	test   %al,%al
    498a:	75 f4                	jne    4980 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x410>
    498c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4991:	ee                   	out    %al,(%dx)
    4992:	b8 52 00 00 00       	mov    $0x52,%eax
    4997:	48 8d 0d 8f f9 00 00 	lea    0xf98f(%rip),%rcx        # 1432d <_data+0x32d>
    499e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    49a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    49aa:	00 00 00 00 
    49ae:	66 90                	xchg   %ax,%ax
    49b0:	48 83 c1 01          	add    $0x1,%rcx
    49b4:	ee                   	out    %al,(%dx)
    49b5:	0f b6 01             	movzbl (%rcx),%eax
    49b8:	84 c0                	test   %al,%al
    49ba:	75 f4                	jne    49b0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x440>
    49bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    49c1:	ee                   	out    %al,(%dx)
    49c2:	b8 20 00 00 00       	mov    $0x20,%eax
    49c7:	ee                   	out    %al,(%dx)
    49c8:	b8 68 00 00 00       	mov    $0x68,%eax
    49cd:	48 8d 0d fb f8 00 00 	lea    0xf8fb(%rip),%rcx        # 142cf <_data+0x2cf>
    49d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    49d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    49e0:	48 83 c1 01          	add    $0x1,%rcx
    49e4:	ee                   	out    %al,(%dx)
    49e5:	0f b6 01             	movzbl (%rcx),%eax
    49e8:	84 c0                	test   %al,%al
    49ea:	75 f4                	jne    49e0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x470>
    49ec:	b8 3d 00 00 00       	mov    $0x3d,%eax
    49f1:	48 8d 0d ce f6 00 00 	lea    0xf6ce(%rip),%rcx        # 140c6 <_data+0xc6>
    49f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    49fd:	0f 1f 00             	nopl   (%rax)
    4a00:	48 83 c1 01          	add    $0x1,%rcx
    4a04:	ee                   	out    %al,(%dx)
    4a05:	0f b6 01             	movzbl (%rcx),%eax
    4a08:	84 c0                	test   %al,%al
    4a0a:	75 f4                	jne    4a00 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x490>
    4a0c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4a11:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4a16:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4a1d:	00 00 00 
    4a20:	48 89 f0             	mov    %rsi,%rax
    4a23:	48 d3 e8             	shr    %cl,%rax
    4a26:	83 e0 0f             	and    $0xf,%eax
    4a29:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    4a2e:	ee                   	out    %al,(%dx)
    4a2f:	83 e9 04             	sub    $0x4,%ecx
    4a32:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4a35:	75 e9                	jne    4a20 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x4b0>
    4a37:	b8 0d 00 00 00       	mov    $0xd,%eax
    4a3c:	ee                   	out    %al,(%dx)
    4a3d:	b8 0a 00 00 00       	mov    $0xa,%eax
    4a42:	ee                   	out    %al,(%dx)
    4a43:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4a48:	48 8d 0d b1 f5 00 00 	lea    0xf5b1(%rip),%rcx        # 14000 <_data>
    4a4f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4a54:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4a5b:	00 00 00 00 
    4a5f:	90                   	nop
    4a60:	48 83 c1 01          	add    $0x1,%rcx
    4a64:	ee                   	out    %al,(%dx)
    4a65:	0f b6 01             	movzbl (%rcx),%eax
    4a68:	84 c0                	test   %al,%al
    4a6a:	75 f4                	jne    4a60 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x4f0>
    4a6c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4a71:	ee                   	out    %al,(%dx)
    4a72:	b8 52 00 00 00       	mov    $0x52,%eax
    4a77:	48 8d 0d af f8 00 00 	lea    0xf8af(%rip),%rcx        # 1432d <_data+0x32d>
    4a7e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4a83:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4a8a:	00 00 00 00 
    4a8e:	66 90                	xchg   %ax,%ax
    4a90:	48 83 c1 01          	add    $0x1,%rcx
    4a94:	ee                   	out    %al,(%dx)
    4a95:	0f b6 01             	movzbl (%rcx),%eax
    4a98:	84 c0                	test   %al,%al
    4a9a:	75 f4                	jne    4a90 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x520>
    4a9c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4aa1:	ee                   	out    %al,(%dx)
    4aa2:	b8 20 00 00 00       	mov    $0x20,%eax
    4aa7:	ee                   	out    %al,(%dx)
    4aa8:	b8 68 00 00 00       	mov    $0x68,%eax
    4aad:	48 8d 0d 30 f8 00 00 	lea    0xf830(%rip),%rcx        # 142e4 <_data+0x2e4>
    4ab4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4ab9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4ac0:	48 83 c1 01          	add    $0x1,%rcx
    4ac4:	ee                   	out    %al,(%dx)
    4ac5:	0f b6 01             	movzbl (%rcx),%eax
    4ac8:	84 c0                	test   %al,%al
    4aca:	75 f4                	jne    4ac0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x550>
    4acc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4ad1:	48 8d 0d ee f5 00 00 	lea    0xf5ee(%rip),%rcx        # 140c6 <_data+0xc6>
    4ad8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4add:	0f 1f 00             	nopl   (%rax)
    4ae0:	48 83 c1 01          	add    $0x1,%rcx
    4ae4:	ee                   	out    %al,(%dx)
    4ae5:	0f b6 01             	movzbl (%rcx),%eax
    4ae8:	84 c0                	test   %al,%al
    4aea:	75 f4                	jne    4ae0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x570>
    4aec:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4af1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4af6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4afd:	00 00 00 
    4b00:	48 89 d8             	mov    %rbx,%rax
    4b03:	48 d3 e8             	shr    %cl,%rax
    4b06:	83 e0 0f             	and    $0xf,%eax
    4b09:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    4b0e:	ee                   	out    %al,(%dx)
    4b0f:	83 e9 04             	sub    $0x4,%ecx
    4b12:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4b15:	75 e9                	jne    4b00 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x590>
    4b17:	b8 0d 00 00 00       	mov    $0xd,%eax
    4b1c:	ee                   	out    %al,(%dx)
    4b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
    4b22:	ee                   	out    %al,(%dx)
    4b23:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4b28:	48 8d 0d d1 f4 00 00 	lea    0xf4d1(%rip),%rcx        # 14000 <_data>
    4b2f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4b34:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4b3b:	00 00 00 00 
    4b3f:	90                   	nop
    4b40:	48 83 c1 01          	add    $0x1,%rcx
    4b44:	ee                   	out    %al,(%dx)
    4b45:	0f b6 01             	movzbl (%rcx),%eax
    4b48:	84 c0                	test   %al,%al
    4b4a:	75 f4                	jne    4b40 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x5d0>
    4b4c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4b51:	ee                   	out    %al,(%dx)
    4b52:	b8 52 00 00 00       	mov    $0x52,%eax
    4b57:	48 8d 0d cf f7 00 00 	lea    0xf7cf(%rip),%rcx        # 1432d <_data+0x32d>
    4b5e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4b63:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4b6a:	00 00 00 00 
    4b6e:	66 90                	xchg   %ax,%ax
    4b70:	48 83 c1 01          	add    $0x1,%rcx
    4b74:	ee                   	out    %al,(%dx)
    4b75:	0f b6 01             	movzbl (%rcx),%eax
    4b78:	84 c0                	test   %al,%al
    4b7a:	75 f4                	jne    4b70 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x600>
    4b7c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4b81:	ee                   	out    %al,(%dx)
    4b82:	b8 20 00 00 00       	mov    $0x20,%eax
    4b87:	ee                   	out    %al,(%dx)
    4b88:	b8 68 00 00 00       	mov    $0x68,%eax
    4b8d:	48 8d 0d 65 f7 00 00 	lea    0xf765(%rip),%rcx        # 142f9 <_data+0x2f9>
    4b94:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4b99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4ba0:	48 83 c1 01          	add    $0x1,%rcx
    4ba4:	ee                   	out    %al,(%dx)
    4ba5:	0f b6 01             	movzbl (%rcx),%eax
    4ba8:	84 c0                	test   %al,%al
    4baa:	75 f4                	jne    4ba0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x630>
    4bac:	b8 3d 00 00 00       	mov    $0x3d,%eax
    4bb1:	48 8d 0d 0e f5 00 00 	lea    0xf50e(%rip),%rcx        # 140c6 <_data+0xc6>
    4bb8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4bbd:	0f 1f 00             	nopl   (%rax)
    4bc0:	48 83 c1 01          	add    $0x1,%rcx
    4bc4:	ee                   	out    %al,(%dx)
    4bc5:	0f b6 01             	movzbl (%rcx),%eax
    4bc8:	84 c0                	test   %al,%al
    4bca:	75 f4                	jne    4bc0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x650>
    4bcc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    4bd1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4bd6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4bdd:	00 00 00 
    4be0:	4c 89 d8             	mov    %r11,%rax
    4be3:	48 d3 e8             	shr    %cl,%rax
    4be6:	83 e0 0f             	and    $0xf,%eax
    4be9:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    4bee:	ee                   	out    %al,(%dx)
    4bef:	83 e9 04             	sub    $0x4,%ecx
    4bf2:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    4bf5:	75 e9                	jne    4be0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x670>
    4bf7:	45 8b 59 0c          	mov    0xc(%r9),%r11d
    4bfb:	41 c7 41 10 00 00 00 	movl   $0x0,0x10(%r9)
    4c02:	00 
    4c03:	4d 85 db             	test   %r11,%r11
    4c06:	0f 84 15 03 00 00    	je     4f21 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x9b1>
    4c0c:	4d 89 c8             	mov    %r9,%r8
    4c0f:	4d 01 cb             	add    %r9,%r11
    4c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    4c17:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    4c1e:	00 00 
    4c20:	41 0f b6 10          	movzbl (%r8),%edx
    4c24:	31 d0                	xor    %edx,%eax
    4c26:	ba 08 00 00 00       	mov    $0x8,%edx
    4c2b:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4c32:	00 00 00 00 
    4c36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4c3d:	00 00 00 
    4c40:	89 c1                	mov    %eax,%ecx
    4c42:	83 e0 01             	and    $0x1,%eax
    4c45:	f7 d8                	neg    %eax
    4c47:	d1 e9                	shr    $1,%ecx
    4c49:	25 20 83 b8 ed       	and    $0xedb88320,%eax
    4c4e:	31 c8                	xor    %ecx,%eax
    4c50:	83 ea 01             	sub    $0x1,%edx
    4c53:	75 eb                	jne    4c40 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x6d0>
    4c55:	49 83 c0 01          	add    $0x1,%r8
    4c59:	4d 39 d8             	cmp    %r11,%r8
    4c5c:	75 c2                	jne    4c20 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x6b0>
    4c5e:	f7 d0                	not    %eax
    4c60:	41 89 41 10          	mov    %eax,0x10(%r9)
    4c64:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4c69:	b8 0d 00 00 00       	mov    $0xd,%eax
    4c6e:	41 c6 42 30 01       	movb   $0x1,0x30(%r10)
    4c73:	ee                   	out    %al,(%dx)
    4c74:	b8 0a 00 00 00       	mov    $0xa,%eax
    4c79:	ee                   	out    %al,(%dx)
    4c7a:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4c7f:	48 8d 0d 7a f3 00 00 	lea    0xf37a(%rip),%rcx        # 14000 <_data>
    4c86:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4c8d:	00 00 00 
    4c90:	48 83 c1 01          	add    $0x1,%rcx
    4c94:	ee                   	out    %al,(%dx)
    4c95:	0f b6 01             	movzbl (%rcx),%eax
    4c98:	84 c0                	test   %al,%al
    4c9a:	75 f4                	jne    4c90 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x720>
    4c9c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4ca1:	ee                   	out    %al,(%dx)
    4ca2:	b8 52 00 00 00       	mov    $0x52,%eax
    4ca7:	48 8d 0d 7f f6 00 00 	lea    0xf67f(%rip),%rcx        # 1432d <_data+0x32d>
    4cae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4cb3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4cba:	00 00 00 00 
    4cbe:	66 90                	xchg   %ax,%ax
    4cc0:	48 83 c1 01          	add    $0x1,%rcx
    4cc4:	ee                   	out    %al,(%dx)
    4cc5:	0f b6 01             	movzbl (%rcx),%eax
    4cc8:	84 c0                	test   %al,%al
    4cca:	75 f4                	jne    4cc0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x750>
    4ccc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4cd1:	ee                   	out    %al,(%dx)
    4cd2:	b8 20 00 00 00       	mov    $0x20,%eax
    4cd7:	ee                   	out    %al,(%dx)
    4cd8:	b8 67 00 00 00       	mov    $0x67,%eax
    4cdd:	48 8d 0d 9c f8 00 00 	lea    0xf89c(%rip),%rcx        # 14580 <_data+0x580>
    4ce4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4ce9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4cf0:	48 83 c1 01          	add    $0x1,%rcx
    4cf4:	ee                   	out    %al,(%dx)
    4cf5:	0f b6 01             	movzbl (%rcx),%eax
    4cf8:	84 c0                	test   %al,%al
    4cfa:	75 f4                	jne    4cf0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x780>
    4cfc:	c7 05 aa 84 01 00 03 	movl   $0x3,0x184aa(%rip)        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
    4d03:	00 00 00 
    4d06:	e8 f5 7b 00 00       	call   c900 <_ZN10UEFIBridge9DiagWriteEv>
    4d0b:	48 8d 3d 0e 6e 01 00 	lea    0x16e0e(%rip),%rdi        # 1bb20 <_ZN10UEFIBridgeL10g_va_graphE>
    4d12:	e8 e9 d6 00 00       	call   12400 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE>
    4d17:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4d1c:	b8 0d 00 00 00       	mov    $0xd,%eax
    4d21:	c7 05 5d 84 01 00 01 	movl   $0x1,0x1845d(%rip)        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
    4d28:	00 00 00 
    4d2b:	ee                   	out    %al,(%dx)
    4d2c:	b8 0a 00 00 00       	mov    $0xa,%eax
    4d31:	ee                   	out    %al,(%dx)
    4d32:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4d37:	48 8d 0d c2 f2 00 00 	lea    0xf2c2(%rip),%rcx        # 14000 <_data>
    4d3e:	66 90                	xchg   %ax,%ax
    4d40:	48 83 c1 01          	add    $0x1,%rcx
    4d44:	ee                   	out    %al,(%dx)
    4d45:	0f b6 01             	movzbl (%rcx),%eax
    4d48:	84 c0                	test   %al,%al
    4d4a:	75 f4                	jne    4d40 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x7d0>
    4d4c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4d51:	ee                   	out    %al,(%dx)
    4d52:	b8 56 00 00 00       	mov    $0x56,%eax
    4d57:	48 8d 0d cd f2 00 00 	lea    0xf2cd(%rip),%rcx        # 1402b <_data+0x2b>
    4d5e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4d63:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4d6a:	00 00 00 00 
    4d6e:	66 90                	xchg   %ax,%ax
    4d70:	48 83 c1 01          	add    $0x1,%rcx
    4d74:	ee                   	out    %al,(%dx)
    4d75:	0f b6 01             	movzbl (%rcx),%eax
    4d78:	84 c0                	test   %al,%al
    4d7a:	75 f4                	jne    4d70 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x800>
    4d7c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4d81:	ee                   	out    %al,(%dx)
    4d82:	b8 20 00 00 00       	mov    $0x20,%eax
    4d87:	ee                   	out    %al,(%dx)
    4d88:	b8 76 00 00 00       	mov    $0x76,%eax
    4d8d:	48 8d 0d 2c f8 00 00 	lea    0xf82c(%rip),%rcx        # 145c0 <_data+0x5c0>
    4d94:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4d99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4da0:	48 83 c1 01          	add    $0x1,%rcx
    4da4:	ee                   	out    %al,(%dx)
    4da5:	0f b6 01             	movzbl (%rcx),%eax
    4da8:	84 c0                	test   %al,%al
    4daa:	75 f4                	jne    4da0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x830>
    4dac:	b8 0d 00 00 00       	mov    $0xd,%eax
    4db1:	ee                   	out    %al,(%dx)
    4db2:	b8 0a 00 00 00       	mov    $0xa,%eax
    4db7:	ee                   	out    %al,(%dx)
    4db8:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4dbd:	48 8d 0d 3c f2 00 00 	lea    0xf23c(%rip),%rcx        # 14000 <_data>
    4dc4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4dc9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4dd0:	48 83 c1 01          	add    $0x1,%rcx
    4dd4:	ee                   	out    %al,(%dx)
    4dd5:	0f b6 01             	movzbl (%rcx),%eax
    4dd8:	84 c0                	test   %al,%al
    4dda:	75 f4                	jne    4dd0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x860>
    4ddc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4de1:	ee                   	out    %al,(%dx)
    4de2:	b8 56 00 00 00       	mov    $0x56,%eax
    4de7:	48 8d 0d 3d f2 00 00 	lea    0xf23d(%rip),%rcx        # 1402b <_data+0x2b>
    4dee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4df3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4dfa:	00 00 00 00 
    4dfe:	66 90                	xchg   %ax,%ax
    4e00:	48 83 c1 01          	add    $0x1,%rcx
    4e04:	ee                   	out    %al,(%dx)
    4e05:	0f b6 01             	movzbl (%rcx),%eax
    4e08:	84 c0                	test   %al,%al
    4e0a:	75 f4                	jne    4e00 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x890>
    4e0c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4e11:	ee                   	out    %al,(%dx)
    4e12:	b8 20 00 00 00       	mov    $0x20,%eax
    4e17:	ee                   	out    %al,(%dx)
    4e18:	b8 53 00 00 00       	mov    $0x53,%eax
    4e1d:	48 8d 0d dc f7 00 00 	lea    0xf7dc(%rip),%rcx        # 14600 <_data+0x600>
    4e24:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4e29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4e30:	48 83 c1 01          	add    $0x1,%rcx
    4e34:	ee                   	out    %al,(%dx)
    4e35:	0f b6 01             	movzbl (%rcx),%eax
    4e38:	84 c0                	test   %al,%al
    4e3a:	75 f4                	jne    4e30 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x8c0>
    4e3c:	0f 28 34 24          	movaps (%rsp),%xmm6
    4e40:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
    4e45:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
    4e4b:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
    4e51:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
    4e57:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
    4e5d:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
    4e63:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
    4e69:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
    4e70:	00 00 
    4e72:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
    4e79:	00 00 
    4e7b:	48 81 c4 a0 00 00 00 	add    $0xa0,%rsp
    4e82:	5b                   	pop    %rbx
    4e83:	5e                   	pop    %rsi
    4e84:	5f                   	pop    %rdi
    4e85:	c3                   	ret
    4e86:	b8 0d 00 00 00       	mov    $0xd,%eax
    4e8b:	ee                   	out    %al,(%dx)
    4e8c:	b8 0a 00 00 00       	mov    $0xa,%eax
    4e91:	ee                   	out    %al,(%dx)
    4e92:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4e97:	48 8d 0d 62 f1 00 00 	lea    0xf162(%rip),%rcx        # 14000 <_data>
    4e9e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4ea3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4eaa:	00 00 00 00 
    4eae:	66 90                	xchg   %ax,%ax
    4eb0:	48 83 c1 01          	add    $0x1,%rcx
    4eb4:	ee                   	out    %al,(%dx)
    4eb5:	0f b6 01             	movzbl (%rcx),%eax
    4eb8:	84 c0                	test   %al,%al
    4eba:	75 f4                	jne    4eb0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x940>
    4ebc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4ec1:	ee                   	out    %al,(%dx)
    4ec2:	b8 52 00 00 00       	mov    $0x52,%eax
    4ec7:	48 8d 0d 5a f1 00 00 	lea    0xf15a(%rip),%rcx        # 14028 <_data+0x28>
    4ece:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4ed3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4eda:	00 00 00 00 
    4ede:	66 90                	xchg   %ax,%ax
    4ee0:	48 83 c1 01          	add    $0x1,%rcx
    4ee4:	ee                   	out    %al,(%dx)
    4ee5:	0f b6 01             	movzbl (%rcx),%eax
    4ee8:	84 c0                	test   %al,%al
    4eea:	75 f4                	jne    4ee0 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x970>
    4eec:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4ef1:	ee                   	out    %al,(%dx)
    4ef2:	b8 20 00 00 00       	mov    $0x20,%eax
    4ef7:	ee                   	out    %al,(%dx)
    4ef8:	b8 68 00 00 00       	mov    $0x68,%eax
    4efd:	48 8d 0d 3c f6 00 00 	lea    0xf63c(%rip),%rcx        # 14540 <_data+0x540>
    4f04:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4f09:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4f10:	48 83 c1 01          	add    $0x1,%rcx
    4f14:	ee                   	out    %al,(%dx)
    4f15:	0f b6 01             	movzbl (%rcx),%eax
    4f18:	84 c0                	test   %al,%al
    4f1a:	75 f4                	jne    4f10 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x9a0>
    4f1c:	e9 db fd ff ff       	jmp    4cfc <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x78c>
    4f21:	31 c0                	xor    %eax,%eax
    4f23:	e9 38 fd ff ff       	jmp    4c60 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_+0x6f0>
    4f28:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    4f2f:	00 

0000000000004f30 <efi_main>:
    4f30:	41 57                	push   %r15
    4f32:	41 56                	push   %r14
    4f34:	41 55                	push   %r13
    4f36:	41 54                	push   %r12
    4f38:	55                   	push   %rbp
    4f39:	53                   	push   %rbx
    4f3a:	48 89 fb             	mov    %rdi,%rbx
    4f3d:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
    4f44:	e8 97 1b 00 00       	call   6ae0 <InitializeLib>
    4f49:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4f4e:	b8 0d 00 00 00       	mov    $0xd,%eax
    4f53:	ee                   	out    %al,(%dx)
    4f54:	b8 0a 00 00 00       	mov    $0xa,%eax
    4f59:	ee                   	out    %al,(%dx)
    4f5a:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4f5f:	48 8d 0d 9a f0 00 00 	lea    0xf09a(%rip),%rcx        # 14000 <_data>
    4f66:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    4f6d:	00 00 00 
    4f70:	48 83 c1 01          	add    $0x1,%rcx
    4f74:	ee                   	out    %al,(%dx)
    4f75:	0f b6 01             	movzbl (%rcx),%eax
    4f78:	84 c0                	test   %al,%al
    4f7a:	75 f4                	jne    4f70 <efi_main+0x40>
    4f7c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4f81:	ee                   	out    %al,(%dx)
    4f82:	b8 4d 00 00 00       	mov    $0x4d,%eax
    4f87:	48 8d 0d a0 f0 00 00 	lea    0xf0a0(%rip),%rcx        # 1402e <_data+0x2e>
    4f8e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4f93:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    4f9a:	00 00 00 00 
    4f9e:	66 90                	xchg   %ax,%ax
    4fa0:	48 83 c1 01          	add    $0x1,%rcx
    4fa4:	ee                   	out    %al,(%dx)
    4fa5:	0f b6 01             	movzbl (%rcx),%eax
    4fa8:	84 c0                	test   %al,%al
    4faa:	75 f4                	jne    4fa0 <efi_main+0x70>
    4fac:	b8 5d 00 00 00       	mov    $0x5d,%eax
    4fb1:	ee                   	out    %al,(%dx)
    4fb2:	b8 20 00 00 00       	mov    $0x20,%eax
    4fb7:	ee                   	out    %al,(%dx)
    4fb8:	b8 65 00 00 00       	mov    $0x65,%eax
    4fbd:	48 8d 0d 6f f0 00 00 	lea    0xf06f(%rip),%rcx        # 14033 <_data+0x33>
    4fc4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4fc9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    4fd0:	48 83 c1 01          	add    $0x1,%rcx
    4fd4:	ee                   	out    %al,(%dx)
    4fd5:	0f b6 01             	movzbl (%rcx),%eax
    4fd8:	84 c0                	test   %al,%al
    4fda:	75 f4                	jne    4fd0 <efi_main+0xa0>
    4fdc:	b8 0d 00 00 00       	mov    $0xd,%eax
    4fe1:	ee                   	out    %al,(%dx)
    4fe2:	b8 0a 00 00 00       	mov    $0xa,%eax
    4fe7:	ee                   	out    %al,(%dx)
    4fe8:	b8 5b 00 00 00       	mov    $0x5b,%eax
    4fed:	48 8d 0d 0c f0 00 00 	lea    0xf00c(%rip),%rcx        # 14000 <_data>
    4ff4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    4ff9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5000:	48 83 c1 01          	add    $0x1,%rcx
    5004:	ee                   	out    %al,(%dx)
    5005:	0f b6 01             	movzbl (%rcx),%eax
    5008:	84 c0                	test   %al,%al
    500a:	75 f4                	jne    5000 <efi_main+0xd0>
    500c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5011:	ee                   	out    %al,(%dx)
    5012:	b8 4d 00 00 00       	mov    $0x4d,%eax
    5017:	48 8d 0d 10 f0 00 00 	lea    0xf010(%rip),%rcx        # 1402e <_data+0x2e>
    501e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5023:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    502a:	00 00 00 00 
    502e:	66 90                	xchg   %ax,%ax
    5030:	48 83 c1 01          	add    $0x1,%rcx
    5034:	ee                   	out    %al,(%dx)
    5035:	0f b6 01             	movzbl (%rcx),%eax
    5038:	84 c0                	test   %al,%al
    503a:	75 f4                	jne    5030 <efi_main+0x100>
    503c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5041:	ee                   	out    %al,(%dx)
    5042:	b8 20 00 00 00       	mov    $0x20,%eax
    5047:	ee                   	out    %al,(%dx)
    5048:	b8 76 00 00 00       	mov    $0x76,%eax
    504d:	48 8d 0d d4 f5 00 00 	lea    0xf5d4(%rip),%rcx        # 14628 <_data+0x628>
    5054:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5059:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5060:	48 83 c1 01          	add    $0x1,%rcx
    5064:	ee                   	out    %al,(%dx)
    5065:	0f b6 01             	movzbl (%rcx),%eax
    5068:	84 c0                	test   %al,%al
    506a:	75 f4                	jne    5060 <efi_main+0x130>
    506c:	4c 8d 25 65 81 01 00 	lea    0x18165(%rip),%r12        # 1d1d8 <ST>
    5073:	48 83 ec 20          	sub    $0x20,%rsp
    5077:	41 bd 1e 00 00 00    	mov    $0x1e,%r13d
    507d:	48 8d 2d 74 f8 00 00 	lea    0xf874(%rip),%rbp        # 148f8 <_data+0x8f8>
    5084:	49 8b 04 24          	mov    (%r12),%rax
    5088:	48 8b 40 40          	mov    0x40(%rax),%rax
    508c:	48 89 c1             	mov    %rax,%rcx
    508f:	ff 50 30             	call   *0x30(%rax)
    5092:	49 8b 04 24          	mov    (%r12),%rax
    5096:	ba 1f 00 00 00       	mov    $0x1f,%edx
    509b:	48 8b 40 40          	mov    0x40(%rax),%rax
    509f:	48 89 c1             	mov    %rax,%rcx
    50a2:	ff 50 28             	call   *0x28(%rax)
    50a5:	48 83 c4 20          	add    $0x20,%rsp
    50a9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    50b0:	31 c0                	xor    %eax,%eax
    50b2:	48 89 ef             	mov    %rbp,%rdi
    50b5:	e8 26 40 00 00       	call   90e0 <Print>
    50ba:	41 83 ed 01          	sub    $0x1,%r13d
    50be:	75 f0                	jne    50b0 <efi_main+0x180>
    50c0:	49 8b 04 24          	mov    (%r12),%rax
    50c4:	44 89 6c 24 24       	mov    %r13d,0x24(%rsp)
    50c9:	ba 0f 00 00 00       	mov    $0xf,%edx
    50ce:	48 83 ec 20          	sub    $0x20,%rsp
    50d2:	48 8b 40 40          	mov    0x40(%rax),%rax
    50d6:	48 89 c1             	mov    %rax,%rcx
    50d9:	ff 50 28             	call   *0x28(%rax)
    50dc:	49 8b 04 24          	mov    (%r12),%rax
    50e0:	41 b8 0a 00 00 00    	mov    $0xa,%r8d
    50e6:	31 d2                	xor    %edx,%edx
    50e8:	48 8b 40 40          	mov    0x40(%rax),%rax
    50ec:	48 89 c1             	mov    %rax,%rcx
    50ef:	ff 50 38             	call   *0x38(%rax)
    50f2:	48 83 c4 20          	add    $0x20,%rsp
    50f6:	48 8d 3d 7b f8 00 00 	lea    0xf87b(%rip),%rdi        # 14978 <_data+0x978>
    50fd:	31 c0                	xor    %eax,%eax
    50ff:	e8 dc 3f 00 00       	call   90e0 <Print>
    5104:	48 8d 3d ed f8 00 00 	lea    0xf8ed(%rip),%rdi        # 149f8 <_data+0x9f8>
    510b:	31 c0                	xor    %eax,%eax
    510d:	e8 ce 3f 00 00       	call   90e0 <Print>
    5112:	48 8d 3d 5f f9 00 00 	lea    0xf95f(%rip),%rdi        # 14a78 <_data+0xa78>
    5119:	31 c0                	xor    %eax,%eax
    511b:	e8 c0 3f 00 00       	call   90e0 <Print>
    5120:	48 8d 3d d1 f9 00 00 	lea    0xf9d1(%rip),%rdi        # 14af8 <_data+0xaf8>
    5127:	31 c0                	xor    %eax,%eax
    5129:	e8 b2 3f 00 00       	call   90e0 <Print>
    512e:	48 8d 3d bd f7 00 00 	lea    0xf7bd(%rip),%rdi        # 148f2 <_data+0x8f2>
    5135:	31 c0                	xor    %eax,%eax
    5137:	e8 a4 3f 00 00       	call   90e0 <Print>
    513c:	0f 20 d8             	mov    %cr3,%rax
    513f:	c6 05 ba 7b 01 00 01 	movb   $0x1,0x17bba(%rip)        # 1cd00 <_ZN10UEFIBridgeL10g_phys_memE+0x10>
    5146:	48 89 05 a3 7b 01 00 	mov    %rax,0x17ba3(%rip)        # 1ccf0 <_ZN10UEFIBridgeL10g_phys_memE>
    514d:	0f 20 de             	mov    %cr3,%rsi
    5150:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5155:	b8 0d 00 00 00       	mov    $0xd,%eax
    515a:	ee                   	out    %al,(%dx)
    515b:	b8 0a 00 00 00       	mov    $0xa,%eax
    5160:	ee                   	out    %al,(%dx)
    5161:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5166:	48 8d 0d 93 ee 00 00 	lea    0xee93(%rip),%rcx        # 14000 <_data>
    516d:	0f 1f 00             	nopl   (%rax)
    5170:	48 83 c1 01          	add    $0x1,%rcx
    5174:	ee                   	out    %al,(%dx)
    5175:	0f b6 01             	movzbl (%rcx),%eax
    5178:	84 c0                	test   %al,%al
    517a:	75 f4                	jne    5170 <efi_main+0x240>
    517c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5181:	ee                   	out    %al,(%dx)
    5182:	b8 4d 00 00 00       	mov    $0x4d,%eax
    5187:	48 8d 0d a0 ee 00 00 	lea    0xeea0(%rip),%rcx        # 1402e <_data+0x2e>
    518e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5193:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    519a:	00 00 00 00 
    519e:	66 90                	xchg   %ax,%ax
    51a0:	48 83 c1 01          	add    $0x1,%rcx
    51a4:	ee                   	out    %al,(%dx)
    51a5:	0f b6 01             	movzbl (%rcx),%eax
    51a8:	84 c0                	test   %al,%al
    51aa:	75 f4                	jne    51a0 <efi_main+0x270>
    51ac:	b8 5d 00 00 00       	mov    $0x5d,%eax
    51b1:	ee                   	out    %al,(%dx)
    51b2:	b8 20 00 00 00       	mov    $0x20,%eax
    51b7:	ee                   	out    %al,(%dx)
    51b8:	b8 55 00 00 00       	mov    $0x55,%eax
    51bd:	48 8d 0d 81 ee 00 00 	lea    0xee81(%rip),%rcx        # 14045 <_data+0x45>
    51c4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    51c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    51d0:	48 83 c1 01          	add    $0x1,%rcx
    51d4:	ee                   	out    %al,(%dx)
    51d5:	0f b6 01             	movzbl (%rcx),%eax
    51d8:	84 c0                	test   %al,%al
    51da:	75 f4                	jne    51d0 <efi_main+0x2a0>
    51dc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    51e1:	48 8d 0d de ee 00 00 	lea    0xeede(%rip),%rcx        # 140c6 <_data+0xc6>
    51e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    51ed:	0f 1f 00             	nopl   (%rax)
    51f0:	48 83 c1 01          	add    $0x1,%rcx
    51f4:	ee                   	out    %al,(%dx)
    51f5:	0f b6 01             	movzbl (%rcx),%eax
    51f8:	84 c0                	test   %al,%al
    51fa:	75 f4                	jne    51f0 <efi_main+0x2c0>
    51fc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    5201:	4c 8d 15 f8 fb 00 00 	lea    0xfbf8(%rip),%r10        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    5208:	bd f8 03 00 00       	mov    $0x3f8,%ebp
    520d:	0f 1f 00             	nopl   (%rax)
    5210:	48 89 f0             	mov    %rsi,%rax
    5213:	89 ea                	mov    %ebp,%edx
    5215:	48 d3 e8             	shr    %cl,%rax
    5218:	83 e0 0f             	and    $0xf,%eax
    521b:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    5220:	ee                   	out    %al,(%dx)
    5221:	83 e9 04             	sub    $0x4,%ecx
    5224:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    5227:	75 e7                	jne    5210 <efi_main+0x2e0>
    5229:	48 8d 05 b0 10 01 00 	lea    0x110b0(%rip),%rax        # 162e0 <gEfiLoadedImageProtocolGuid>
    5230:	48 8d 54 24 60       	lea    0x60(%rsp),%rdx
    5235:	48 83 ec 20          	sub    $0x20,%rsp
    5239:	48 89 d9             	mov    %rbx,%rcx
    523c:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
    5243:	00 00 
    5245:	f3 0f 6f 00          	movdqu (%rax),%xmm0
    5249:	48 8d 05 80 7f 01 00 	lea    0x17f80(%rip),%rax        # 1d1d0 <BS>
    5250:	48 8b 00             	mov    (%rax),%rax
    5253:	0f 29 84 24 80 00 00 	movaps %xmm0,0x80(%rsp)
    525a:	00 
    525b:	4c 8d 44 24 60       	lea    0x60(%rsp),%r8
    5260:	ff 90 98 00 00 00    	call   *0x98(%rax)
    5266:	48 83 c4 20          	add    $0x20,%rsp
    526a:	4c 8d 15 8f fb 00 00 	lea    0xfb8f(%rip),%r10        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    5271:	48 85 c0             	test   %rax,%rax
    5274:	48 89 c6             	mov    %rax,%rsi
    5277:	0f 88 7b 03 00 00    	js     55f8 <efi_main+0x6c8>
    527d:	48 8b 7c 24 40       	mov    0x40(%rsp),%rdi
    5282:	48 85 ff             	test   %rdi,%rdi
    5285:	0f 84 6d 03 00 00    	je     55f8 <efi_main+0x6c8>
    528b:	4c 8b 6f 40          	mov    0x40(%rdi),%r13
    528f:	b8 0d 00 00 00       	mov    $0xd,%eax
    5294:	89 ea                	mov    %ebp,%edx
    5296:	ee                   	out    %al,(%dx)
    5297:	b8 0a 00 00 00       	mov    $0xa,%eax
    529c:	ee                   	out    %al,(%dx)
    529d:	b8 5b 00 00 00       	mov    $0x5b,%eax
    52a2:	48 8d 0d 57 ed 00 00 	lea    0xed57(%rip),%rcx        # 14000 <_data>
    52a9:	ba f8 03 00 00       	mov    $0x3f8,%edx
    52ae:	66 90                	xchg   %ax,%ax
    52b0:	48 83 c1 01          	add    $0x1,%rcx
    52b4:	ee                   	out    %al,(%dx)
    52b5:	0f b6 01             	movzbl (%rcx),%eax
    52b8:	84 c0                	test   %al,%al
    52ba:	75 f4                	jne    52b0 <efi_main+0x380>
    52bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    52c1:	ee                   	out    %al,(%dx)
    52c2:	b8 49 00 00 00       	mov    $0x49,%eax
    52c7:	48 8d 0d 81 ed 00 00 	lea    0xed81(%rip),%rcx        # 1404f <_data+0x4f>
    52ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
    52d3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    52da:	00 00 00 00 
    52de:	66 90                	xchg   %ax,%ax
    52e0:	48 83 c1 01          	add    $0x1,%rcx
    52e4:	ee                   	out    %al,(%dx)
    52e5:	0f b6 01             	movzbl (%rcx),%eax
    52e8:	84 c0                	test   %al,%al
    52ea:	75 f4                	jne    52e0 <efi_main+0x3b0>
    52ec:	b8 5d 00 00 00       	mov    $0x5d,%eax
    52f1:	ee                   	out    %al,(%dx)
    52f2:	b8 20 00 00 00       	mov    $0x20,%eax
    52f7:	ee                   	out    %al,(%dx)
    52f8:	b8 49 00 00 00       	mov    $0x49,%eax
    52fd:	48 8d 0d 4f ed 00 00 	lea    0xed4f(%rip),%rcx        # 14053 <_data+0x53>
    5304:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5309:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5310:	48 83 c1 01          	add    $0x1,%rcx
    5314:	ee                   	out    %al,(%dx)
    5315:	0f b6 01             	movzbl (%rcx),%eax
    5318:	84 c0                	test   %al,%al
    531a:	75 f4                	jne    5310 <efi_main+0x3e0>
    531c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    5321:	48 8d 0d 9e ed 00 00 	lea    0xed9e(%rip),%rcx        # 140c6 <_data+0xc6>
    5328:	ba f8 03 00 00       	mov    $0x3f8,%edx
    532d:	0f 1f 00             	nopl   (%rax)
    5330:	48 83 c1 01          	add    $0x1,%rcx
    5334:	ee                   	out    %al,(%dx)
    5335:	0f b6 01             	movzbl (%rcx),%eax
    5338:	84 c0                	test   %al,%al
    533a:	75 f4                	jne    5330 <efi_main+0x400>
    533c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    5341:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5346:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    534d:	00 00 00 
    5350:	4c 89 e8             	mov    %r13,%rax
    5353:	48 d3 e8             	shr    %cl,%rax
    5356:	83 e0 0f             	and    $0xf,%eax
    5359:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    535e:	ee                   	out    %al,(%dx)
    535f:	83 e9 04             	sub    $0x4,%ecx
    5362:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    5365:	75 e9                	jne    5350 <efi_main+0x420>
    5367:	44 8b 47 50          	mov    0x50(%rdi),%r8d
    536b:	b8 0d 00 00 00       	mov    $0xd,%eax
    5370:	ee                   	out    %al,(%dx)
    5371:	b8 0a 00 00 00       	mov    $0xa,%eax
    5376:	ee                   	out    %al,(%dx)
    5377:	b8 5b 00 00 00       	mov    $0x5b,%eax
    537c:	48 8d 0d 7d ec 00 00 	lea    0xec7d(%rip),%rcx        # 14000 <_data>
    5383:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5388:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    538f:	00 
    5390:	48 83 c1 01          	add    $0x1,%rcx
    5394:	ee                   	out    %al,(%dx)
    5395:	0f b6 01             	movzbl (%rcx),%eax
    5398:	84 c0                	test   %al,%al
    539a:	75 f4                	jne    5390 <efi_main+0x460>
    539c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    53a1:	ee                   	out    %al,(%dx)
    53a2:	b8 49 00 00 00       	mov    $0x49,%eax
    53a7:	48 8d 0d a1 ec 00 00 	lea    0xeca1(%rip),%rcx        # 1404f <_data+0x4f>
    53ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    53b3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    53ba:	00 00 00 00 
    53be:	66 90                	xchg   %ax,%ax
    53c0:	48 83 c1 01          	add    $0x1,%rcx
    53c4:	ee                   	out    %al,(%dx)
    53c5:	0f b6 01             	movzbl (%rcx),%eax
    53c8:	84 c0                	test   %al,%al
    53ca:	75 f4                	jne    53c0 <efi_main+0x490>
    53cc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    53d1:	ee                   	out    %al,(%dx)
    53d2:	b8 20 00 00 00       	mov    $0x20,%eax
    53d7:	ee                   	out    %al,(%dx)
    53d8:	b8 49 00 00 00       	mov    $0x49,%eax
    53dd:	48 8d 0d 7a ec 00 00 	lea    0xec7a(%rip),%rcx        # 1405e <_data+0x5e>
    53e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    53e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    53f0:	48 83 c1 01          	add    $0x1,%rcx
    53f4:	ee                   	out    %al,(%dx)
    53f5:	0f b6 01             	movzbl (%rcx),%eax
    53f8:	84 c0                	test   %al,%al
    53fa:	75 f4                	jne    53f0 <efi_main+0x4c0>
    53fc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    5401:	ee                   	out    %al,(%dx)
    5402:	be 13 00 00 00       	mov    $0x13,%esi
    5407:	c6 84 24 84 00 00 00 	movb   $0x0,0x84(%rsp)
    540e:	00 
    540f:	48 8d 4c 24 70       	lea    0x70(%rsp),%rcx
    5414:	49 b9 cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r9
    541b:	cc cc cc 
    541e:	4d 85 c0             	test   %r8,%r8
    5421:	0f 84 81 13 00 00    	je     67a8 <efi_main+0x1878>
    5427:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    542e:	00 00 00 00 
    5432:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5439:	00 00 00 00 
    543d:	0f 1f 00             	nopl   (%rax)
    5440:	4c 89 c0             	mov    %r8,%rax
    5443:	49 f7 e1             	mul    %r9
    5446:	4c 89 c0             	mov    %r8,%rax
    5449:	48 c1 ea 03          	shr    $0x3,%rdx
    544d:	4c 8d 1c 92          	lea    (%rdx,%rdx,4),%r11
    5451:	4d 01 db             	add    %r11,%r11
    5454:	4c 29 d8             	sub    %r11,%rax
    5457:	4d 89 c3             	mov    %r8,%r11
    545a:	49 89 d0             	mov    %rdx,%r8
    545d:	48 89 f2             	mov    %rsi,%rdx
    5460:	83 c0 30             	add    $0x30,%eax
    5463:	49 83 fb 09          	cmp    $0x9,%r11
    5467:	0f 97 c3             	seta   %bl
    546a:	85 f6                	test   %esi,%esi
    546c:	88 04 31             	mov    %al,(%rcx,%rsi,1)
    546f:	41 0f 95 c3          	setne  %r11b
    5473:	48 83 ee 01          	sub    $0x1,%rsi
    5477:	44 84 db             	test   %r11b,%bl
    547a:	75 c4                	jne    5440 <efi_main+0x510>
    547c:	48 63 d2             	movslq %edx,%rdx
    547f:	48 01 d1             	add    %rdx,%rcx
    5482:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5487:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    548e:	00 00 
    5490:	48 83 c1 01          	add    $0x1,%rcx
    5494:	ee                   	out    %al,(%dx)
    5495:	0f b6 01             	movzbl (%rcx),%eax
    5498:	84 c0                	test   %al,%al
    549a:	75 f4                	jne    5490 <efi_main+0x560>
    549c:	8b 7f 54             	mov    0x54(%rdi),%edi
    549f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    54a4:	b8 0d 00 00 00       	mov    $0xd,%eax
    54a9:	ee                   	out    %al,(%dx)
    54aa:	b8 0a 00 00 00       	mov    $0xa,%eax
    54af:	ee                   	out    %al,(%dx)
    54b0:	b8 5b 00 00 00       	mov    $0x5b,%eax
    54b5:	48 8d 0d 44 eb 00 00 	lea    0xeb44(%rip),%rcx        # 14000 <_data>
    54bc:	0f 1f 40 00          	nopl   0x0(%rax)
    54c0:	48 83 c1 01          	add    $0x1,%rcx
    54c4:	ee                   	out    %al,(%dx)
    54c5:	0f b6 01             	movzbl (%rcx),%eax
    54c8:	84 c0                	test   %al,%al
    54ca:	75 f4                	jne    54c0 <efi_main+0x590>
    54cc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    54d1:	ee                   	out    %al,(%dx)
    54d2:	b8 49 00 00 00       	mov    $0x49,%eax
    54d7:	48 8d 0d 71 eb 00 00 	lea    0xeb71(%rip),%rcx        # 1404f <_data+0x4f>
    54de:	ba f8 03 00 00       	mov    $0x3f8,%edx
    54e3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    54ea:	00 00 00 00 
    54ee:	66 90                	xchg   %ax,%ax
    54f0:	48 83 c1 01          	add    $0x1,%rcx
    54f4:	ee                   	out    %al,(%dx)
    54f5:	0f b6 01             	movzbl (%rcx),%eax
    54f8:	84 c0                	test   %al,%al
    54fa:	75 f4                	jne    54f0 <efi_main+0x5c0>
    54fc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5501:	ee                   	out    %al,(%dx)
    5502:	b8 20 00 00 00       	mov    $0x20,%eax
    5507:	ee                   	out    %al,(%dx)
    5508:	b8 49 00 00 00       	mov    $0x49,%eax
    550d:	48 8d 0d 59 eb 00 00 	lea    0xeb59(%rip),%rcx        # 1406d <_data+0x6d>
    5514:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5519:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5520:	48 83 c1 01          	add    $0x1,%rcx
    5524:	ee                   	out    %al,(%dx)
    5525:	0f b6 01             	movzbl (%rcx),%eax
    5528:	84 c0                	test   %al,%al
    552a:	75 f4                	jne    5520 <efi_main+0x5f0>
    552c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    5531:	ee                   	out    %al,(%dx)
    5532:	be 13 00 00 00       	mov    $0x13,%esi
    5537:	c6 84 24 84 00 00 00 	movb   $0x0,0x84(%rsp)
    553e:	00 
    553f:	48 8d 4c 24 70       	lea    0x70(%rsp),%rcx
    5544:	49 b9 cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r9
    554b:	cc cc cc 
    554e:	48 85 ff             	test   %rdi,%rdi
    5551:	0f 84 46 12 00 00    	je     679d <efi_main+0x186d>
    5557:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    555e:	00 00 00 00 
    5562:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5569:	00 00 00 00 
    556d:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5574:	00 00 00 00 
    5578:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    557f:	00 
    5580:	48 89 f8             	mov    %rdi,%rax
    5583:	49 f7 e1             	mul    %r9
    5586:	48 89 f8             	mov    %rdi,%rax
    5589:	48 c1 ea 03          	shr    $0x3,%rdx
    558d:	4c 8d 04 92          	lea    (%rdx,%rdx,4),%r8
    5591:	4d 01 c0             	add    %r8,%r8
    5594:	4c 29 c0             	sub    %r8,%rax
    5597:	49 89 f8             	mov    %rdi,%r8
    559a:	48 89 d7             	mov    %rdx,%rdi
    559d:	48 89 f2             	mov    %rsi,%rdx
    55a0:	83 c0 30             	add    $0x30,%eax
    55a3:	49 83 f8 09          	cmp    $0x9,%r8
    55a7:	41 0f 97 c3          	seta   %r11b
    55ab:	85 f6                	test   %esi,%esi
    55ad:	88 04 31             	mov    %al,(%rcx,%rsi,1)
    55b0:	41 0f 95 c0          	setne  %r8b
    55b4:	48 83 ee 01          	sub    $0x1,%rsi
    55b8:	45 84 c3             	test   %r8b,%r11b
    55bb:	75 c3                	jne    5580 <efi_main+0x650>
    55bd:	48 63 d2             	movslq %edx,%rdx
    55c0:	48 01 d1             	add    %rdx,%rcx
    55c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
    55c8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    55cf:	00 
    55d0:	48 83 c1 01          	add    $0x1,%rcx
    55d4:	ee                   	out    %al,(%dx)
    55d5:	0f b6 01             	movzbl (%rcx),%eax
    55d8:	84 c0                	test   %al,%al
    55da:	75 f4                	jne    55d0 <efi_main+0x6a0>
    55dc:	49 8d 85 00 00 02 00 	lea    0x20000(%r13),%rax
    55e3:	4c 8d 1d f6 f7 00 00 	lea    0xf7f6(%rip),%r11        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    55ea:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    55ef:	e9 ed 00 00 00       	jmp    56e1 <efi_main+0x7b1>
    55f4:	0f 1f 40 00          	nopl   0x0(%rax)
    55f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    55fd:	b8 0d 00 00 00       	mov    $0xd,%eax
    5602:	ee                   	out    %al,(%dx)
    5603:	b8 0a 00 00 00       	mov    $0xa,%eax
    5608:	ee                   	out    %al,(%dx)
    5609:	b8 5b 00 00 00       	mov    $0x5b,%eax
    560e:	48 8d 0d eb e9 00 00 	lea    0xe9eb(%rip),%rcx        # 14000 <_data>
    5615:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    561c:	00 00 00 00 
    5620:	48 83 c1 01          	add    $0x1,%rcx
    5624:	ee                   	out    %al,(%dx)
    5625:	0f b6 01             	movzbl (%rcx),%eax
    5628:	84 c0                	test   %al,%al
    562a:	75 f4                	jne    5620 <efi_main+0x6f0>
    562c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5631:	ee                   	out    %al,(%dx)
    5632:	b8 49 00 00 00       	mov    $0x49,%eax
    5637:	48 8d 0d 11 ea 00 00 	lea    0xea11(%rip),%rcx        # 1404f <_data+0x4f>
    563e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5643:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    564a:	00 00 00 00 
    564e:	66 90                	xchg   %ax,%ax
    5650:	48 83 c1 01          	add    $0x1,%rcx
    5654:	ee                   	out    %al,(%dx)
    5655:	0f b6 01             	movzbl (%rcx),%eax
    5658:	84 c0                	test   %al,%al
    565a:	75 f4                	jne    5650 <efi_main+0x720>
    565c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5661:	ee                   	out    %al,(%dx)
    5662:	b8 20 00 00 00       	mov    $0x20,%eax
    5667:	ee                   	out    %al,(%dx)
    5668:	b8 4c 00 00 00       	mov    $0x4c,%eax
    566d:	48 8d 0d 08 ea 00 00 	lea    0xea08(%rip),%rcx        # 1407c <_data+0x7c>
    5674:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5679:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5680:	48 83 c1 01          	add    $0x1,%rcx
    5684:	ee                   	out    %al,(%dx)
    5685:	0f b6 01             	movzbl (%rcx),%eax
    5688:	84 c0                	test   %al,%al
    568a:	75 f4                	jne    5680 <efi_main+0x750>
    568c:	b8 20 00 00 00       	mov    $0x20,%eax
    5691:	48 8d 0d bf ec 00 00 	lea    0xecbf(%rip),%rcx        # 14357 <_data+0x357>
    5698:	ba f8 03 00 00       	mov    $0x3f8,%edx
    569d:	0f 1f 00             	nopl   (%rax)
    56a0:	48 83 c1 01          	add    $0x1,%rcx
    56a4:	ee                   	out    %al,(%dx)
    56a5:	0f b6 01             	movzbl (%rcx),%eax
    56a8:	84 c0                	test   %al,%al
    56aa:	75 f4                	jne    56a0 <efi_main+0x770>
    56ac:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    56b1:	4c 8d 1d 28 f7 00 00 	lea    0xf728(%rip),%r11        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    56b8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    56bd:	0f 1f 00             	nopl   (%rax)
    56c0:	89 f0                	mov    %esi,%eax
    56c2:	d3 e8                	shr    %cl,%eax
    56c4:	83 e0 0f             	and    $0xf,%eax
    56c7:	41 0f b6 04 03       	movzbl (%r11,%rax,1),%eax
    56cc:	ee                   	out    %al,(%dx)
    56cd:	83 e9 04             	sub    $0x4,%ecx
    56d0:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    56d3:	75 eb                	jne    56c0 <efi_main+0x790>
    56d5:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    56dc:	00 00 
    56de:	45 31 ed             	xor    %r13d,%r13d
    56e1:	4c 89 1c 24          	mov    %r11,(%rsp)
    56e5:	48 8d 05 e4 7a 01 00 	lea    0x17ae4(%rip),%rax        # 1d1d0 <BS>
    56ec:	48 8d 4c 24 48       	lea    0x48(%rsp),%rcx
    56f1:	48 83 ec 08          	sub    $0x8,%rsp
    56f5:	48 c7 44 24 50 00 50 	movq   $0x5000,0x50(%rsp)
    56fc:	00 00 
    56fe:	48 c7 44 24 58 00 00 	movq   $0x0,0x58(%rsp)
    5705:	00 00 
    5707:	48 8b 00             	mov    (%rax),%rax
    570a:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
    5711:	00 00 
    5713:	c7 44 24 44 00 00 00 	movl   $0x0,0x44(%rsp)
    571a:	00 
    571b:	48 8d 54 24 44       	lea    0x44(%rsp),%rdx
    5720:	52                   	push   %rdx
    5721:	48 8d 15 f8 13 01 00 	lea    0x113f8(%rip),%rdx        # 16b20 <_ZZN10UEFIBridgeL19DumpImageMemoryInfoEPvmmE3map>
    5728:	48 83 ec 20          	sub    $0x20,%rsp
    572c:	4c 8d 8c 24 88 00 00 	lea    0x88(%rsp),%r9
    5733:	00 
    5734:	4c 8d 84 24 80 00 00 	lea    0x80(%rsp),%r8
    573b:	00 
    573c:	ff 50 38             	call   *0x38(%rax)
    573f:	48 83 c4 30          	add    $0x30,%rsp
    5743:	4c 8d 15 b6 f6 00 00 	lea    0xf6b6(%rip),%r10        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    574a:	4c 8b 1c 24          	mov    (%rsp),%r11
    574e:	48 85 c0             	test   %rax,%rax
    5751:	48 89 c6             	mov    %rax,%rsi
    5754:	0f 88 80 0d 00 00    	js     64da <efi_main+0x15aa>
    575a:	4c 8b 74 24 58       	mov    0x58(%rsp),%r14
    575f:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    5764:	be 01 00 00 00       	mov    $0x1,%esi
    5769:	ba f8 03 00 00       	mov    $0x3f8,%edx
    576e:	4d 85 f6             	test   %r14,%r14
    5771:	48 89 04 24          	mov    %rax,(%rsp)
    5775:	b8 0d 00 00 00       	mov    $0xd,%eax
    577a:	49 0f 45 f6          	cmovne %r14,%rsi
    577e:	ee                   	out    %al,(%dx)
    577f:	b8 0a 00 00 00       	mov    $0xa,%eax
    5784:	ee                   	out    %al,(%dx)
    5785:	b8 5b 00 00 00       	mov    $0x5b,%eax
    578a:	48 8d 0d 6f e8 00 00 	lea    0xe86f(%rip),%rcx        # 14000 <_data>
    5791:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5798:	00 00 00 00 
    579c:	0f 1f 40 00          	nopl   0x0(%rax)
    57a0:	48 83 c1 01          	add    $0x1,%rcx
    57a4:	ee                   	out    %al,(%dx)
    57a5:	0f b6 01             	movzbl (%rcx),%eax
    57a8:	84 c0                	test   %al,%al
    57aa:	75 f4                	jne    57a0 <efi_main+0x870>
    57ac:	b8 5b 00 00 00       	mov    $0x5b,%eax
    57b1:	ee                   	out    %al,(%dx)
    57b2:	b8 4d 00 00 00       	mov    $0x4d,%eax
    57b7:	48 8d 0d d7 e8 00 00 	lea    0xe8d7(%rip),%rcx        # 14095 <_data+0x95>
    57be:	ba f8 03 00 00       	mov    $0x3f8,%edx
    57c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    57ca:	00 00 00 00 
    57ce:	66 90                	xchg   %ax,%ax
    57d0:	48 83 c1 01          	add    $0x1,%rcx
    57d4:	ee                   	out    %al,(%dx)
    57d5:	0f b6 01             	movzbl (%rcx),%eax
    57d8:	84 c0                	test   %al,%al
    57da:	75 f4                	jne    57d0 <efi_main+0x8a0>
    57dc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    57e1:	ee                   	out    %al,(%dx)
    57e2:	b8 20 00 00 00       	mov    $0x20,%eax
    57e7:	ee                   	out    %al,(%dx)
    57e8:	b8 64 00 00 00       	mov    $0x64,%eax
    57ed:	48 8d 0d ba e8 00 00 	lea    0xe8ba(%rip),%rcx        # 140ae <_data+0xae>
    57f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    57f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5800:	48 83 c1 01          	add    $0x1,%rcx
    5804:	ee                   	out    %al,(%dx)
    5805:	0f b6 01             	movzbl (%rcx),%eax
    5808:	84 c0                	test   %al,%al
    580a:	75 f4                	jne    5800 <efi_main+0x8d0>
    580c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    5811:	ee                   	out    %al,(%dx)
    5812:	c6 84 24 84 00 00 00 	movb   $0x0,0x84(%rsp)
    5819:	00 
    581a:	48 39 34 24          	cmp    %rsi,(%rsp)
    581e:	0f 82 6d 04 00 00    	jb     5c91 <efi_main+0xd61>
    5824:	48 8b 04 24          	mov    (%rsp),%rax
    5828:	31 d2                	xor    %edx,%edx
    582a:	48 8d 4c 24 70       	lea    0x70(%rsp),%rcx
    582f:	49 b8 cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r8
    5836:	cc cc cc 
    5839:	48 f7 f6             	div    %rsi
    583c:	be 13 00 00 00       	mov    $0x13,%esi
    5841:	48 89 c7             	mov    %rax,%rdi
    5844:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    584b:	00 00 00 00 
    584f:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5856:	00 00 00 00 
    585a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5861:	00 00 00 00 
    5865:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    586c:	00 00 00 00 
    5870:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5877:	00 00 00 00 
    587b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    5880:	48 89 f8             	mov    %rdi,%rax
    5883:	48 89 f3             	mov    %rsi,%rbx
    5886:	49 f7 e0             	mul    %r8
    5889:	48 89 f8             	mov    %rdi,%rax
    588c:	48 c1 ea 03          	shr    $0x3,%rdx
    5890:	4c 8d 0c 92          	lea    (%rdx,%rdx,4),%r9
    5894:	4d 01 c9             	add    %r9,%r9
    5897:	4c 29 c8             	sub    %r9,%rax
    589a:	49 89 f9             	mov    %rdi,%r9
    589d:	48 89 d7             	mov    %rdx,%rdi
    58a0:	83 c0 30             	add    $0x30,%eax
    58a3:	49 83 f9 09          	cmp    $0x9,%r9
    58a7:	41 0f 97 c1          	seta   %r9b
    58ab:	85 f6                	test   %esi,%esi
    58ad:	88 04 31             	mov    %al,(%rcx,%rsi,1)
    58b0:	0f 95 c2             	setne  %dl
    58b3:	48 83 ee 01          	sub    $0x1,%rsi
    58b7:	41 84 d1             	test   %dl,%r9b
    58ba:	75 c4                	jne    5880 <efi_main+0x950>
    58bc:	48 63 db             	movslq %ebx,%rbx
    58bf:	ba f8 03 00 00       	mov    $0x3f8,%edx
    58c4:	48 01 d9             	add    %rbx,%rcx
    58c7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    58ce:	00 00 
    58d0:	48 83 c1 01          	add    $0x1,%rcx
    58d4:	ee                   	out    %al,(%dx)
    58d5:	0f b6 01             	movzbl (%rcx),%eax
    58d8:	84 c0                	test   %al,%al
    58da:	75 f4                	jne    58d0 <efi_main+0x9a0>
    58dc:	48 8d 1d 3d 12 01 00 	lea    0x1123d(%rip),%rbx        # 16b20 <_ZZN10UEFIBridgeL19DumpImageMemoryInfoEPvmmE3map>
    58e3:	4c 39 34 24          	cmp    %r14,(%rsp)
    58e7:	0f 82 b8 03 00 00    	jb     5ca5 <efi_main+0xd75>
    58ed:	4c 89 5c 24 28       	mov    %r11,0x28(%rsp)
    58f2:	be f8 03 00 00       	mov    $0x3f8,%esi
    58f7:	4c 8d 64 24 70       	lea    0x70(%rsp),%r12
    58fc:	49 bf cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r15
    5903:	cc cc cc 
    5906:	eb 2a                	jmp    5932 <efi_main+0xa02>
    5908:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    590f:	00 
    5910:	40 84 ed             	test   %bpl,%bpl
    5913:	75 4d                	jne    5962 <efi_main+0xa32>
    5915:	4c 89 f0             	mov    %r14,%rax
    5918:	48 8d 3d 01 12 01 00 	lea    0x11201(%rip),%rdi        # 16b20 <_ZZN10UEFIBridgeL19DumpImageMemoryInfoEPvmmE3map>
    591f:	4c 01 f3             	add    %r14,%rbx
    5922:	48 29 f8             	sub    %rdi,%rax
    5925:	48 01 d8             	add    %rbx,%rax
    5928:	48 39 04 24          	cmp    %rax,(%rsp)
    592c:	0f 82 6e 03 00 00    	jb     5ca0 <efi_main+0xd70>
    5932:	4c 8b 43 18          	mov    0x18(%rbx),%r8
    5936:	4c 8b 5b 08          	mov    0x8(%rbx),%r11
    593a:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    593f:	8b 0b                	mov    (%rbx),%ecx
    5941:	4c 89 c7             	mov    %r8,%rdi
    5944:	48 c1 e7 0c          	shl    $0xc,%rdi
    5948:	4c 01 df             	add    %r11,%rdi
    594b:	49 39 fd             	cmp    %rdi,%r13
    594e:	40 0f 92 c5          	setb   %bpl
    5952:	49 39 c3             	cmp    %rax,%r11
    5955:	0f 92 c0             	setb   %al
    5958:	21 c5                	and    %eax,%ebp
    595a:	8d 41 fb             	lea    -0x5(%rcx),%eax
    595d:	83 f8 01             	cmp    $0x1,%eax
    5960:	77 ae                	ja     5910 <efi_main+0x9e0>
    5962:	b8 0d 00 00 00       	mov    $0xd,%eax
    5967:	89 f2                	mov    %esi,%edx
    5969:	ee                   	out    %al,(%dx)
    596a:	b8 0a 00 00 00       	mov    $0xa,%eax
    596f:	ee                   	out    %al,(%dx)
    5970:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5975:	4c 8d 0d 84 e6 00 00 	lea    0xe684(%rip),%r9        # 14000 <_data>
    597c:	0f 1f 40 00          	nopl   0x0(%rax)
    5980:	49 83 c1 01          	add    $0x1,%r9
    5984:	89 f2                	mov    %esi,%edx
    5986:	ee                   	out    %al,(%dx)
    5987:	41 0f b6 01          	movzbl (%r9),%eax
    598b:	84 c0                	test   %al,%al
    598d:	75 f1                	jne    5980 <efi_main+0xa50>
    598f:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5994:	ee                   	out    %al,(%dx)
    5995:	b8 4d 00 00 00       	mov    $0x4d,%eax
    599a:	4c 8d 0d f4 e6 00 00 	lea    0xe6f4(%rip),%r9        # 14095 <_data+0x95>
    59a1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    59a8:	00 00 00 00 
    59ac:	0f 1f 40 00          	nopl   0x0(%rax)
    59b0:	49 83 c1 01          	add    $0x1,%r9
    59b4:	89 f2                	mov    %esi,%edx
    59b6:	ee                   	out    %al,(%dx)
    59b7:	41 0f b6 01          	movzbl (%r9),%eax
    59bb:	84 c0                	test   %al,%al
    59bd:	75 f1                	jne    59b0 <efi_main+0xa80>
    59bf:	b8 5d 00 00 00       	mov    $0x5d,%eax
    59c4:	ee                   	out    %al,(%dx)
    59c5:	b8 20 00 00 00       	mov    $0x20,%eax
    59ca:	ee                   	out    %al,(%dx)
    59cb:	b8 74 00 00 00       	mov    $0x74,%eax
    59d0:	4c 8d 0d e4 e6 00 00 	lea    0xe6e4(%rip),%r9        # 140bb <_data+0xbb>
    59d7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    59de:	00 00 
    59e0:	49 83 c1 01          	add    $0x1,%r9
    59e4:	89 f2                	mov    %esi,%edx
    59e6:	ee                   	out    %al,(%dx)
    59e7:	41 0f b6 01          	movzbl (%r9),%eax
    59eb:	84 c0                	test   %al,%al
    59ed:	75 f1                	jne    59e0 <efi_main+0xab0>
    59ef:	c6 84 24 84 00 00 00 	movb   $0x0,0x84(%rsp)
    59f6:	00 
    59f7:	41 b9 13 00 00 00    	mov    $0x13,%r9d
    59fd:	48 85 c9             	test   %rcx,%rcx
    5a00:	0f 84 c2 09 00 00    	je     63c8 <efi_main+0x1498>
    5a06:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
    5a0b:	4c 89 74 24 18       	mov    %r14,0x18(%rsp)
    5a10:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5a17:	00 00 00 00 
    5a1b:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5a22:	00 00 00 00 
    5a26:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5a2d:	00 00 00 00 
    5a31:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5a38:	00 00 00 00 
    5a3c:	0f 1f 40 00          	nopl   0x0(%rax)
    5a40:	48 89 c8             	mov    %rcx,%rax
    5a43:	49 f7 e7             	mul    %r15
    5a46:	48 89 c8             	mov    %rcx,%rax
    5a49:	48 c1 ea 03          	shr    $0x3,%rdx
    5a4d:	4c 8d 2c 92          	lea    (%rdx,%rdx,4),%r13
    5a51:	4d 01 ed             	add    %r13,%r13
    5a54:	4c 29 e8             	sub    %r13,%rax
    5a57:	49 89 cd             	mov    %rcx,%r13
    5a5a:	48 89 d1             	mov    %rdx,%rcx
    5a5d:	4c 89 ca             	mov    %r9,%rdx
    5a60:	83 c0 30             	add    $0x30,%eax
    5a63:	49 83 fd 09          	cmp    $0x9,%r13
    5a67:	41 0f 97 c6          	seta   %r14b
    5a6b:	45 85 c9             	test   %r9d,%r9d
    5a6e:	43 88 04 0c          	mov    %al,(%r12,%r9,1)
    5a72:	41 0f 95 c5          	setne  %r13b
    5a76:	49 83 e9 01          	sub    $0x1,%r9
    5a7a:	45 84 ee             	test   %r13b,%r14b
    5a7d:	75 c1                	jne    5a40 <efi_main+0xb10>
    5a7f:	48 63 d2             	movslq %edx,%rdx
    5a82:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
    5a87:	4c 8b 74 24 18       	mov    0x18(%rsp),%r14
    5a8c:	49 8d 0c 14          	lea    (%r12,%rdx,1),%rcx
    5a90:	48 83 c1 01          	add    $0x1,%rcx
    5a94:	89 f2                	mov    %esi,%edx
    5a96:	ee                   	out    %al,(%dx)
    5a97:	0f b6 01             	movzbl (%rcx),%eax
    5a9a:	84 c0                	test   %al,%al
    5a9c:	75 f2                	jne    5a90 <efi_main+0xb60>
    5a9e:	b8 20 00 00 00       	mov    $0x20,%eax
    5aa3:	48 8d 0d 17 e6 00 00 	lea    0xe617(%rip),%rcx        # 140c1 <_data+0xc1>
    5aaa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    5ab0:	48 83 c1 01          	add    $0x1,%rcx
    5ab4:	89 f2                	mov    %esi,%edx
    5ab6:	ee                   	out    %al,(%dx)
    5ab7:	0f b6 01             	movzbl (%rcx),%eax
    5aba:	84 c0                	test   %al,%al
    5abc:	75 f2                	jne    5ab0 <efi_main+0xb80>
    5abe:	4c 8b 4b 20          	mov    0x20(%rbx),%r9
    5ac2:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    5ac7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    5ace:	00 00 
    5ad0:	4c 89 c8             	mov    %r9,%rax
    5ad3:	89 f2                	mov    %esi,%edx
    5ad5:	48 d3 e8             	shr    %cl,%rax
    5ad8:	83 e0 0f             	and    $0xf,%eax
    5adb:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    5ae0:	ee                   	out    %al,(%dx)
    5ae1:	83 e9 04             	sub    $0x4,%ecx
    5ae4:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    5ae7:	75 e7                	jne    5ad0 <efi_main+0xba0>
    5ae9:	b8 20 00 00 00       	mov    $0x20,%eax
    5aee:	48 8d 0d d5 e5 00 00 	lea    0xe5d5(%rip),%rcx        # 140ca <_data+0xca>
    5af5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5afc:	00 00 00 00 
    5b00:	48 83 c1 01          	add    $0x1,%rcx
    5b04:	89 f2                	mov    %esi,%edx
    5b06:	ee                   	out    %al,(%dx)
    5b07:	0f b6 01             	movzbl (%rcx),%eax
    5b0a:	84 c0                	test   %al,%al
    5b0c:	75 f2                	jne    5b00 <efi_main+0xbd0>
    5b0e:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    5b13:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5b1a:	00 00 00 00 
    5b1e:	66 90                	xchg   %ax,%ax
    5b20:	4c 89 d8             	mov    %r11,%rax
    5b23:	89 f2                	mov    %esi,%edx
    5b25:	48 d3 e8             	shr    %cl,%rax
    5b28:	83 e0 0f             	and    $0xf,%eax
    5b2b:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    5b30:	ee                   	out    %al,(%dx)
    5b31:	83 e9 04             	sub    $0x4,%ecx
    5b34:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    5b37:	75 e7                	jne    5b20 <efi_main+0xbf0>
    5b39:	b8 2d 00 00 00       	mov    $0x2d,%eax
    5b3e:	48 8d 0d 8e e5 00 00 	lea    0xe58e(%rip),%rcx        # 140d3 <_data+0xd3>
    5b45:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5b4c:	00 00 00 00 
    5b50:	48 83 c1 01          	add    $0x1,%rcx
    5b54:	89 f2                	mov    %esi,%edx
    5b56:	ee                   	out    %al,(%dx)
    5b57:	0f b6 01             	movzbl (%rcx),%eax
    5b5a:	84 c0                	test   %al,%al
    5b5c:	75 f2                	jne    5b50 <efi_main+0xc20>
    5b5e:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    5b63:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5b6a:	00 00 00 00 
    5b6e:	66 90                	xchg   %ax,%ax
    5b70:	48 89 f8             	mov    %rdi,%rax
    5b73:	89 f2                	mov    %esi,%edx
    5b75:	48 d3 e8             	shr    %cl,%rax
    5b78:	83 e0 0f             	and    $0xf,%eax
    5b7b:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    5b80:	ee                   	out    %al,(%dx)
    5b81:	83 e9 04             	sub    $0x4,%ecx
    5b84:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    5b87:	75 e7                	jne    5b70 <efi_main+0xc40>
    5b89:	b8 20 00 00 00       	mov    $0x20,%eax
    5b8e:	48 8d 0d 42 e5 00 00 	lea    0xe542(%rip),%rcx        # 140d7 <_data+0xd7>
    5b95:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5b9c:	00 00 00 00 
    5ba0:	48 83 c1 01          	add    $0x1,%rcx
    5ba4:	89 f2                	mov    %esi,%edx
    5ba6:	ee                   	out    %al,(%dx)
    5ba7:	0f b6 01             	movzbl (%rcx),%eax
    5baa:	84 c0                	test   %al,%al
    5bac:	75 f2                	jne    5ba0 <efi_main+0xc70>
    5bae:	c6 84 24 84 00 00 00 	movb   $0x0,0x84(%rsp)
    5bb5:	00 
    5bb6:	b9 13 00 00 00       	mov    $0x13,%ecx
    5bbb:	4d 85 c0             	test   %r8,%r8
    5bbe:	0f 84 14 08 00 00    	je     63d8 <efi_main+0x14a8>
    5bc4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5bcb:	00 00 00 00 
    5bcf:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5bd6:	00 00 00 00 
    5bda:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5be1:	00 00 00 00 
    5be5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5bec:	00 00 00 00 
    5bf0:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5bf7:	00 00 00 00 
    5bfb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    5c00:	4c 89 c0             	mov    %r8,%rax
    5c03:	49 f7 e7             	mul    %r15
    5c06:	4c 89 c0             	mov    %r8,%rax
    5c09:	48 c1 ea 03          	shr    $0x3,%rdx
    5c0d:	48 8d 3c 92          	lea    (%rdx,%rdx,4),%rdi
    5c11:	48 01 ff             	add    %rdi,%rdi
    5c14:	48 29 f8             	sub    %rdi,%rax
    5c17:	4c 89 c7             	mov    %r8,%rdi
    5c1a:	49 89 d0             	mov    %rdx,%r8
    5c1d:	48 89 ca             	mov    %rcx,%rdx
    5c20:	83 c0 30             	add    $0x30,%eax
    5c23:	48 83 ff 09          	cmp    $0x9,%rdi
    5c27:	41 0f 97 c1          	seta   %r9b
    5c2b:	85 c9                	test   %ecx,%ecx
    5c2d:	41 88 04 0c          	mov    %al,(%r12,%rcx,1)
    5c31:	40 0f 95 c7          	setne  %dil
    5c35:	48 83 e9 01          	sub    $0x1,%rcx
    5c39:	41 84 f9             	test   %dil,%r9b
    5c3c:	75 c2                	jne    5c00 <efi_main+0xcd0>
    5c3e:	48 63 d2             	movslq %edx,%rdx
    5c41:	49 8d 0c 14          	lea    (%r12,%rdx,1),%rcx
    5c45:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5c4c:	00 00 00 00 
    5c50:	48 83 c1 01          	add    $0x1,%rcx
    5c54:	89 f2                	mov    %esi,%edx
    5c56:	ee                   	out    %al,(%dx)
    5c57:	0f b6 01             	movzbl (%rcx),%eax
    5c5a:	84 c0                	test   %al,%al
    5c5c:	75 f2                	jne    5c50 <efi_main+0xd20>
    5c5e:	40 84 ed             	test   %bpl,%bpl
    5c61:	0f 84 ae fc ff ff    	je     5915 <efi_main+0x9e5>
    5c67:	b8 20 00 00 00       	mov    $0x20,%eax
    5c6c:	48 8d 0d 6d e4 00 00 	lea    0xe46d(%rip),%rcx        # 140e0 <_data+0xe0>
    5c73:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5c78:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    5c7f:	00 
    5c80:	48 83 c1 01          	add    $0x1,%rcx
    5c84:	ee                   	out    %al,(%dx)
    5c85:	0f b6 01             	movzbl (%rcx),%eax
    5c88:	84 c0                	test   %al,%al
    5c8a:	75 f4                	jne    5c80 <efi_main+0xd50>
    5c8c:	e9 84 fc ff ff       	jmp    5915 <efi_main+0x9e5>
    5c91:	b8 30 00 00 00       	mov    $0x30,%eax
    5c96:	ee                   	out    %al,(%dx)
    5c97:	e9 40 fc ff ff       	jmp    58dc <efi_main+0x9ac>
    5c9c:	0f 1f 40 00          	nopl   0x0(%rax)
    5ca0:	4c 8b 5c 24 28       	mov    0x28(%rsp),%r11
    5ca5:	4c 8d 25 24 70 01 00 	lea    0x17024(%rip),%r12        # 1ccd0 <_ZN10UEFIBridgeL6g_poolE>
    5cac:	4c 89 1c 24          	mov    %r11,(%rsp)
    5cb0:	4c 89 e7             	mov    %r12,%rdi
    5cb3:	e8 a8 71 00 00       	call   ce60 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv>
    5cb8:	4c 8b 1c 24          	mov    (%rsp),%r11
    5cbc:	48 85 c0             	test   %rax,%rax
    5cbf:	48 89 c3             	mov    %rax,%rbx
    5cc2:	0f 85 20 07 00 00    	jne    63e8 <efi_main+0x14b8>
    5cc8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5ccd:	b8 0d 00 00 00       	mov    $0xd,%eax
    5cd2:	ee                   	out    %al,(%dx)
    5cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
    5cd8:	ee                   	out    %al,(%dx)
    5cd9:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5cde:	48 8d 0d 1b e3 00 00 	lea    0xe31b(%rip),%rcx        # 14000 <_data>
    5ce5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5cec:	00 00 00 00 
    5cf0:	48 83 c1 01          	add    $0x1,%rcx
    5cf4:	ee                   	out    %al,(%dx)
    5cf5:	0f b6 01             	movzbl (%rcx),%eax
    5cf8:	84 c0                	test   %al,%al
    5cfa:	75 f4                	jne    5cf0 <efi_main+0xdc0>
    5cfc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5d01:	ee                   	out    %al,(%dx)
    5d02:	b8 4d 00 00 00       	mov    $0x4d,%eax
    5d07:	48 8d 0d 20 e3 00 00 	lea    0xe320(%rip),%rcx        # 1402e <_data+0x2e>
    5d0e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5d13:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5d1a:	00 00 00 00 
    5d1e:	66 90                	xchg   %ax,%ax
    5d20:	48 83 c1 01          	add    $0x1,%rcx
    5d24:	ee                   	out    %al,(%dx)
    5d25:	0f b6 01             	movzbl (%rcx),%eax
    5d28:	84 c0                	test   %al,%al
    5d2a:	75 f4                	jne    5d20 <efi_main+0xdf0>
    5d2c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5d31:	ee                   	out    %al,(%dx)
    5d32:	b8 20 00 00 00       	mov    $0x20,%eax
    5d37:	ee                   	out    %al,(%dx)
    5d38:	b8 73 00 00 00       	mov    $0x73,%eax
    5d3d:	48 8d 0d 0c e9 00 00 	lea    0xe90c(%rip),%rcx        # 14650 <_data+0x650>
    5d44:	41 bf f8 03 00 00    	mov    $0x3f8,%r15d
    5d4a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    5d50:	48 83 c1 01          	add    $0x1,%rcx
    5d54:	44 89 fa             	mov    %r15d,%edx
    5d57:	ee                   	out    %al,(%dx)
    5d58:	0f b6 01             	movzbl (%rcx),%eax
    5d5b:	84 c0                	test   %al,%al
    5d5d:	75 f1                	jne    5d50 <efi_main+0xe20>
    5d5f:	48 8d 05 8a 6f 01 00 	lea    0x16f8a(%rip),%rax        # 1ccf0 <_ZN10UEFIBridgeL10g_phys_memE>
    5d66:	4c 89 1c 24          	mov    %r11,(%rsp)
    5d6a:	48 8d 35 a7 6e 01 00 	lea    0x16ea7(%rip),%rsi        # 1cc18 <_ZN10UEFIBridgeL9g_handlerE+0x18>
    5d71:	48 83 ec 08          	sub    $0x8,%rsp
    5d75:	48 89 05 44 6f 01 00 	mov    %rax,0x16f44(%rip)        # 1ccc0 <_ZN10UEFIBridgeL10g_proc_memE>
    5d7c:	4c 8d 2d 3d 6f 01 00 	lea    0x16f3d(%rip),%r13        # 1ccc0 <_ZN10UEFIBridgeL10g_proc_memE>
    5d83:	4c 8d 4e e8          	lea    -0x18(%rsi),%r9
    5d87:	66 49 0f 6e c4       	movq   %r12,%xmm0
    5d8c:	48 89 05 ed 6e 01 00 	mov    %rax,0x16eed(%rip)        # 1cc80 <_ZN10UEFIBridgeL8g_finderE>
    5d93:	48 8d 05 c6 5d 01 00 	lea    0x15dc6(%rip),%rax        # 1bb60 <_ZN10UEFIBridgeL14g_runtime_hookE>
    5d9a:	66 49 0f 6e d5       	movq   %r13,%xmm2
    5d9f:	48 8d 2d da 6e 01 00 	lea    0x16eda(%rip),%rbp        # 1cc80 <_ZN10UEFIBridgeL8g_finderE>
    5da6:	48 89 05 6b 6f 01 00 	mov    %rax,0x16f6b(%rip)        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
    5dad:	66 0f 6c c2          	punpcklqdq %xmm2,%xmm0
    5db1:	48 8d 05 18 74 01 00 	lea    0x17418(%rip),%rax        # 1d1d0 <BS>
    5db8:	4c 8d 35 81 6e 01 00 	lea    0x16e81(%rip),%r14        # 1cc40 <_ZN10UEFIBridgeL13g_cr3_captureE>
    5dbf:	48 c7 05 fe 6e 01 00 	movq   $0x0,0x16efe(%rip)        # 1ccc8 <_ZN10UEFIBridgeL10g_proc_memE+0x8>
    5dc6:	00 00 00 00 
    5dca:	4c 8d 05 7f a3 00 00 	lea    0xa37f(%rip),%r8        # 10150 <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_>
    5dd1:	ba 08 00 00 00       	mov    $0x8,%edx
    5dd6:	b9 00 02 00 80       	mov    $0x80000200,%ecx
    5ddb:	48 8b 00             	mov    (%rax),%rax
    5dde:	56                   	push   %rsi
    5ddf:	4c 89 35 2a 6f 01 00 	mov    %r14,0x16f2a(%rip)        # 1cd10 <_ZN10UEFIBridge10CR3Capture9instance_E>
    5de6:	48 89 2d 23 6e 01 00 	mov    %rbp,0x16e23(%rip)        # 1cc10 <_ZN10UEFIBridgeL9g_handlerE+0x10>
    5ded:	48 83 ec 20          	sub    $0x20,%rsp
    5df1:	c6 05 28 6e 01 00 01 	movb   $0x1,0x16e28(%rip)        # 1cc20 <_ZN10UEFIBridgeL9g_handlerE+0x20>
    5df8:	0f 29 05 01 6e 01 00 	movaps %xmm0,0x16e01(%rip)        # 1cc00 <_ZN10UEFIBridgeL9g_handlerE>
    5dff:	ff 50 50             	call   *0x50(%rax)
    5e02:	48 83 c4 30          	add    $0x30,%rsp
    5e06:	4c 8b 1c 24          	mov    (%rsp),%r11
    5e0a:	48 85 c0             	test   %rax,%rax
    5e0d:	48 89 c6             	mov    %rax,%rsi
    5e10:	0f 88 d3 07 00 00    	js     65e9 <efi_main+0x16b9>
    5e16:	48 8d 05 b3 73 01 00 	lea    0x173b3(%rip),%rax        # 1d1d0 <BS>
    5e1d:	48 83 ec 20          	sub    $0x20,%rsp
    5e21:	ba 01 00 00 00       	mov    $0x1,%edx
    5e26:	48 8b 0d eb 6d 01 00 	mov    0x16deb(%rip),%rcx        # 1cc18 <_ZN10UEFIBridgeL9g_handlerE+0x18>
    5e2d:	41 b8 10 27 00 00    	mov    $0x2710,%r8d
    5e33:	48 8b 00             	mov    (%rax),%rax
    5e36:	ff 50 58             	call   *0x58(%rax)
    5e39:	48 83 c4 20          	add    $0x20,%rsp
    5e3d:	4c 8b 1c 24          	mov    (%rsp),%r11
    5e41:	48 85 c0             	test   %rax,%rax
    5e44:	0f 88 70 07 00 00    	js     65ba <efi_main+0x168a>
    5e4a:	b8 0d 00 00 00       	mov    $0xd,%eax
    5e4f:	44 89 fa             	mov    %r15d,%edx
    5e52:	ee                   	out    %al,(%dx)
    5e53:	b8 0a 00 00 00       	mov    $0xa,%eax
    5e58:	ee                   	out    %al,(%dx)
    5e59:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5e5e:	48 8d 0d 9b e1 00 00 	lea    0xe19b(%rip),%rcx        # 14000 <_data>
    5e65:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5e6a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    5e70:	48 83 c1 01          	add    $0x1,%rcx
    5e74:	ee                   	out    %al,(%dx)
    5e75:	0f b6 01             	movzbl (%rcx),%eax
    5e78:	84 c0                	test   %al,%al
    5e7a:	75 f4                	jne    5e70 <efi_main+0xf40>
    5e7c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5e81:	ee                   	out    %al,(%dx)
    5e82:	b8 4d 00 00 00       	mov    $0x4d,%eax
    5e87:	48 8d 0d a0 e1 00 00 	lea    0xe1a0(%rip),%rcx        # 1402e <_data+0x2e>
    5e8e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5e93:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5e9a:	00 00 00 00 
    5e9e:	66 90                	xchg   %ax,%ax
    5ea0:	48 83 c1 01          	add    $0x1,%rcx
    5ea4:	ee                   	out    %al,(%dx)
    5ea5:	0f b6 01             	movzbl (%rcx),%eax
    5ea8:	84 c0                	test   %al,%al
    5eaa:	75 f4                	jne    5ea0 <efi_main+0xf70>
    5eac:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5eb1:	ee                   	out    %al,(%dx)
    5eb2:	b8 20 00 00 00       	mov    $0x20,%eax
    5eb7:	ee                   	out    %al,(%dx)
    5eb8:	b8 72 00 00 00       	mov    $0x72,%eax
    5ebd:	48 8d 0d bc e7 00 00 	lea    0xe7bc(%rip),%rcx        # 14680 <_data+0x680>
    5ec4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5ec9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5ed0:	48 83 c1 01          	add    $0x1,%rcx
    5ed4:	ee                   	out    %al,(%dx)
    5ed5:	0f b6 01             	movzbl (%rcx),%eax
    5ed8:	84 c0                	test   %al,%al
    5eda:	75 f4                	jne    5ed0 <efi_main+0xfa0>
    5edc:	48 8d 05 1d 6d 01 00 	lea    0x16d1d(%rip),%rax        # 1cc00 <_ZN10UEFIBridgeL9g_handlerE>
    5ee3:	48 8d 3d 76 5c 01 00 	lea    0x15c76(%rip),%rdi        # 1bb60 <_ZN10UEFIBridgeL14g_runtime_hookE>
    5eea:	89 54 24 08          	mov    %edx,0x8(%rsp)
    5eee:	4c 89 1c 24          	mov    %r11,(%rsp)
    5ef2:	48 89 05 67 5c 01 00 	mov    %rax,0x15c67(%rip)        # 1bb60 <_ZN10UEFIBridgeL14g_runtime_hookE>
    5ef9:	e8 82 a3 00 00       	call   10280 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv>
    5efe:	66 49 0f 6e dc       	movq   %r12,%xmm3
    5f03:	8b 54 24 08          	mov    0x8(%rsp),%edx
    5f07:	f3 0f 7e 05 81 ff 00 	movq   0xff81(%rip),%xmm0        # 15e90 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid+0x10>
    5f0e:	00 
    5f0f:	66 48 0f 6e e5       	movq   %rbp,%xmm4
    5f14:	48 8d 05 e5 6c 01 00 	lea    0x16ce5(%rip),%rax        # 1cc00 <_ZN10UEFIBridgeL9g_handlerE>
    5f1b:	4c 89 35 2e 5c 01 00 	mov    %r14,0x15c2e(%rip)        # 1bb50 <_ZN10UEFIBridgeL10g_va_graphE+0x30>
    5f22:	66 0f 6c c3          	punpcklqdq %xmm3,%xmm0
    5f26:	66 48 0f 6e c8       	movq   %rax,%xmm1
    5f2b:	b8 0d 00 00 00       	mov    $0xd,%eax
    5f30:	0f 29 05 e9 5b 01 00 	movaps %xmm0,0x15be9(%rip)        # 1bb20 <_ZN10UEFIBridgeL10g_va_graphE>
    5f37:	66 49 0f 6e c5       	movq   %r13,%xmm0
    5f3c:	66 0f 6c c4          	punpcklqdq %xmm4,%xmm0
    5f40:	0f 29 05 e9 5b 01 00 	movaps %xmm0,0x15be9(%rip)        # 1bb30 <_ZN10UEFIBridgeL10g_va_graphE+0x10>
    5f47:	66 0f 6f c1          	movdqa %xmm1,%xmm0
    5f4b:	0f 16 05 46 ff 00 00 	movhps 0xff46(%rip),%xmm0        # 15e98 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid+0x18>
    5f52:	0f 29 05 e7 5b 01 00 	movaps %xmm0,0x15be7(%rip)        # 1bb40 <_ZN10UEFIBridgeL10g_va_graphE+0x20>
    5f59:	ee                   	out    %al,(%dx)
    5f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
    5f5f:	ee                   	out    %al,(%dx)
    5f60:	4c 8b 1c 24          	mov    (%rsp),%r11
    5f64:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5f69:	48 8d 0d 90 e0 00 00 	lea    0xe090(%rip),%rcx        # 14000 <_data>
    5f70:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5f75:	4c 8d 15 84 ee 00 00 	lea    0xee84(%rip),%r10        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    5f7c:	0f 1f 40 00          	nopl   0x0(%rax)
    5f80:	48 83 c1 01          	add    $0x1,%rcx
    5f84:	ee                   	out    %al,(%dx)
    5f85:	0f b6 01             	movzbl (%rcx),%eax
    5f88:	84 c0                	test   %al,%al
    5f8a:	75 f4                	jne    5f80 <efi_main+0x1050>
    5f8c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    5f91:	ee                   	out    %al,(%dx)
    5f92:	b8 4d 00 00 00       	mov    $0x4d,%eax
    5f97:	48 8d 0d 90 e0 00 00 	lea    0xe090(%rip),%rcx        # 1402e <_data+0x2e>
    5f9e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5fa3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5faa:	00 00 00 00 
    5fae:	66 90                	xchg   %ax,%ax
    5fb0:	48 83 c1 01          	add    $0x1,%rcx
    5fb4:	ee                   	out    %al,(%dx)
    5fb5:	0f b6 01             	movzbl (%rcx),%eax
    5fb8:	84 c0                	test   %al,%al
    5fba:	75 f4                	jne    5fb0 <efi_main+0x1080>
    5fbc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    5fc1:	ee                   	out    %al,(%dx)
    5fc2:	b8 20 00 00 00       	mov    $0x20,%eax
    5fc7:	ee                   	out    %al,(%dx)
    5fc8:	b8 56 00 00 00       	mov    $0x56,%eax
    5fcd:	48 8d 0d 3f e1 00 00 	lea    0xe13f(%rip),%rcx        # 14113 <_data+0x113>
    5fd4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    5fd9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    5fe0:	48 83 c1 01          	add    $0x1,%rcx
    5fe4:	ee                   	out    %al,(%dx)
    5fe5:	0f b6 01             	movzbl (%rcx),%eax
    5fe8:	84 c0                	test   %al,%al
    5fea:	75 f4                	jne    5fe0 <efi_main+0x10b0>
    5fec:	f3 0f 7e 05 9c fe 00 	movq   0xfe9c(%rip),%xmm0        # 15e90 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid+0x10>
    5ff3:	00 
    5ff4:	66 48 0f 6e ed       	movq   %rbp,%xmm5
    5ff9:	48 8d 05 d0 71 01 00 	lea    0x171d0(%rip),%rax        # 1d1d0 <BS>
    6000:	4c 89 35 09 6d 01 00 	mov    %r14,0x16d09(%rip)        # 1cd10 <_ZN10UEFIBridge10CR3Capture9instance_E>
    6007:	66 0f 6c c5          	punpcklqdq %xmm5,%xmm0
    600b:	48 8b 30             	mov    (%rax),%rsi
    600e:	48 8d 05 6b 73 00 00 	lea    0x736b(%rip),%rax        # d380 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm>
    6015:	0f 29 05 24 6c 01 00 	movaps %xmm0,0x16c24(%rip)        # 1cc40 <_ZN10UEFIBridgeL13g_cr3_captureE>
    601c:	f3 0f 7e 05 74 fe 00 	movq   0xfe74(%rip),%xmm0        # 15e98 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid+0x18>
    6023:	00 
    6024:	48 8b be e8 00 00 00 	mov    0xe8(%rsi),%rdi
    602b:	48 89 86 e8 00 00 00 	mov    %rax,0xe8(%rsi)
    6032:	66 0f 6c c1          	punpcklqdq %xmm1,%xmm0
    6036:	0f 29 05 13 6c 01 00 	movaps %xmm0,0x16c13(%rip)        # 1cc50 <_ZN10UEFIBridgeL13g_cr3_captureE+0x10>
    603d:	44 8b 4e 0c          	mov    0xc(%rsi),%r9d
    6041:	48 89 3d c0 6c 01 00 	mov    %rdi,0x16cc0(%rip)        # 1cd08 <_ZN10UEFIBridge10CR3Capture13orig_exit_bs_E>
    6048:	c7 46 10 00 00 00 00 	movl   $0x0,0x10(%rsi)
    604f:	4d 85 c9             	test   %r9,%r9
    6052:	74 50                	je     60a4 <efi_main+0x1174>
    6054:	49 89 f0             	mov    %rsi,%r8
    6057:	49 01 f1             	add    %rsi,%r9
    605a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    605f:	90                   	nop
    6060:	41 0f b6 10          	movzbl (%r8),%edx
    6064:	31 d0                	xor    %edx,%eax
    6066:	ba 08 00 00 00       	mov    $0x8,%edx
    606b:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6072:	00 00 00 00 
    6076:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    607d:	00 00 00 
    6080:	89 c1                	mov    %eax,%ecx
    6082:	83 e0 01             	and    $0x1,%eax
    6085:	f7 d8                	neg    %eax
    6087:	d1 e9                	shr    $1,%ecx
    6089:	25 20 83 b8 ed       	and    $0xedb88320,%eax
    608e:	31 c8                	xor    %ecx,%eax
    6090:	83 ea 01             	sub    $0x1,%edx
    6093:	75 eb                	jne    6080 <efi_main+0x1150>
    6095:	49 83 c0 01          	add    $0x1,%r8
    6099:	4d 39 c8             	cmp    %r9,%r8
    609c:	75 c2                	jne    6060 <efi_main+0x1130>
    609e:	f7 d0                	not    %eax
    60a0:	89 44 24 24          	mov    %eax,0x24(%rsp)
    60a4:	8b 44 24 24          	mov    0x24(%rsp),%eax
    60a8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    60ad:	89 46 10             	mov    %eax,0x10(%rsi)
    60b0:	b8 0d 00 00 00       	mov    $0xd,%eax
    60b5:	ee                   	out    %al,(%dx)
    60b6:	b8 0a 00 00 00       	mov    $0xa,%eax
    60bb:	ee                   	out    %al,(%dx)
    60bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    60c1:	48 8d 0d 38 df 00 00 	lea    0xdf38(%rip),%rcx        # 14000 <_data>
    60c8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    60cf:	00 
    60d0:	48 83 c1 01          	add    $0x1,%rcx
    60d4:	ee                   	out    %al,(%dx)
    60d5:	0f b6 01             	movzbl (%rcx),%eax
    60d8:	84 c0                	test   %al,%al
    60da:	75 f4                	jne    60d0 <efi_main+0x11a0>
    60dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    60e1:	ee                   	out    %al,(%dx)
    60e2:	b8 45 00 00 00       	mov    $0x45,%eax
    60e7:	48 8d 0d ab e0 00 00 	lea    0xe0ab(%rip),%rcx        # 14199 <_data+0x199>
    60ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    60f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    60fa:	00 00 00 00 
    60fe:	66 90                	xchg   %ax,%ax
    6100:	48 83 c1 01          	add    $0x1,%rcx
    6104:	ee                   	out    %al,(%dx)
    6105:	0f b6 01             	movzbl (%rcx),%eax
    6108:	84 c0                	test   %al,%al
    610a:	75 f4                	jne    6100 <efi_main+0x11d0>
    610c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6111:	ee                   	out    %al,(%dx)
    6112:	b8 20 00 00 00       	mov    $0x20,%eax
    6117:	ee                   	out    %al,(%dx)
    6118:	b8 68 00 00 00       	mov    $0x68,%eax
    611d:	48 8d 0d 84 e5 00 00 	lea    0xe584(%rip),%rcx        # 146a8 <_data+0x6a8>
    6124:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6129:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6130:	48 83 c1 01          	add    $0x1,%rcx
    6134:	ee                   	out    %al,(%dx)
    6135:	0f b6 01             	movzbl (%rcx),%eax
    6138:	84 c0                	test   %al,%al
    613a:	75 f4                	jne    6130 <efi_main+0x1200>
    613c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    6141:	48 8d 0d 7e df 00 00 	lea    0xdf7e(%rip),%rcx        # 140c6 <_data+0xc6>
    6148:	ba f8 03 00 00       	mov    $0x3f8,%edx
    614d:	0f 1f 00             	nopl   (%rax)
    6150:	48 83 c1 01          	add    $0x1,%rcx
    6154:	ee                   	out    %al,(%dx)
    6155:	0f b6 01             	movzbl (%rcx),%eax
    6158:	84 c0                	test   %al,%al
    615a:	75 f4                	jne    6150 <efi_main+0x1220>
    615c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    6161:	bd f8 03 00 00       	mov    $0x3f8,%ebp
    6166:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    616d:	00 00 00 
    6170:	48 89 f8             	mov    %rdi,%rax
    6173:	89 ea                	mov    %ebp,%edx
    6175:	48 d3 e8             	shr    %cl,%rax
    6178:	83 e0 0f             	and    $0xf,%eax
    617b:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    6180:	ee                   	out    %al,(%dx)
    6181:	83 e9 04             	sub    $0x4,%ecx
    6184:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    6187:	75 e7                	jne    6170 <efi_main+0x1240>
    6189:	48 8d 44 24 70       	lea    0x70(%rsp),%rax
    618e:	4c 89 1c 24          	mov    %r11,(%rsp)
    6192:	45 31 c9             	xor    %r9d,%r9d
    6195:	ba 10 00 00 00       	mov    $0x10,%edx
    619a:	48 c7 44 24 70 00 00 	movq   $0x0,0x70(%rsp)
    61a1:	00 00 
    61a3:	4c 8d 05 c6 e3 ff ff 	lea    -0x1c3a(%rip),%r8        # 4570 <_ZN10UEFIBridgeL15VaChangeHandlerEPvS0_>
    61aa:	b9 00 02 00 00       	mov    $0x200,%ecx
    61af:	50                   	push   %rax
    61b0:	48 8d 05 b9 fc 00 00 	lea    0xfcb9(%rip),%rax        # 15e70 <_ZN10UEFIBridgeL33gEfiEventVirtualAddressChangeGuidE>
    61b7:	50                   	push   %rax
    61b8:	48 83 ec 20          	sub    $0x20,%rsp
    61bc:	ff 96 70 01 00 00    	call   *0x170(%rsi)
    61c2:	89 ea                	mov    %ebp,%edx
    61c4:	48 89 c6             	mov    %rax,%rsi
    61c7:	b8 0d 00 00 00       	mov    $0xd,%eax
    61cc:	ee                   	out    %al,(%dx)
    61cd:	b8 0a 00 00 00       	mov    $0xa,%eax
    61d2:	ee                   	out    %al,(%dx)
    61d3:	4c 8b 5c 24 30       	mov    0x30(%rsp),%r11
    61d8:	48 83 c4 30          	add    $0x30,%rsp
    61dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    61e1:	48 8d 0d 18 de 00 00 	lea    0xde18(%rip),%rcx        # 14000 <_data>
    61e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    61ed:	0f 1f 00             	nopl   (%rax)
    61f0:	48 83 c1 01          	add    $0x1,%rcx
    61f4:	ee                   	out    %al,(%dx)
    61f5:	0f b6 01             	movzbl (%rcx),%eax
    61f8:	84 c0                	test   %al,%al
    61fa:	75 f4                	jne    61f0 <efi_main+0x12c0>
    61fc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6201:	ee                   	out    %al,(%dx)
    6202:	b8 4d 00 00 00       	mov    $0x4d,%eax
    6207:	48 8d 0d 20 de 00 00 	lea    0xde20(%rip),%rcx        # 1402e <_data+0x2e>
    620e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6213:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    621a:	00 00 00 00 
    621e:	66 90                	xchg   %ax,%ax
    6220:	48 83 c1 01          	add    $0x1,%rcx
    6224:	ee                   	out    %al,(%dx)
    6225:	0f b6 01             	movzbl (%rcx),%eax
    6228:	84 c0                	test   %al,%al
    622a:	75 f4                	jne    6220 <efi_main+0x12f0>
    622c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6231:	ee                   	out    %al,(%dx)
    6232:	b8 20 00 00 00       	mov    $0x20,%eax
    6237:	ee                   	out    %al,(%dx)
    6238:	b8 56 00 00 00       	mov    $0x56,%eax
    623d:	48 8d 0d e2 de 00 00 	lea    0xdee2(%rip),%rcx        # 14126 <_data+0x126>
    6244:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6249:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6250:	48 83 c1 01          	add    $0x1,%rcx
    6254:	ee                   	out    %al,(%dx)
    6255:	0f b6 01             	movzbl (%rcx),%eax
    6258:	84 c0                	test   %al,%al
    625a:	75 f4                	jne    6250 <efi_main+0x1320>
    625c:	b8 20 00 00 00       	mov    $0x20,%eax
    6261:	48 8d 0d ef e0 00 00 	lea    0xe0ef(%rip),%rcx        # 14357 <_data+0x357>
    6268:	ba f8 03 00 00       	mov    $0x3f8,%edx
    626d:	0f 1f 00             	nopl   (%rax)
    6270:	48 83 c1 01          	add    $0x1,%rcx
    6274:	ee                   	out    %al,(%dx)
    6275:	0f b6 01             	movzbl (%rcx),%eax
    6278:	84 c0                	test   %al,%al
    627a:	75 f4                	jne    6270 <efi_main+0x1340>
    627c:	89 f7                	mov    %esi,%edi
    627e:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    6283:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6288:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    628f:	00 
    6290:	89 f8                	mov    %edi,%eax
    6292:	d3 e8                	shr    %cl,%eax
    6294:	83 e0 0f             	and    $0xf,%eax
    6297:	41 0f b6 04 03       	movzbl (%r11,%rax,1),%eax
    629c:	ee                   	out    %al,(%dx)
    629d:	83 e9 04             	sub    $0x4,%ecx
    62a0:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    62a3:	75 eb                	jne    6290 <efi_main+0x1360>
    62a5:	48 85 f6             	test   %rsi,%rsi
    62a8:	0f 88 05 05 00 00    	js     67b3 <efi_main+0x1883>
    62ae:	83 0d f7 6e 01 00 01 	orl    $0x1,0x16ef7(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
    62b5:	c7 05 f1 6e 01 00 01 	movl   $0x1,0x16ef1(%rip)        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
    62bc:	00 00 00 
    62bf:	c7 05 cf 6e 01 00 00 	movl   $0x0,0x16ecf(%rip)        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
    62c6:	00 00 00 
    62c9:	e8 32 66 00 00       	call   c900 <_ZN10UEFIBridge9DiagWriteEv>
    62ce:	48 8d 3d d3 e9 00 00 	lea    0xe9d3(%rip),%rdi        # 14ca8 <_data+0xca8>
    62d5:	31 c0                	xor    %eax,%eax
    62d7:	e8 04 2e 00 00       	call   90e0 <Print>
    62dc:	48 8d 3d 2d ea 00 00 	lea    0xea2d(%rip),%rdi        # 14d10 <_data+0xd10>
    62e3:	31 c0                	xor    %eax,%eax
    62e5:	e8 f6 2d 00 00       	call   90e0 <Print>
    62ea:	48 8d 3d 8f ea 00 00 	lea    0xea8f(%rip),%rdi        # 14d80 <_data+0xd80>
    62f1:	31 c0                	xor    %eax,%eax
    62f3:	e8 e8 2d 00 00       	call   90e0 <Print>
    62f8:	48 8d 05 d1 6e 01 00 	lea    0x16ed1(%rip),%rax        # 1d1d0 <BS>
    62ff:	48 83 ec 20          	sub    $0x20,%rsp
    6303:	b9 c0 c6 2d 00       	mov    $0x2dc6c0,%ecx
    6308:	48 8b 00             	mov    (%rax),%rax
    630b:	ff 90 f8 00 00 00    	call   *0xf8(%rax)
    6311:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6316:	b8 0d 00 00 00       	mov    $0xd,%eax
    631b:	ee                   	out    %al,(%dx)
    631c:	b8 0a 00 00 00       	mov    $0xa,%eax
    6321:	ee                   	out    %al,(%dx)
    6322:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6327:	48 83 c4 20          	add    $0x20,%rsp
    632b:	48 8d 0d ce dc 00 00 	lea    0xdcce(%rip),%rcx        # 14000 <_data>
    6332:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6339:	00 00 00 00 
    633d:	0f 1f 00             	nopl   (%rax)
    6340:	48 83 c1 01          	add    $0x1,%rcx
    6344:	ee                   	out    %al,(%dx)
    6345:	0f b6 01             	movzbl (%rcx),%eax
    6348:	84 c0                	test   %al,%al
    634a:	75 f4                	jne    6340 <efi_main+0x1410>
    634c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6351:	ee                   	out    %al,(%dx)
    6352:	b8 4d 00 00 00       	mov    $0x4d,%eax
    6357:	48 8d 0d d0 dc 00 00 	lea    0xdcd0(%rip),%rcx        # 1402e <_data+0x2e>
    635e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6363:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    636a:	00 00 00 00 
    636e:	66 90                	xchg   %ax,%ax
    6370:	48 83 c1 01          	add    $0x1,%rcx
    6374:	ee                   	out    %al,(%dx)
    6375:	0f b6 01             	movzbl (%rcx),%eax
    6378:	84 c0                	test   %al,%al
    637a:	75 f4                	jne    6370 <efi_main+0x1440>
    637c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6381:	ee                   	out    %al,(%dx)
    6382:	b8 20 00 00 00       	mov    $0x20,%eax
    6387:	ee                   	out    %al,(%dx)
    6388:	b8 65 00 00 00       	mov    $0x65,%eax
    638d:	48 8d 0d a8 dd 00 00 	lea    0xdda8(%rip),%rcx        # 1413c <_data+0x13c>
    6394:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6399:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    63a0:	48 83 c1 01          	add    $0x1,%rcx
    63a4:	ee                   	out    %al,(%dx)
    63a5:	0f b6 01             	movzbl (%rcx),%eax
    63a8:	84 c0                	test   %al,%al
    63aa:	75 f4                	jne    63a0 <efi_main+0x1470>
    63ac:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
    63b3:	48 89 d8             	mov    %rbx,%rax
    63b6:	5b                   	pop    %rbx
    63b7:	5d                   	pop    %rbp
    63b8:	41 5c                	pop    %r12
    63ba:	41 5d                	pop    %r13
    63bc:	41 5e                	pop    %r14
    63be:	41 5f                	pop    %r15
    63c0:	c3                   	ret
    63c1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    63c8:	b8 30 00 00 00       	mov    $0x30,%eax
    63cd:	ee                   	out    %al,(%dx)
    63ce:	e9 cb f6 ff ff       	jmp    5a9e <efi_main+0xb6e>
    63d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    63d8:	b8 30 00 00 00       	mov    $0x30,%eax
    63dd:	ee                   	out    %al,(%dx)
    63de:	e9 7b f8 ff ff       	jmp    5c5e <efi_main+0xd2e>
    63e3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    63e8:	48 89 c6             	mov    %rax,%rsi
    63eb:	48 8d 3d 86 e7 00 00 	lea    0xe786(%rip),%rdi        # 14b78 <_data+0xb78>
    63f2:	31 c0                	xor    %eax,%eax
    63f4:	4c 89 1c 24          	mov    %r11,(%rsp)
    63f8:	e8 e3 2c 00 00       	call   90e0 <Print>
    63fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6402:	b8 0d 00 00 00       	mov    $0xd,%eax
    6407:	ee                   	out    %al,(%dx)
    6408:	b8 0a 00 00 00       	mov    $0xa,%eax
    640d:	ee                   	out    %al,(%dx)
    640e:	4c 8b 1c 24          	mov    (%rsp),%r11
    6412:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6417:	48 8d 0d e2 db 00 00 	lea    0xdbe2(%rip),%rcx        # 14000 <_data>
    641e:	66 90                	xchg   %ax,%ax
    6420:	48 83 c1 01          	add    $0x1,%rcx
    6424:	ee                   	out    %al,(%dx)
    6425:	0f b6 01             	movzbl (%rcx),%eax
    6428:	84 c0                	test   %al,%al
    642a:	75 f4                	jne    6420 <efi_main+0x14f0>
    642c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6431:	ee                   	out    %al,(%dx)
    6432:	b8 4d 00 00 00       	mov    $0x4d,%eax
    6437:	48 8d 0d f0 db 00 00 	lea    0xdbf0(%rip),%rcx        # 1402e <_data+0x2e>
    643e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6443:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    644a:	00 00 00 00 
    644e:	66 90                	xchg   %ax,%ax
    6450:	48 83 c1 01          	add    $0x1,%rcx
    6454:	ee                   	out    %al,(%dx)
    6455:	0f b6 01             	movzbl (%rcx),%eax
    6458:	84 c0                	test   %al,%al
    645a:	75 f4                	jne    6450 <efi_main+0x1520>
    645c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6461:	ee                   	out    %al,(%dx)
    6462:	b8 20 00 00 00       	mov    $0x20,%eax
    6467:	ee                   	out    %al,(%dx)
    6468:	b8 70 00 00 00       	mov    $0x70,%eax
    646d:	48 8d 0d 79 dc 00 00 	lea    0xdc79(%rip),%rcx        # 140ed <_data+0xed>
    6474:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6479:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6480:	48 83 c1 01          	add    $0x1,%rcx
    6484:	ee                   	out    %al,(%dx)
    6485:	0f b6 01             	movzbl (%rcx),%eax
    6488:	84 c0                	test   %al,%al
    648a:	75 f4                	jne    6480 <efi_main+0x1550>
    648c:	b8 20 00 00 00       	mov    $0x20,%eax
    6491:	48 8d 0d bf de 00 00 	lea    0xdebf(%rip),%rcx        # 14357 <_data+0x357>
    6498:	ba f8 03 00 00       	mov    $0x3f8,%edx
    649d:	0f 1f 00             	nopl   (%rax)
    64a0:	48 83 c1 01          	add    $0x1,%rcx
    64a4:	ee                   	out    %al,(%dx)
    64a5:	0f b6 01             	movzbl (%rcx),%eax
    64a8:	84 c0                	test   %al,%al
    64aa:	75 f4                	jne    64a0 <efi_main+0x1570>
    64ac:	89 de                	mov    %ebx,%esi
    64ae:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    64b3:	ba f8 03 00 00       	mov    $0x3f8,%edx
    64b8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    64bf:	00 
    64c0:	89 f0                	mov    %esi,%eax
    64c2:	d3 e8                	shr    %cl,%eax
    64c4:	83 e0 0f             	and    $0xf,%eax
    64c7:	41 0f b6 04 03       	movzbl (%r11,%rax,1),%eax
    64cc:	ee                   	out    %al,(%dx)
    64cd:	83 e9 04             	sub    $0x4,%ecx
    64d0:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    64d3:	75 eb                	jne    64c0 <efi_main+0x1590>
    64d5:	e9 d2 fe ff ff       	jmp    63ac <efi_main+0x147c>
    64da:	ba f8 03 00 00       	mov    $0x3f8,%edx
    64df:	b8 0d 00 00 00       	mov    $0xd,%eax
    64e4:	ee                   	out    %al,(%dx)
    64e5:	b8 0a 00 00 00       	mov    $0xa,%eax
    64ea:	ee                   	out    %al,(%dx)
    64eb:	b8 5b 00 00 00       	mov    $0x5b,%eax
    64f0:	48 8d 0d 09 db 00 00 	lea    0xdb09(%rip),%rcx        # 14000 <_data>
    64f7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    64fe:	00 00 
    6500:	48 83 c1 01          	add    $0x1,%rcx
    6504:	ee                   	out    %al,(%dx)
    6505:	0f b6 01             	movzbl (%rcx),%eax
    6508:	84 c0                	test   %al,%al
    650a:	75 f4                	jne    6500 <efi_main+0x15d0>
    650c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6511:	ee                   	out    %al,(%dx)
    6512:	b8 4d 00 00 00       	mov    $0x4d,%eax
    6517:	48 8d 0d 77 db 00 00 	lea    0xdb77(%rip),%rcx        # 14095 <_data+0x95>
    651e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6523:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    652a:	00 00 00 00 
    652e:	66 90                	xchg   %ax,%ax
    6530:	48 83 c1 01          	add    $0x1,%rcx
    6534:	ee                   	out    %al,(%dx)
    6535:	0f b6 01             	movzbl (%rcx),%eax
    6538:	84 c0                	test   %al,%al
    653a:	75 f4                	jne    6530 <efi_main+0x1600>
    653c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6541:	ee                   	out    %al,(%dx)
    6542:	b8 20 00 00 00       	mov    $0x20,%eax
    6547:	ee                   	out    %al,(%dx)
    6548:	b8 47 00 00 00       	mov    $0x47,%eax
    654d:	48 8d 0d 46 db 00 00 	lea    0xdb46(%rip),%rcx        # 1409a <_data+0x9a>
    6554:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6559:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6560:	48 83 c1 01          	add    $0x1,%rcx
    6564:	ee                   	out    %al,(%dx)
    6565:	0f b6 01             	movzbl (%rcx),%eax
    6568:	84 c0                	test   %al,%al
    656a:	75 f4                	jne    6560 <efi_main+0x1630>
    656c:	b8 20 00 00 00       	mov    $0x20,%eax
    6571:	48 8d 0d df dd 00 00 	lea    0xdddf(%rip),%rcx        # 14357 <_data+0x357>
    6578:	ba f8 03 00 00       	mov    $0x3f8,%edx
    657d:	0f 1f 00             	nopl   (%rax)
    6580:	48 83 c1 01          	add    $0x1,%rcx
    6584:	ee                   	out    %al,(%dx)
    6585:	0f b6 01             	movzbl (%rcx),%eax
    6588:	84 c0                	test   %al,%al
    658a:	75 f4                	jne    6580 <efi_main+0x1650>
    658c:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    6591:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6596:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    659d:	00 00 00 
    65a0:	89 f0                	mov    %esi,%eax
    65a2:	d3 e8                	shr    %cl,%eax
    65a4:	83 e0 0f             	and    $0xf,%eax
    65a7:	41 0f b6 04 03       	movzbl (%r11,%rax,1),%eax
    65ac:	ee                   	out    %al,(%dx)
    65ad:	83 e9 04             	sub    $0x4,%ecx
    65b0:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    65b3:	75 eb                	jne    65a0 <efi_main+0x1670>
    65b5:	e9 eb f6 ff ff       	jmp    5ca5 <efi_main+0xd75>
    65ba:	48 89 04 24          	mov    %rax,(%rsp)
    65be:	48 8d 05 0b 6c 01 00 	lea    0x16c0b(%rip),%rax        # 1d1d0 <BS>
    65c5:	48 83 ec 20          	sub    $0x20,%rsp
    65c9:	4c 89 5c 24 28       	mov    %r11,0x28(%rsp)
    65ce:	48 8b 0d 43 66 01 00 	mov    0x16643(%rip),%rcx        # 1cc18 <_ZN10UEFIBridgeL9g_handlerE+0x18>
    65d5:	48 8b 00             	mov    (%rax),%rax
    65d8:	ff 50 70             	call   *0x70(%rax)
    65db:	48 8b 74 24 20       	mov    0x20(%rsp),%rsi
    65e0:	4c 8b 5c 24 28       	mov    0x28(%rsp),%r11
    65e5:	48 83 c4 20          	add    $0x20,%rsp
    65e9:	48 8d 3d f0 e5 00 00 	lea    0xe5f0(%rip),%rdi        # 14be0 <_data+0xbe0>
    65f0:	31 c0                	xor    %eax,%eax
    65f2:	4c 89 5c 24 08       	mov    %r11,0x8(%rsp)
    65f7:	48 89 34 24          	mov    %rsi,(%rsp)
    65fb:	e8 e0 2a 00 00       	call   90e0 <Print>
    6600:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6605:	b8 0d 00 00 00       	mov    $0xd,%eax
    660a:	ee                   	out    %al,(%dx)
    660b:	b8 0a 00 00 00       	mov    $0xa,%eax
    6610:	ee                   	out    %al,(%dx)
    6611:	48 8b 34 24          	mov    (%rsp),%rsi
    6615:	4c 8b 5c 24 08       	mov    0x8(%rsp),%r11
    661a:	b8 5b 00 00 00       	mov    $0x5b,%eax
    661f:	48 8d 0d da d9 00 00 	lea    0xd9da(%rip),%rcx        # 14000 <_data>
    6626:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    662d:	00 00 00 
    6630:	48 83 c1 01          	add    $0x1,%rcx
    6634:	ee                   	out    %al,(%dx)
    6635:	0f b6 01             	movzbl (%rcx),%eax
    6638:	84 c0                	test   %al,%al
    663a:	75 f4                	jne    6630 <efi_main+0x1700>
    663c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    6641:	ee                   	out    %al,(%dx)
    6642:	b8 4d 00 00 00       	mov    $0x4d,%eax
    6647:	48 8d 0d e0 d9 00 00 	lea    0xd9e0(%rip),%rcx        # 1402e <_data+0x2e>
    664e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6653:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    665a:	00 00 00 00 
    665e:	66 90                	xchg   %ax,%ax
    6660:	48 83 c1 01          	add    $0x1,%rcx
    6664:	ee                   	out    %al,(%dx)
    6665:	0f b6 01             	movzbl (%rcx),%eax
    6668:	84 c0                	test   %al,%al
    666a:	75 f4                	jne    6660 <efi_main+0x1730>
    666c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    6671:	ee                   	out    %al,(%dx)
    6672:	b8 20 00 00 00       	mov    $0x20,%eax
    6677:	ee                   	out    %al,(%dx)
    6678:	b8 68 00 00 00       	mov    $0x68,%eax
    667d:	48 8d 0d 7a da 00 00 	lea    0xda7a(%rip),%rcx        # 140fe <_data+0xfe>
    6684:	ba f8 03 00 00       	mov    $0x3f8,%edx
    6689:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6690:	48 83 c1 01          	add    $0x1,%rcx
    6694:	ee                   	out    %al,(%dx)
    6695:	0f b6 01             	movzbl (%rcx),%eax
    6698:	84 c0                	test   %al,%al
    669a:	75 f4                	jne    6690 <efi_main+0x1760>
    669c:	b8 20 00 00 00       	mov    $0x20,%eax
    66a1:	48 8d 0d af dc 00 00 	lea    0xdcaf(%rip),%rcx        # 14357 <_data+0x357>
    66a8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    66ad:	0f 1f 00             	nopl   (%rax)
    66b0:	48 83 c1 01          	add    $0x1,%rcx
    66b4:	ee                   	out    %al,(%dx)
    66b5:	0f b6 01             	movzbl (%rcx),%eax
    66b8:	84 c0                	test   %al,%al
    66ba:	75 f4                	jne    66b0 <efi_main+0x1780>
    66bc:	89 f7                	mov    %esi,%edi
    66be:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    66c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
    66c8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    66cf:	00 
    66d0:	89 f8                	mov    %edi,%eax
    66d2:	d3 e8                	shr    %cl,%eax
    66d4:	83 e0 0f             	and    $0xf,%eax
    66d7:	41 0f b6 04 03       	movzbl (%r11,%rax,1),%eax
    66dc:	ee                   	out    %al,(%dx)
    66dd:	83 e9 04             	sub    $0x4,%ecx
    66e0:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    66e3:	75 eb                	jne    66d0 <efi_main+0x17a0>
    66e5:	48 8b 05 f4 65 01 00 	mov    0x165f4(%rip),%rax        # 1cce0 <_ZN10UEFIBridgeL6g_poolE+0x10>
    66ec:	48 85 c0             	test   %rax,%rax
    66ef:	74 07                	je     66f8 <efi_main+0x17c8>
    66f1:	c7 40 40 00 00 00 00 	movl   $0x0,0x40(%rax)
    66f8:	48 8b 0d d1 65 01 00 	mov    0x165d1(%rip),%rcx        # 1ccd0 <_ZN10UEFIBridgeL6g_poolE>
    66ff:	48 85 c9             	test   %rcx,%rcx
    6702:	74 3b                	je     673f <efi_main+0x180f>
    6704:	48 8d 05 c5 6a 01 00 	lea    0x16ac5(%rip),%rax        # 1d1d0 <BS>
    670b:	48 8b 38             	mov    (%rax),%rdi
    670e:	48 85 ff             	test   %rdi,%rdi
    6711:	74 2c                	je     673f <efi_main+0x180f>
    6713:	48 8b 05 be 65 01 00 	mov    0x165be(%rip),%rax        # 1ccd8 <_ZN10UEFIBridgeL6g_poolE+0x8>
    671a:	31 d2                	xor    %edx,%edx
    671c:	48 89 34 24          	mov    %rsi,(%rsp)
    6720:	a9 ff 0f 00 00       	test   $0xfff,%eax
    6725:	0f 95 c2             	setne  %dl
    6728:	48 83 ec 20          	sub    $0x20,%rsp
    672c:	48 c1 e8 0c          	shr    $0xc,%rax
    6730:	48 01 c2             	add    %rax,%rdx
    6733:	ff 57 30             	call   *0x30(%rdi)
    6736:	48 8b 74 24 20       	mov    0x20(%rsp),%rsi
    673b:	48 83 c4 20          	add    $0x20,%rsp
    673f:	48 8d 05 da 6a 01 00 	lea    0x16ada(%rip),%rax        # 1d220 <RT>
    6746:	48 8b 00             	mov    (%rax),%rax
    6749:	48 85 c0             	test   %rax,%rax
    674c:	74 31                	je     677f <efi_main+0x184f>
    674e:	48 89 34 24          	mov    %rsi,(%rsp)
    6752:	48 83 ec 08          	sub    $0x8,%rsp
    6756:	45 31 c9             	xor    %r9d,%r9d
    6759:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    675f:	6a 00                	push   $0x0
    6761:	48 8d 15 f8 f6 00 00 	lea    0xf6f8(%rip),%rdx        # 15e60 <_ZN10UEFIBridge19gInfinityMemVarGuidE>
    6768:	48 8d 0d fb e0 00 00 	lea    0xe0fb(%rip),%rcx        # 1486a <_data+0x86a>
    676f:	48 83 ec 20          	sub    $0x20,%rsp
    6773:	ff 50 58             	call   *0x58(%rax)
    6776:	48 8b 74 24 30       	mov    0x30(%rsp),%rsi
    677b:	48 83 c4 30          	add    $0x30,%rsp
    677f:	48 c7 05 46 65 01 00 	movq   $0x0,0x16546(%rip)        # 1ccd0 <_ZN10UEFIBridgeL6g_poolE>
    6786:	00 00 00 00 
    678a:	48 89 f3             	mov    %rsi,%rbx
    678d:	48 c7 05 48 65 01 00 	movq   $0x0,0x16548(%rip)        # 1cce0 <_ZN10UEFIBridgeL6g_poolE+0x10>
    6794:	00 00 00 00 
    6798:	e9 0f fc ff ff       	jmp    63ac <efi_main+0x147c>
    679d:	b8 30 00 00 00       	mov    $0x30,%eax
    67a2:	ee                   	out    %al,(%dx)
    67a3:	e9 34 ee ff ff       	jmp    55dc <efi_main+0x6ac>
    67a8:	b8 30 00 00 00       	mov    $0x30,%eax
    67ad:	ee                   	out    %al,(%dx)
    67ae:	e9 e9 ec ff ff       	jmp    549c <efi_main+0x56c>
    67b3:	48 8d 3d 7e e4 00 00 	lea    0xe47e(%rip),%rdi        # 14c38 <_data+0xc38>
    67ba:	31 c0                	xor    %eax,%eax
    67bc:	e8 1f 29 00 00       	call   90e0 <Print>
    67c1:	e9 e8 fa ff ff       	jmp    62ae <efi_main+0x137e>
    67c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    67cd:	00 00 00 

00000000000067d0 <_relocate>:
    67d0:	f3 0f 1e fa          	endbr64
    67d4:	48 8b 06             	mov    (%rsi),%rax
    67d7:	48 85 c0             	test   %rax,%rax
    67da:	74 7e                	je     685a <_relocate+0x8a>
    67dc:	48 83 c6 08          	add    $0x8,%rsi
    67e0:	31 d2                	xor    %edx,%edx
    67e2:	45 31 c0             	xor    %r8d,%r8d
    67e5:	31 c9                	xor    %ecx,%ecx
    67e7:	eb 1a                	jmp    6803 <_relocate+0x33>
    67e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    67f0:	48 83 f8 07          	cmp    $0x7,%rax
    67f4:	74 72                	je     6868 <_relocate+0x98>
    67f6:	48 8b 46 08          	mov    0x8(%rsi),%rax
    67fa:	48 83 c6 10          	add    $0x10,%rsi
    67fe:	48 85 c0             	test   %rax,%rax
    6801:	74 1c                	je     681f <_relocate+0x4f>
    6803:	48 83 f8 08          	cmp    $0x8,%rax
    6807:	74 57                	je     6860 <_relocate+0x90>
    6809:	48 83 f8 09          	cmp    $0x9,%rax
    680d:	75 e1                	jne    67f0 <_relocate+0x20>
    680f:	4c 8b 06             	mov    (%rsi),%r8
    6812:	48 8b 46 08          	mov    0x8(%rsi),%rax
    6816:	48 83 c6 10          	add    $0x10,%rsi
    681a:	48 85 c0             	test   %rax,%rax
    681d:	75 e4                	jne    6803 <_relocate+0x33>
    681f:	48 89 d0             	mov    %rdx,%rax
    6822:	4c 09 c0             	or     %r8,%rax
    6825:	74 33                	je     685a <_relocate+0x8a>
    6827:	48 85 d2             	test   %rdx,%rdx
    682a:	74 44                	je     6870 <_relocate+0xa0>
    682c:	4d 85 c0             	test   %r8,%r8
    682f:	74 3f                	je     6870 <_relocate+0xa0>
    6831:	48 85 c9             	test   %rcx,%rcx
    6834:	7e 24                	jle    685a <_relocate+0x8a>
    6836:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    683d:	00 00 00 
    6840:	83 7a 08 08          	cmpl   $0x8,0x8(%rdx)
    6844:	75 09                	jne    684f <_relocate+0x7f>
    6846:	48 8b 02             	mov    (%rdx),%rax
    6849:	48 01 f8             	add    %rdi,%rax
    684c:	48 01 38             	add    %rdi,(%rax)
    684f:	4c 29 c1             	sub    %r8,%rcx
    6852:	4c 01 c2             	add    %r8,%rdx
    6855:	48 85 c9             	test   %rcx,%rcx
    6858:	7f e6                	jg     6840 <_relocate+0x70>
    685a:	31 c0                	xor    %eax,%eax
    685c:	c3                   	ret
    685d:	0f 1f 00             	nopl   (%rax)
    6860:	48 8b 0e             	mov    (%rsi),%rcx
    6863:	eb 91                	jmp    67f6 <_relocate+0x26>
    6865:	0f 1f 00             	nopl   (%rax)
    6868:	48 8b 16             	mov    (%rsi),%rdx
    686b:	48 01 fa             	add    %rdi,%rdx
    686e:	eb 86                	jmp    67f6 <_relocate+0x26>
    6870:	48 b8 01 00 00 00 00 	movabs $0x8000000000000001,%rax
    6877:	00 00 80 
    687a:	c3                   	ret
    687b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000006880 <InitializeGuid>:
    6880:	f3 0f 1e fa          	endbr64
    6884:	c3                   	ret
    6885:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    688c:	00 00 00 00 

0000000000006890 <CompareGuid>:
    6890:	f3 0f 1e fa          	endbr64
    6894:	e9 07 35 00 00       	jmp    9da0 <RtCompareGuid>
    6899:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000068a0 <GuidToString>:
    68a0:	f3 0f 1e fa          	endbr64
    68a4:	41 55                	push   %r13
    68a6:	49 89 f5             	mov    %rsi,%r13
    68a9:	48 8d 35 10 69 01 00 	lea    0x16910(%rip),%rsi        # 1d1c0 <NullGuid>
    68b0:	41 54                	push   %r12
    68b2:	49 89 fc             	mov    %rdi,%r12
    68b5:	55                   	push   %rbp
    68b6:	31 ed                	xor    %ebp,%ebp
    68b8:	53                   	push   %rbx
    68b9:	48 8d 1d 70 fb 00 00 	lea    0xfb70(%rip),%rbx        # 16430 <KnownGuids+0x10>
    68c0:	48 83 ec 48          	sub    $0x48,%rsp
    68c4:	eb 1a                	jmp    68e0 <GuidToString+0x40>
    68c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    68cd:	00 00 00 
    68d0:	48 8b 33             	mov    (%rbx),%rsi
    68d3:	48 83 c3 10          	add    $0x10,%rbx
    68d7:	48 83 c5 01          	add    $0x1,%rbp
    68db:	48 85 f6             	test   %rsi,%rsi
    68de:	74 38                	je     6918 <GuidToString+0x78>
    68e0:	4c 89 ef             	mov    %r13,%rdi
    68e3:	e8 b8 34 00 00       	call   9da0 <RtCompareGuid>
    68e8:	48 85 c0             	test   %rax,%rax
    68eb:	75 e3                	jne    68d0 <GuidToString+0x30>
    68ed:	48 c1 e5 04          	shl    $0x4,%rbp
    68f1:	48 8d 05 28 fb 00 00 	lea    0xfb28(%rip),%rax        # 16420 <KnownGuids>
    68f8:	4c 89 e7             	mov    %r12,%rdi
    68fb:	31 f6                	xor    %esi,%esi
    68fd:	48 8b 54 28 08       	mov    0x8(%rax,%rbp,1),%rdx
    6902:	48 83 c4 48          	add    $0x48,%rsp
    6906:	31 c0                	xor    %eax,%eax
    6908:	5b                   	pop    %rbx
    6909:	5d                   	pop    %rbp
    690a:	41 5c                	pop    %r12
    690c:	41 5d                	pop    %r13
    690e:	e9 3d 25 00 00       	jmp    8e50 <UnicodeSPrint>
    6913:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6918:	41 0f b6 45 0f       	movzbl 0xf(%r13),%eax
    691d:	45 0f b7 4d 06       	movzwl 0x6(%r13),%r9d
    6922:	4c 89 e7             	mov    %r12,%rdi
    6925:	48 8d 15 2c e5 00 00 	lea    0xe52c(%rip),%rdx        # 14e58 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x58>
    692c:	45 0f b7 45 04       	movzwl 0x4(%r13),%r8d
    6931:	41 8b 4d 00          	mov    0x0(%r13),%ecx
    6935:	89 44 24 38          	mov    %eax,0x38(%rsp)
    6939:	41 0f b6 45 0e       	movzbl 0xe(%r13),%eax
    693e:	89 44 24 30          	mov    %eax,0x30(%rsp)
    6942:	41 0f b6 45 0d       	movzbl 0xd(%r13),%eax
    6947:	89 44 24 28          	mov    %eax,0x28(%rsp)
    694b:	41 0f b6 45 0c       	movzbl 0xc(%r13),%eax
    6950:	89 44 24 20          	mov    %eax,0x20(%rsp)
    6954:	41 0f b6 45 0b       	movzbl 0xb(%r13),%eax
    6959:	89 44 24 18          	mov    %eax,0x18(%rsp)
    695d:	41 0f b6 45 0a       	movzbl 0xa(%r13),%eax
    6962:	89 44 24 10          	mov    %eax,0x10(%rsp)
    6966:	41 0f b6 45 09       	movzbl 0x9(%r13),%eax
    696b:	89 44 24 08          	mov    %eax,0x8(%rsp)
    696f:	41 0f b6 45 08       	movzbl 0x8(%r13),%eax
    6974:	89 04 24             	mov    %eax,(%rsp)
    6977:	31 c0                	xor    %eax,%eax
    6979:	e8 d2 24 00 00       	call   8e50 <UnicodeSPrint>
    697e:	48 83 c4 48          	add    $0x48,%rsp
    6982:	5b                   	pop    %rbx
    6983:	5d                   	pop    %rbp
    6984:	41 5c                	pop    %r12
    6986:	41 5d                	pop    %r13
    6988:	c3                   	ret
    6989:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000006990 <InitializeUnicodeSupport>:
    6990:	f3 0f 1e fa          	endbr64
    6994:	41 57                	push   %r15
    6996:	31 d2                	xor    %edx,%edx
    6998:	41 56                	push   %r14
    699a:	4c 8d 35 9f f8 00 00 	lea    0xf89f(%rip),%r14        # 16240 <gEfiUnicodeCollationProtocolGuid>
    69a1:	41 55                	push   %r13
    69a3:	4c 89 f6             	mov    %r14,%rsi
    69a6:	41 54                	push   %r12
    69a8:	55                   	push   %rbp
    69a9:	53                   	push   %rbx
    69aa:	48 89 fb             	mov    %rdi,%rbx
    69ad:	bf 02 00 00 00       	mov    $0x2,%edi
    69b2:	48 83 ec 58          	sub    $0x58,%rsp
    69b6:	48 8d 4c 24 40       	lea    0x40(%rsp),%rcx
    69bb:	4c 8d 44 24 48       	lea    0x48(%rsp),%r8
    69c0:	e8 bb 52 00 00       	call   bc80 <LibLocateHandle>
    69c5:	48 85 db             	test   %rbx,%rbx
    69c8:	74 46                	je     6a10 <InitializeUnicodeSupport+0x80>
    69ca:	48 83 7c 24 40 00    	cmpq   $0x0,0x40(%rsp)
    69d0:	74 3e                	je     6a10 <InitializeUnicodeSupport+0x80>
    69d2:	48 8d 44 24 38       	lea    0x38(%rsp),%rax
    69d7:	45 31 ed             	xor    %r13d,%r13d
    69da:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    69df:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    69e4:	4c 8b 44 24 28       	mov    0x28(%rsp),%r8
    69e9:	4c 89 f2             	mov    %r14,%rdx
    69ec:	4a 8b 0c e8          	mov    (%rax,%r13,8),%rcx
    69f0:	48 8b 05 d9 67 01 00 	mov    0x167d9(%rip),%rax        # 1d1d0 <BS>
    69f7:	ff 90 98 00 00 00    	call   *0x98(%rax)
    69fd:	48 85 c0             	test   %rax,%rax
    6a00:	79 2e                	jns    6a30 <InitializeUnicodeSupport+0xa0>
    6a02:	49 83 c5 01          	add    $0x1,%r13
    6a06:	4c 39 6c 24 40       	cmp    %r13,0x40(%rsp)
    6a0b:	77 d2                	ja     69df <InitializeUnicodeSupport+0x4f>
    6a0d:	0f 1f 00             	nopl   (%rax)
    6a10:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
    6a15:	48 85 ff             	test   %rdi,%rdi
    6a18:	74 05                	je     6a1f <InitializeUnicodeSupport+0x8f>
    6a1a:	e8 21 03 00 00       	call   6d40 <FreePool>
    6a1f:	48 83 c4 58          	add    $0x58,%rsp
    6a23:	5b                   	pop    %rbx
    6a24:	5d                   	pop    %rbp
    6a25:	41 5c                	pop    %r12
    6a27:	41 5d                	pop    %r13
    6a29:	41 5e                	pop    %r14
    6a2b:	41 5f                	pop    %r15
    6a2d:	c3                   	ret
    6a2e:	66 90                	xchg   %ax,%ax
    6a30:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    6a35:	4c 8b 60 30          	mov    0x30(%rax),%r12
    6a39:	4c 89 e7             	mov    %r12,%rdi
    6a3c:	e8 9f 2e 00 00       	call   98e0 <strlena>
    6a41:	48 89 c5             	mov    %rax,%rbp
    6a44:	48 85 c0             	test   %rax,%rax
    6a47:	74 b9                	je     6a02 <InitializeUnicodeSupport+0x72>
    6a49:	45 31 ff             	xor    %r15d,%r15d
    6a4c:	eb 0b                	jmp    6a59 <InitializeUnicodeSupport+0xc9>
    6a4e:	66 90                	xchg   %ax,%ax
    6a50:	49 83 c7 03          	add    $0x3,%r15
    6a54:	4c 39 fd             	cmp    %r15,%rbp
    6a57:	76 a9                	jbe    6a02 <InitializeUnicodeSupport+0x72>
    6a59:	4b 8d 3c 3c          	lea    (%r12,%r15,1),%rdi
    6a5d:	ba 03 00 00 00       	mov    $0x3,%edx
    6a62:	48 89 de             	mov    %rbx,%rsi
    6a65:	e8 26 03 00 00       	call   6d90 <CompareMem>
    6a6a:	48 85 c0             	test   %rax,%rax
    6a6d:	75 e1                	jne    6a50 <InitializeUnicodeSupport+0xc0>
    6a6f:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    6a74:	48 89 05 e5 f8 00 00 	mov    %rax,0xf8e5(%rip)        # 16360 <UnicodeInterface>
    6a7b:	eb 93                	jmp    6a10 <InitializeUnicodeSupport+0x80>
    6a7d:	0f 1f 00             	nopl   (%rax)

0000000000006a80 <EFIDebugVariable>:
    6a80:	f3 0f 1e fa          	endbr64
    6a84:	48 83 ec 58          	sub    $0x58,%rsp
    6a88:	48 8d 15 a1 f8 00 00 	lea    0xf8a1(%rip),%rdx        # 16330 <gEfiGlobalVariableGuid>
    6a8f:	48 8d 0d aa e6 00 00 	lea    0xe6aa(%rip),%rcx        # 15140 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x340>
    6a96:	48 8d 44 24 48       	lea    0x48(%rsp),%rax
    6a9b:	4c 8d 4c 24 40       	lea    0x40(%rsp),%r9
    6aa0:	48 c7 44 24 40 08 00 	movq   $0x8,0x40(%rsp)
    6aa7:	00 00 
    6aa9:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    6aae:	48 8b 05 6b 67 01 00 	mov    0x1676b(%rip),%rax        # 1d220 <RT>
    6ab5:	4c 8d 44 24 3c       	lea    0x3c(%rsp),%r8
    6aba:	ff 50 48             	call   *0x48(%rax)
    6abd:	48 85 c0             	test   %rax,%rax
    6ac0:	78 0c                	js     6ace <EFIDebugVariable+0x4e>
    6ac2:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    6ac7:	48 89 05 12 fc 00 00 	mov    %rax,0xfc12(%rip)        # 166e0 <EFIDebug>
    6ace:	48 83 c4 58          	add    $0x58,%rsp
    6ad2:	c3                   	ret
    6ad3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6ada:	00 00 00 00 
    6ade:	66 90                	xchg   %ax,%ax

0000000000006ae0 <InitializeLib>:
    6ae0:	f3 0f 1e fa          	endbr64
    6ae4:	55                   	push   %rbp
    6ae5:	53                   	push   %rbx
    6ae6:	48 89 fb             	mov    %rdi,%rbx
    6ae9:	48 83 ec 38          	sub    $0x38,%rsp
    6aed:	80 3d f4 66 01 00 00 	cmpb   $0x0,0x166f4(%rip)        # 1d1e8 <LibInitialized>
    6af4:	75 77                	jne    6b6d <InitializeLib+0x8d>
    6af6:	48 8b 46 60          	mov    0x60(%rsi),%rax
    6afa:	48 8b 56 58          	mov    0x58(%rsi),%rdx
    6afe:	c6 05 e3 66 01 00 01 	movb   $0x1,0x166e3(%rip)        # 1d1e8 <LibInitialized>
    6b05:	48 89 f5             	mov    %rsi,%rbp
    6b08:	c6 05 09 67 01 00 00 	movb   $0x0,0x16709(%rip)        # 1d218 <LibFwInstance>
    6b0f:	48 89 3d ca 66 01 00 	mov    %rdi,0x166ca(%rip)        # 1d1e0 <LibImageHandle>
    6b16:	48 89 35 bb 66 01 00 	mov    %rsi,0x166bb(%rip)        # 1d1d8 <ST>
    6b1d:	48 89 05 ac 66 01 00 	mov    %rax,0x166ac(%rip)        # 1d1d0 <BS>
    6b24:	48 89 15 f5 66 01 00 	mov    %rdx,0x166f5(%rip)        # 1d220 <RT>
    6b2b:	48 85 ff             	test   %rdi,%rdi
    6b2e:	74 2d                	je     6b5d <InitializeLib+0x7d>
    6b30:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    6b35:	48 8d 15 a4 f7 00 00 	lea    0xf7a4(%rip),%rdx        # 162e0 <gEfiLoadedImageProtocolGuid>
    6b3c:	48 89 f9             	mov    %rdi,%rcx
    6b3f:	ff 90 98 00 00 00    	call   *0x98(%rax)
    6b45:	48 85 c0             	test   %rax,%rax
    6b48:	78 0e                	js     6b58 <InitializeLib+0x78>
    6b4a:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    6b4f:	8b 40 54             	mov    0x54(%rax),%eax
    6b52:	89 05 f4 f7 00 00    	mov    %eax,0xf7f4(%rip)        # 1634c <PoolAllocationType>
    6b58:	e8 23 ff ff ff       	call   6a80 <EFIDebugVariable>
    6b5d:	e8 1e fd ff ff       	call   6880 <InitializeGuid>
    6b62:	48 89 ee             	mov    %rbp,%rsi
    6b65:	48 89 df             	mov    %rbx,%rdi
    6b68:	e8 e3 35 00 00       	call   a150 <InitializeLibPlatform>
    6b6d:	48 85 db             	test   %rbx,%rbx
    6b70:	74 10                	je     6b82 <InitializeLib+0xa2>
    6b72:	48 8d 05 07 f8 00 00 	lea    0xf807(%rip),%rax        # 16380 <LibStubUnicodeInterface>
    6b79:	48 39 05 e0 f7 00 00 	cmp    %rax,0xf7e0(%rip)        # 16360 <UnicodeInterface>
    6b80:	74 0e                	je     6b90 <InitializeLib+0xb0>
    6b82:	48 83 c4 38          	add    $0x38,%rsp
    6b86:	5b                   	pop    %rbx
    6b87:	5d                   	pop    %rbp
    6b88:	c3                   	ret
    6b89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6b90:	48 8d 3d bb e5 00 00 	lea    0xe5bb(%rip),%rdi        # 15152 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x352>
    6b97:	48 8d 35 92 f7 00 00 	lea    0xf792(%rip),%rsi        # 16330 <gEfiGlobalVariableGuid>
    6b9e:	e8 bd 04 00 00       	call   7060 <LibGetVariable>
    6ba3:	48 89 c5             	mov    %rax,%rbp
    6ba6:	48 89 c7             	mov    %rax,%rdi
    6ba9:	e8 e2 fd ff ff       	call   6990 <InitializeUnicodeSupport>
    6bae:	48 85 ed             	test   %rbp,%rbp
    6bb1:	74 cf                	je     6b82 <InitializeLib+0xa2>
    6bb3:	48 89 ef             	mov    %rbp,%rdi
    6bb6:	e8 85 01 00 00       	call   6d40 <FreePool>
    6bbb:	eb c5                	jmp    6b82 <InitializeLib+0xa2>
    6bbd:	0f 1f 00             	nopl   (%rax)

0000000000006bc0 <memset>:
    6bc0:	f3 0f 1e fa          	endbr64
    6bc4:	48 89 f8             	mov    %rdi,%rax
    6bc7:	4c 8d 04 17          	lea    (%rdi,%rdx,1),%r8
    6bcb:	48 89 f9             	mov    %rdi,%rcx
    6bce:	48 85 d2             	test   %rdx,%rdx
    6bd1:	74 12                	je     6be5 <memset+0x25>
    6bd3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6bd8:	48 83 c1 01          	add    $0x1,%rcx
    6bdc:	40 88 71 ff          	mov    %sil,-0x1(%rcx)
    6be0:	4c 39 c1             	cmp    %r8,%rcx
    6be3:	75 f3                	jne    6bd8 <memset+0x18>
    6be5:	c3                   	ret
    6be6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    6bed:	00 00 00 

0000000000006bf0 <memcpy>:
    6bf0:	f3 0f 1e fa          	endbr64
    6bf4:	48 89 f8             	mov    %rdi,%rax
    6bf7:	48 85 d2             	test   %rdx,%rdx
    6bfa:	74 16                	je     6c12 <memcpy+0x22>
    6bfc:	31 c9                	xor    %ecx,%ecx
    6bfe:	66 90                	xchg   %ax,%ax
    6c00:	44 0f b6 04 0e       	movzbl (%rsi,%rcx,1),%r8d
    6c05:	44 88 04 08          	mov    %r8b,(%rax,%rcx,1)
    6c09:	48 83 c1 01          	add    $0x1,%rcx
    6c0d:	48 39 d1             	cmp    %rdx,%rcx
    6c10:	75 ee                	jne    6c00 <memcpy+0x10>
    6c12:	c3                   	ret
    6c13:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    6c1a:	00 00 00 
    6c1d:	0f 1f 00             	nopl   (%rax)

0000000000006c20 <AllocatePool>:
    6c20:	f3 0f 1e fa          	endbr64
    6c24:	48 83 ec 38          	sub    $0x38,%rsp
    6c28:	48 8b 05 a1 65 01 00 	mov    0x165a1(%rip),%rax        # 1d1d0 <BS>
    6c2f:	8b 0d 17 f7 00 00    	mov    0xf717(%rip),%ecx        # 1634c <PoolAllocationType>
    6c35:	48 89 fa             	mov    %rdi,%rdx
    6c38:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    6c3d:	ff 50 40             	call   *0x40(%rax)
    6c40:	48 85 c0             	test   %rax,%rax
    6c43:	b8 00 00 00 00       	mov    $0x0,%eax
    6c48:	48 0f 49 44 24 28    	cmovns 0x28(%rsp),%rax
    6c4e:	48 83 c4 38          	add    $0x38,%rsp
    6c52:	c3                   	ret
    6c53:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6c5a:	00 00 00 00 
    6c5e:	66 90                	xchg   %ax,%ax

0000000000006c60 <AllocateZeroPool>:
    6c60:	f3 0f 1e fa          	endbr64
    6c64:	41 54                	push   %r12
    6c66:	48 89 fa             	mov    %rdi,%rdx
    6c69:	45 31 e4             	xor    %r12d,%r12d
    6c6c:	55                   	push   %rbp
    6c6d:	48 89 fd             	mov    %rdi,%rbp
    6c70:	48 83 ec 38          	sub    $0x38,%rsp
    6c74:	48 8b 05 55 65 01 00 	mov    0x16555(%rip),%rax        # 1d1d0 <BS>
    6c7b:	8b 0d cb f6 00 00    	mov    0xf6cb(%rip),%ecx        # 1634c <PoolAllocationType>
    6c81:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    6c86:	ff 50 40             	call   *0x40(%rax)
    6c89:	48 85 c0             	test   %rax,%rax
    6c8c:	78 15                	js     6ca3 <AllocateZeroPool+0x43>
    6c8e:	4c 8b 64 24 28       	mov    0x28(%rsp),%r12
    6c93:	4d 85 e4             	test   %r12,%r12
    6c96:	74 0b                	je     6ca3 <AllocateZeroPool+0x43>
    6c98:	48 89 ee             	mov    %rbp,%rsi
    6c9b:	4c 89 e7             	mov    %r12,%rdi
    6c9e:	e8 fd 2f 00 00       	call   9ca0 <RtZeroMem>
    6ca3:	48 83 c4 38          	add    $0x38,%rsp
    6ca7:	4c 89 e0             	mov    %r12,%rax
    6caa:	5d                   	pop    %rbp
    6cab:	41 5c                	pop    %r12
    6cad:	c3                   	ret
    6cae:	66 90                	xchg   %ax,%ax

0000000000006cb0 <ReallocatePool>:
    6cb0:	f3 0f 1e fa          	endbr64
    6cb4:	41 55                	push   %r13
    6cb6:	41 54                	push   %r12
    6cb8:	49 89 fc             	mov    %rdi,%r12
    6cbb:	55                   	push   %rbp
    6cbc:	53                   	push   %rbx
    6cbd:	48 83 ec 38          	sub    $0x38,%rsp
    6cc1:	48 85 d2             	test   %rdx,%rdx
    6cc4:	74 62                	je     6d28 <ReallocatePool+0x78>
    6cc6:	48 8b 05 03 65 01 00 	mov    0x16503(%rip),%rax        # 1d1d0 <BS>
    6ccd:	8b 0d 79 f6 00 00    	mov    0xf679(%rip),%ecx        # 1634c <PoolAllocationType>
    6cd3:	48 89 f5             	mov    %rsi,%rbp
    6cd6:	48 89 d3             	mov    %rdx,%rbx
    6cd9:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    6cde:	ff 50 40             	call   *0x40(%rax)
    6ce1:	48 85 c0             	test   %rax,%rax
    6ce4:	78 42                	js     6d28 <ReallocatePool+0x78>
    6ce6:	4c 8b 6c 24 28       	mov    0x28(%rsp),%r13
    6ceb:	4d 85 e4             	test   %r12,%r12
    6cee:	74 27                	je     6d17 <ReallocatePool+0x67>
    6cf0:	4d 85 ed             	test   %r13,%r13
    6cf3:	74 15                	je     6d0a <ReallocatePool+0x5a>
    6cf5:	48 39 eb             	cmp    %rbp,%rbx
    6cf8:	48 89 ea             	mov    %rbp,%rdx
    6cfb:	4c 89 e6             	mov    %r12,%rsi
    6cfe:	4c 89 ef             	mov    %r13,%rdi
    6d01:	48 0f 46 d3          	cmovbe %rbx,%rdx
    6d05:	e8 d6 2f 00 00       	call   9ce0 <RtCopyMem>
    6d0a:	48 8b 05 bf 64 01 00 	mov    0x164bf(%rip),%rax        # 1d1d0 <BS>
    6d11:	4c 89 e1             	mov    %r12,%rcx
    6d14:	ff 50 48             	call   *0x48(%rax)
    6d17:	48 83 c4 38          	add    $0x38,%rsp
    6d1b:	4c 89 e8             	mov    %r13,%rax
    6d1e:	5b                   	pop    %rbx
    6d1f:	5d                   	pop    %rbp
    6d20:	41 5c                	pop    %r12
    6d22:	41 5d                	pop    %r13
    6d24:	c3                   	ret
    6d25:	0f 1f 00             	nopl   (%rax)
    6d28:	45 31 ed             	xor    %r13d,%r13d
    6d2b:	4d 85 e4             	test   %r12,%r12
    6d2e:	75 da                	jne    6d0a <ReallocatePool+0x5a>
    6d30:	48 83 c4 38          	add    $0x38,%rsp
    6d34:	4c 89 e8             	mov    %r13,%rax
    6d37:	5b                   	pop    %rbx
    6d38:	5d                   	pop    %rbp
    6d39:	41 5c                	pop    %r12
    6d3b:	41 5d                	pop    %r13
    6d3d:	c3                   	ret
    6d3e:	66 90                	xchg   %ax,%ax

0000000000006d40 <FreePool>:
    6d40:	f3 0f 1e fa          	endbr64
    6d44:	48 83 ec 28          	sub    $0x28,%rsp
    6d48:	48 8b 05 81 64 01 00 	mov    0x16481(%rip),%rax        # 1d1d0 <BS>
    6d4f:	48 89 f9             	mov    %rdi,%rcx
    6d52:	ff 50 48             	call   *0x48(%rax)
    6d55:	48 83 c4 28          	add    $0x28,%rsp
    6d59:	c3                   	ret
    6d5a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000006d60 <ZeroMem>:
    6d60:	f3 0f 1e fa          	endbr64
    6d64:	e9 37 2f 00 00       	jmp    9ca0 <RtZeroMem>
    6d69:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000006d70 <SetMem>:
    6d70:	f3 0f 1e fa          	endbr64
    6d74:	0f b6 d2             	movzbl %dl,%edx
    6d77:	e9 44 2f 00 00       	jmp    9cc0 <RtSetMem>
    6d7c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000006d80 <CopyMem>:
    6d80:	f3 0f 1e fa          	endbr64
    6d84:	e9 57 2f 00 00       	jmp    9ce0 <RtCopyMem>
    6d89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000006d90 <CompareMem>:
    6d90:	f3 0f 1e fa          	endbr64
    6d94:	e9 c7 2f 00 00       	jmp    9d60 <RtCompareMem>
    6d99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000006da0 <GrowBuffer>:
    6da0:	f3 0f 1e fa          	endbr64
    6da4:	41 54                	push   %r12
    6da6:	49 89 d4             	mov    %rdx,%r12
    6da9:	55                   	push   %rbp
    6daa:	48 89 fd             	mov    %rdi,%rbp
    6dad:	53                   	push   %rbx
    6dae:	48 89 f3             	mov    %rsi,%rbx
    6db1:	48 83 ec 30          	sub    $0x30,%rsp
    6db5:	48 8b 0e             	mov    (%rsi),%rcx
    6db8:	48 85 d2             	test   %rdx,%rdx
    6dbb:	74 05                	je     6dc2 <GrowBuffer+0x22>
    6dbd:	48 85 c9             	test   %rcx,%rcx
    6dc0:	74 5e                	je     6e20 <GrowBuffer+0x80>
    6dc2:	48 ba 05 00 00 00 00 	movabs $0x8000000000000005,%rdx
    6dc9:	00 00 80 
    6dcc:	48 8b 45 00          	mov    0x0(%rbp),%rax
    6dd0:	48 39 d0             	cmp    %rdx,%rax
    6dd3:	74 5b                	je     6e30 <GrowBuffer+0x90>
    6dd5:	48 85 c0             	test   %rax,%rax
    6dd8:	78 26                	js     6e00 <GrowBuffer+0x60>
    6dda:	48 83 c4 30          	add    $0x30,%rsp
    6dde:	31 c0                	xor    %eax,%eax
    6de0:	5b                   	pop    %rbx
    6de1:	5d                   	pop    %rbp
    6de2:	41 5c                	pop    %r12
    6de4:	c3                   	ret
    6de5:	0f 1f 00             	nopl   (%rax)
    6de8:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    6def:	48 b8 09 00 00 00 00 	movabs $0x8000000000000009,%rax
    6df6:	00 00 80 
    6df9:	48 89 45 00          	mov    %rax,0x0(%rbp)
    6dfd:	48 8b 0b             	mov    (%rbx),%rcx
    6e00:	48 85 c9             	test   %rcx,%rcx
    6e03:	74 d5                	je     6dda <GrowBuffer+0x3a>
    6e05:	48 8b 05 c4 63 01 00 	mov    0x163c4(%rip),%rax        # 1d1d0 <BS>
    6e0c:	ff 50 48             	call   *0x48(%rax)
    6e0f:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    6e16:	eb c2                	jmp    6dda <GrowBuffer+0x3a>
    6e18:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    6e1f:	00 
    6e20:	48 b8 05 00 00 00 00 	movabs $0x8000000000000005,%rax
    6e27:	00 00 80 
    6e2a:	48 89 07             	mov    %rax,(%rdi)
    6e2d:	48 8b 0e             	mov    (%rsi),%rcx
    6e30:	48 85 c9             	test   %rcx,%rcx
    6e33:	74 0a                	je     6e3f <GrowBuffer+0x9f>
    6e35:	48 8b 05 94 63 01 00 	mov    0x16394(%rip),%rax        # 1d1d0 <BS>
    6e3c:	ff 50 48             	call   *0x48(%rax)
    6e3f:	48 8b 05 8a 63 01 00 	mov    0x1638a(%rip),%rax        # 1d1d0 <BS>
    6e46:	8b 0d 00 f5 00 00    	mov    0xf500(%rip),%ecx        # 1634c <PoolAllocationType>
    6e4c:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    6e51:	4c 89 e2             	mov    %r12,%rdx
    6e54:	ff 50 40             	call   *0x40(%rax)
    6e57:	48 85 c0             	test   %rax,%rax
    6e5a:	78 8c                	js     6de8 <GrowBuffer+0x48>
    6e5c:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    6e61:	48 89 03             	mov    %rax,(%rbx)
    6e64:	48 85 c0             	test   %rax,%rax
    6e67:	74 86                	je     6def <GrowBuffer+0x4f>
    6e69:	48 83 c4 30          	add    $0x30,%rsp
    6e6d:	b8 01 00 00 00       	mov    $0x1,%eax
    6e72:	5b                   	pop    %rbx
    6e73:	5d                   	pop    %rbp
    6e74:	41 5c                	pop    %r12
    6e76:	c3                   	ret
    6e77:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    6e7e:	00 00 

0000000000006e80 <LibMemoryMap>:
    6e80:	f3 0f 1e fa          	endbr64
    6e84:	41 57                	push   %r15
    6e86:	41 56                	push   %r14
    6e88:	41 55                	push   %r13
    6e8a:	49 bd 05 00 00 00 00 	movabs $0x8000000000000005,%r13
    6e91:	00 00 80 
    6e94:	41 54                	push   %r12
    6e96:	49 89 f4             	mov    %rsi,%r12
    6e99:	55                   	push   %rbp
    6e9a:	48 89 cd             	mov    %rcx,%rbp
    6e9d:	53                   	push   %rbx
    6e9e:	48 89 d3             	mov    %rdx,%rbx
    6ea1:	ba 28 00 00 00       	mov    $0x28,%edx
    6ea6:	48 83 ec 58          	sub    $0x58,%rsp
    6eaa:	48 89 7c 24 38       	mov    %rdi,0x38(%rsp)
    6eaf:	4c 8d 74 24 48       	lea    0x48(%rsp),%r14
    6eb4:	48 c7 44 24 40 28 00 	movq   $0x28,0x40(%rsp)
    6ebb:	00 00 
    6ebd:	48 8b 05 0c 63 01 00 	mov    0x1630c(%rip),%rax        # 1d1d0 <BS>
    6ec4:	8b 0d 82 f4 00 00    	mov    0xf482(%rip),%ecx        # 1634c <PoolAllocationType>
    6eca:	4d 89 f0             	mov    %r14,%r8
    6ecd:	ff 50 40             	call   *0x40(%rax)
    6ed0:	48 85 c0             	test   %rax,%rax
    6ed3:	0f 88 97 00 00 00    	js     6f70 <LibMemoryMap+0xf0>
    6ed9:	4c 8b 7c 24 48       	mov    0x48(%rsp),%r15
    6ede:	4d 85 ff             	test   %r15,%r15
    6ee1:	0f 84 89 00 00 00    	je     6f70 <LibMemoryMap+0xf0>
    6ee7:	48 8b 05 e2 62 01 00 	mov    0x162e2(%rip),%rax        # 1d1d0 <BS>
    6eee:	4c 89 fa             	mov    %r15,%rdx
    6ef1:	49 89 d9             	mov    %rbx,%r9
    6ef4:	4d 89 e0             	mov    %r12,%r8
    6ef7:	48 89 6c 24 20       	mov    %rbp,0x20(%rsp)
    6efc:	48 8d 4c 24 40       	lea    0x40(%rsp),%rcx
    6f01:	ff 50 38             	call   *0x38(%rax)
    6f04:	48 8b 54 24 40       	mov    0x40(%rsp),%rdx
    6f09:	4c 39 e8             	cmp    %r13,%rax
    6f0c:	74 2a                	je     6f38 <LibMemoryMap+0xb8>
    6f0e:	48 85 c0             	test   %rax,%rax
    6f11:	78 45                	js     6f58 <LibMemoryMap+0xd8>
    6f13:	48 89 d0             	mov    %rdx,%rax
    6f16:	31 d2                	xor    %edx,%edx
    6f18:	48 8b 74 24 38       	mov    0x38(%rsp),%rsi
    6f1d:	48 f7 33             	divq   (%rbx)
    6f20:	48 89 06             	mov    %rax,(%rsi)
    6f23:	48 83 c4 58          	add    $0x58,%rsp
    6f27:	4c 89 f8             	mov    %r15,%rax
    6f2a:	5b                   	pop    %rbx
    6f2b:	5d                   	pop    %rbp
    6f2c:	41 5c                	pop    %r12
    6f2e:	41 5d                	pop    %r13
    6f30:	41 5e                	pop    %r14
    6f32:	41 5f                	pop    %r15
    6f34:	c3                   	ret
    6f35:	0f 1f 00             	nopl   (%rax)
    6f38:	48 8b 05 91 62 01 00 	mov    0x16291(%rip),%rax        # 1d1d0 <BS>
    6f3f:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    6f44:	4c 89 f9             	mov    %r15,%rcx
    6f47:	ff 50 48             	call   *0x48(%rax)
    6f4a:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    6f4f:	e9 69 ff ff ff       	jmp    6ebd <LibMemoryMap+0x3d>
    6f54:	0f 1f 40 00          	nopl   0x0(%rax)
    6f58:	48 8b 05 71 62 01 00 	mov    0x16271(%rip),%rax        # 1d1d0 <BS>
    6f5f:	4c 89 f9             	mov    %r15,%rcx
    6f62:	45 31 ff             	xor    %r15d,%r15d
    6f65:	ff 50 48             	call   *0x48(%rax)
    6f68:	eb b9                	jmp    6f23 <LibMemoryMap+0xa3>
    6f6a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    6f70:	45 31 ff             	xor    %r15d,%r15d
    6f73:	eb ae                	jmp    6f23 <LibMemoryMap+0xa3>
    6f75:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6f7c:	00 00 00 00 

0000000000006f80 <LibGetVariableAndSize>:
    6f80:	f3 0f 1e fa          	endbr64
    6f84:	41 57                	push   %r15
    6f86:	41 56                	push   %r14
    6f88:	41 be 64 00 00 00    	mov    $0x64,%r14d
    6f8e:	41 55                	push   %r13
    6f90:	41 54                	push   %r12
    6f92:	49 bc 05 00 00 00 00 	movabs $0x8000000000000005,%r12
    6f99:	00 00 80 
    6f9c:	55                   	push   %rbp
    6f9d:	48 89 fd             	mov    %rdi,%rbp
    6fa0:	53                   	push   %rbx
    6fa1:	48 89 f3             	mov    %rsi,%rbx
    6fa4:	48 83 ec 58          	sub    $0x58,%rsp
    6fa8:	48 89 54 24 38       	mov    %rdx,0x38(%rsp)
    6fad:	4c 8d 6c 24 48       	lea    0x48(%rsp),%r13
    6fb2:	48 c7 44 24 40 64 00 	movq   $0x64,0x40(%rsp)
    6fb9:	00 00 
    6fbb:	48 8b 05 0e 62 01 00 	mov    0x1620e(%rip),%rax        # 1d1d0 <BS>
    6fc2:	8b 0d 84 f3 00 00    	mov    0xf384(%rip),%ecx        # 1634c <PoolAllocationType>
    6fc8:	4d 89 e8             	mov    %r13,%r8
    6fcb:	4c 89 f2             	mov    %r14,%rdx
    6fce:	ff 50 40             	call   *0x40(%rax)
    6fd1:	48 85 c0             	test   %rax,%rax
    6fd4:	78 67                	js     703d <LibGetVariableAndSize+0xbd>
    6fd6:	4c 8b 7c 24 48       	mov    0x48(%rsp),%r15
    6fdb:	4d 85 ff             	test   %r15,%r15
    6fde:	74 7a                	je     705a <LibGetVariableAndSize+0xda>
    6fe0:	48 8b 05 39 62 01 00 	mov    0x16239(%rip),%rax        # 1d220 <RT>
    6fe7:	45 31 c0             	xor    %r8d,%r8d
    6fea:	48 89 da             	mov    %rbx,%rdx
    6fed:	48 89 e9             	mov    %rbp,%rcx
    6ff0:	4c 89 7c 24 20       	mov    %r15,0x20(%rsp)
    6ff5:	4c 8d 4c 24 40       	lea    0x40(%rsp),%r9
    6ffa:	ff 50 48             	call   *0x48(%rax)
    6ffd:	4c 8b 74 24 40       	mov    0x40(%rsp),%r14
    7002:	4c 39 e0             	cmp    %r12,%rax
    7005:	74 41                	je     7048 <LibGetVariableAndSize+0xc8>
    7007:	48 85 c0             	test   %rax,%rax
    700a:	78 24                	js     7030 <LibGetVariableAndSize+0xb0>
    700c:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    7011:	4c 89 30             	mov    %r14,(%rax)
    7014:	48 83 c4 58          	add    $0x58,%rsp
    7018:	4c 89 f8             	mov    %r15,%rax
    701b:	5b                   	pop    %rbx
    701c:	5d                   	pop    %rbp
    701d:	41 5c                	pop    %r12
    701f:	41 5d                	pop    %r13
    7021:	41 5e                	pop    %r14
    7023:	41 5f                	pop    %r15
    7025:	c3                   	ret
    7026:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    702d:	00 00 00 
    7030:	48 8b 05 99 61 01 00 	mov    0x16199(%rip),%rax        # 1d1d0 <BS>
    7037:	4c 89 f9             	mov    %r15,%rcx
    703a:	ff 50 48             	call   *0x48(%rax)
    703d:	45 31 f6             	xor    %r14d,%r14d
    7040:	45 31 ff             	xor    %r15d,%r15d
    7043:	eb c7                	jmp    700c <LibGetVariableAndSize+0x8c>
    7045:	0f 1f 00             	nopl   (%rax)
    7048:	48 8b 05 81 61 01 00 	mov    0x16181(%rip),%rax        # 1d1d0 <BS>
    704f:	4c 89 f9             	mov    %r15,%rcx
    7052:	ff 50 48             	call   *0x48(%rax)
    7055:	e9 61 ff ff ff       	jmp    6fbb <LibGetVariableAndSize+0x3b>
    705a:	45 31 f6             	xor    %r14d,%r14d
    705d:	eb ad                	jmp    700c <LibGetVariableAndSize+0x8c>
    705f:	90                   	nop

0000000000007060 <LibGetVariable>:
    7060:	f3 0f 1e fa          	endbr64
    7064:	48 83 ec 18          	sub    $0x18,%rsp
    7068:	48 8d 54 24 08       	lea    0x8(%rsp),%rdx
    706d:	e8 0e ff ff ff       	call   6f80 <LibGetVariableAndSize>
    7072:	48 83 c4 18          	add    $0x18,%rsp
    7076:	c3                   	ret
    7077:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    707e:	00 00 

0000000000007080 <LibDeleteVariable>:
    7080:	f3 0f 1e fa          	endbr64
    7084:	41 57                	push   %r15
    7086:	49 bf 0e 00 00 00 00 	movabs $0x800000000000000e,%r15
    708d:	00 00 80 
    7090:	41 56                	push   %r14
    7092:	49 89 f6             	mov    %rsi,%r14
    7095:	41 55                	push   %r13
    7097:	49 89 fd             	mov    %rdi,%r13
    709a:	41 54                	push   %r12
    709c:	48 83 ec 48          	sub    $0x48,%rsp
    70a0:	48 8d 54 24 38       	lea    0x38(%rsp),%rdx
    70a5:	e8 d6 fe ff ff       	call   6f80 <LibGetVariableAndSize>
    70aa:	48 85 c0             	test   %rax,%rax
    70ad:	74 35                	je     70e4 <LibDeleteVariable+0x64>
    70af:	49 89 c4             	mov    %rax,%r12
    70b2:	48 8b 05 67 61 01 00 	mov    0x16167(%rip),%rax        # 1d220 <RT>
    70b9:	4c 89 e9             	mov    %r13,%rcx
    70bc:	45 31 c9             	xor    %r9d,%r9d
    70bf:	48 c7 44 24 20 00 00 	movq   $0x0,0x20(%rsp)
    70c6:	00 00 
    70c8:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    70ce:	4c 89 f2             	mov    %r14,%rdx
    70d1:	ff 50 58             	call   *0x58(%rax)
    70d4:	4c 89 e1             	mov    %r12,%rcx
    70d7:	49 89 c7             	mov    %rax,%r15
    70da:	48 8b 05 ef 60 01 00 	mov    0x160ef(%rip),%rax        # 1d1d0 <BS>
    70e1:	ff 50 48             	call   *0x48(%rax)
    70e4:	48 83 c4 48          	add    $0x48,%rsp
    70e8:	4c 89 f8             	mov    %r15,%rax
    70eb:	41 5c                	pop    %r12
    70ed:	41 5d                	pop    %r13
    70ef:	41 5e                	pop    %r14
    70f1:	41 5f                	pop    %r15
    70f3:	c3                   	ret
    70f4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    70fb:	00 00 00 00 
    70ff:	90                   	nop

0000000000007100 <LibSetNVVariable>:
    7100:	f3 0f 1e fa          	endbr64
    7104:	48 83 ec 38          	sub    $0x38,%rsp
    7108:	48 8b 05 11 61 01 00 	mov    0x16111(%rip),%rax        # 1d220 <RT>
    710f:	49 89 d1             	mov    %rdx,%r9
    7112:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    7118:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
    711d:	48 89 f2             	mov    %rsi,%rdx
    7120:	48 89 f9             	mov    %rdi,%rcx
    7123:	ff 50 58             	call   *0x58(%rax)
    7126:	48 83 c4 38          	add    $0x38,%rsp
    712a:	c3                   	ret
    712b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000007130 <LibSetVariable>:
    7130:	f3 0f 1e fa          	endbr64
    7134:	48 83 ec 38          	sub    $0x38,%rsp
    7138:	48 8b 05 e1 60 01 00 	mov    0x160e1(%rip),%rax        # 1d220 <RT>
    713f:	49 89 d1             	mov    %rdx,%r9
    7142:	41 b8 06 00 00 00    	mov    $0x6,%r8d
    7148:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
    714d:	48 89 f2             	mov    %rsi,%rdx
    7150:	48 89 f9             	mov    %rdi,%rcx
    7153:	ff 50 58             	call   *0x58(%rax)
    7156:	48 83 c4 38          	add    $0x38,%rsp
    715a:	c3                   	ret
    715b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000007160 <LibInsertToTailOfBootOrder>:
    7160:	f3 0f 1e fa          	endbr64
    7164:	41 57                	push   %r15
    7166:	41 56                	push   %r14
    7168:	4c 8d 35 c1 f1 00 00 	lea    0xf1c1(%rip),%r14        # 16330 <gEfiGlobalVariableGuid>
    716f:	41 55                	push   %r13
    7171:	4c 8d 2d e4 df 00 00 	lea    0xdfe4(%rip),%r13        # 1515c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x35c>
    7178:	41 54                	push   %r12
    717a:	41 89 f4             	mov    %esi,%r12d
    717d:	4c 89 f6             	mov    %r14,%rsi
    7180:	53                   	push   %rbx
    7181:	89 fb                	mov    %edi,%ebx
    7183:	4c 89 ef             	mov    %r13,%rdi
    7186:	48 83 ec 40          	sub    $0x40,%rsp
    718a:	48 8d 54 24 30       	lea    0x30(%rsp),%rdx
    718f:	e8 ec fd ff ff       	call   6f80 <LibGetVariableAndSize>
    7194:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    7199:	49 89 c7             	mov    %rax,%r15
    719c:	45 84 e4             	test   %r12b,%r12b
    719f:	74 09                	je     71aa <LibInsertToTailOfBootOrder+0x4a>
    71a1:	48 85 d2             	test   %rdx,%rdx
    71a4:	0f 85 16 01 00 00    	jne    72c0 <LibInsertToTailOfBootOrder+0x160>
    71aa:	48 8b 05 1f 60 01 00 	mov    0x1601f(%rip),%rax        # 1d1d0 <BS>
    71b1:	48 83 c2 02          	add    $0x2,%rdx
    71b5:	8b 0d 91 f1 00 00    	mov    0xf191(%rip),%ecx        # 1634c <PoolAllocationType>
    71bb:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    71c0:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    71c5:	ff 50 40             	call   *0x40(%rax)
    71c8:	48 85 c0             	test   %rax,%rax
    71cb:	0f 88 9f 00 00 00    	js     7270 <LibInsertToTailOfBootOrder+0x110>
    71d1:	4c 8b 64 24 38       	mov    0x38(%rsp),%r12
    71d6:	4d 85 e4             	test   %r12,%r12
    71d9:	0f 84 91 00 00 00    	je     7270 <LibInsertToTailOfBootOrder+0x110>
    71df:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    71e4:	48 d1 e8             	shr    $1,%rax
    71e7:	48 83 f8 01          	cmp    $0x1,%rax
    71eb:	0f 84 8f 00 00 00    	je     7280 <LibInsertToTailOfBootOrder+0x120>
    71f1:	31 d2                	xor    %edx,%edx
    71f3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    71f8:	41 0f b7 04 57       	movzwl (%r15,%rdx,2),%eax
    71fd:	66 41 89 04 54       	mov    %ax,(%r12,%rdx,2)
    7202:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    7207:	48 83 c2 01          	add    $0x1,%rdx
    720b:	48 d1 e8             	shr    $1,%rax
    720e:	48 83 e8 01          	sub    $0x1,%rax
    7212:	48 39 d0             	cmp    %rdx,%rax
    7215:	77 e1                	ja     71f8 <LibInsertToTailOfBootOrder+0x98>
    7217:	66 41 89 1c 54       	mov    %bx,(%r12,%rdx,2)
    721c:	4c 89 e9             	mov    %r13,%rcx
    721f:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
    7224:	4c 89 f2             	mov    %r14,%rdx
    7227:	48 8b 05 f2 5f 01 00 	mov    0x15ff2(%rip),%rax        # 1d220 <RT>
    722e:	4c 89 64 24 20       	mov    %r12,0x20(%rsp)
    7233:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    7239:	ff 50 58             	call   *0x58(%rax)
    723c:	4c 89 e1             	mov    %r12,%rcx
    723f:	49 89 c5             	mov    %rax,%r13
    7242:	48 8b 05 87 5f 01 00 	mov    0x15f87(%rip),%rax        # 1d1d0 <BS>
    7249:	ff 50 48             	call   *0x48(%rax)
    724c:	48 8b 05 7d 5f 01 00 	mov    0x15f7d(%rip),%rax        # 1d1d0 <BS>
    7253:	4c 89 f9             	mov    %r15,%rcx
    7256:	ff 50 48             	call   *0x48(%rax)
    7259:	48 83 c4 40          	add    $0x40,%rsp
    725d:	4c 89 e8             	mov    %r13,%rax
    7260:	5b                   	pop    %rbx
    7261:	41 5c                	pop    %r12
    7263:	41 5d                	pop    %r13
    7265:	41 5e                	pop    %r14
    7267:	41 5f                	pop    %r15
    7269:	c3                   	ret
    726a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7270:	49 bd 09 00 00 00 00 	movabs $0x8000000000000009,%r13
    7277:	00 00 80 
    727a:	eb dd                	jmp    7259 <LibInsertToTailOfBootOrder+0xf9>
    727c:	0f 1f 40 00          	nopl   0x0(%rax)
    7280:	66 41 89 1c 24       	mov    %bx,(%r12)
    7285:	48 8b 05 94 5f 01 00 	mov    0x15f94(%rip),%rax        # 1d220 <RT>
    728c:	4c 89 e9             	mov    %r13,%rcx
    728f:	4c 89 f2             	mov    %r14,%rdx
    7292:	4c 89 64 24 20       	mov    %r12,0x20(%rsp)
    7297:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
    729c:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    72a2:	ff 50 58             	call   *0x58(%rax)
    72a5:	4c 89 e1             	mov    %r12,%rcx
    72a8:	49 89 c5             	mov    %rax,%r13
    72ab:	48 8b 05 1e 5f 01 00 	mov    0x15f1e(%rip),%rax        # 1d1d0 <BS>
    72b2:	ff 50 48             	call   *0x48(%rax)
    72b5:	4d 85 ff             	test   %r15,%r15
    72b8:	74 9f                	je     7259 <LibInsertToTailOfBootOrder+0xf9>
    72ba:	eb 90                	jmp    724c <LibInsertToTailOfBootOrder+0xec>
    72bc:	0f 1f 40 00          	nopl   0x0(%rax)
    72c0:	49 bd 03 00 00 00 00 	movabs $0x8000000000000003,%r13
    72c7:	00 00 80 
    72ca:	48 85 c0             	test   %rax,%rax
    72cd:	0f 85 79 ff ff ff    	jne    724c <LibInsertToTailOfBootOrder+0xec>
    72d3:	eb 84                	jmp    7259 <LibInsertToTailOfBootOrder+0xf9>
    72d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    72dc:	00 00 00 00 

00000000000072e0 <ValidMBR>:
    72e0:	f3 0f 1e fa          	endbr64
    72e4:	45 31 c0             	xor    %r8d,%r8d
    72e7:	66 81 bf fe 01 00 00 	cmpw   $0xaa55,0x1fe(%rdi)
    72ee:	55 aa 
    72f0:	74 0e                	je     7300 <ValidMBR+0x20>
    72f2:	44 89 c0             	mov    %r8d,%eax
    72f5:	c3                   	ret
    72f6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    72fd:	00 00 00 
    7300:	49 89 f2             	mov    %rsi,%r10
    7303:	41 bb 01 00 00 00    	mov    $0x1,%r11d
    7309:	80 bf c2 01 00 00 00 	cmpb   $0x0,0x1c2(%rdi)
    7310:	0f 84 62 01 00 00    	je     7478 <ValidMBR+0x198>
    7316:	53                   	push   %rbx
    7317:	0f b6 87 cb 01 00 00 	movzbl 0x1cb(%rdi),%eax
    731e:	0f b6 97 cc 01 00 00 	movzbl 0x1cc(%rdi),%edx
    7325:	c1 e0 08             	shl    $0x8,%eax
    7328:	c1 e2 10             	shl    $0x10,%edx
    732b:	09 d0                	or     %edx,%eax
    732d:	0f b6 97 ca 01 00 00 	movzbl 0x1ca(%rdi),%edx
    7334:	09 d0                	or     %edx,%eax
    7336:	0f b6 97 cd 01 00 00 	movzbl 0x1cd(%rdi),%edx
    733d:	c1 e2 18             	shl    $0x18,%edx
    7340:	09 d0                	or     %edx,%eax
    7342:	0f 84 1e 01 00 00    	je     7466 <ValidMBR+0x186>
    7348:	44 0f b6 87 c7 01 00 	movzbl 0x1c7(%rdi),%r8d
    734f:	00 
    7350:	0f b6 97 c8 01 00 00 	movzbl 0x1c8(%rdi),%edx
    7357:	41 c1 e0 08          	shl    $0x8,%r8d
    735b:	c1 e2 10             	shl    $0x10,%edx
    735e:	41 09 d0             	or     %edx,%r8d
    7361:	0f b6 97 c6 01 00 00 	movzbl 0x1c6(%rdi),%edx
    7368:	41 09 d0             	or     %edx,%r8d
    736b:	0f b6 97 c9 01 00 00 	movzbl 0x1c9(%rdi),%edx
    7372:	c1 e2 18             	shl    $0x18,%edx
    7375:	41 09 d0             	or     %edx,%r8d
    7378:	42 8d 54 00 ff       	lea    -0x1(%rax,%r8,1),%edx
    737d:	49 8b 42 08          	mov    0x8(%r10),%rax
    7381:	49 89 d1             	mov    %rdx,%r9
    7384:	48 8b 40 18          	mov    0x18(%rax),%rax
    7388:	48 39 c2             	cmp    %rax,%rdx
    738b:	76 1b                	jbe    73a8 <ValidMBR+0xc8>
    738d:	48 3d ff ff 07 00    	cmp    $0x7ffff,%rax
    7393:	0f 86 f7 00 00 00    	jbe    7490 <ValidMBR+0x1b0>
    7399:	48 05 00 00 04 00    	add    $0x40000,%rax
    739f:	48 39 c2             	cmp    %rax,%rdx
    73a2:	0f 87 e8 00 00 00    	ja     7490 <ValidMBR+0x1b0>
    73a8:	4c 89 de             	mov    %r11,%rsi
    73ab:	49 83 fb 04          	cmp    $0x4,%r11
    73af:	0f 84 e3 00 00 00    	je     7498 <ValidMBR+0x1b8>
    73b5:	48 89 f8             	mov    %rdi,%rax
    73b8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    73bf:	00 
    73c0:	80 b8 d2 01 00 00 00 	cmpb   $0x0,0x1d2(%rax)
    73c7:	74 70                	je     7439 <ValidMBR+0x159>
    73c9:	0f b6 90 db 01 00 00 	movzbl 0x1db(%rax),%edx
    73d0:	0f b6 88 dc 01 00 00 	movzbl 0x1dc(%rax),%ecx
    73d7:	c1 e2 08             	shl    $0x8,%edx
    73da:	c1 e1 10             	shl    $0x10,%ecx
    73dd:	09 ca                	or     %ecx,%edx
    73df:	0f b6 88 da 01 00 00 	movzbl 0x1da(%rax),%ecx
    73e6:	09 ca                	or     %ecx,%edx
    73e8:	0f b6 88 dd 01 00 00 	movzbl 0x1dd(%rax),%ecx
    73ef:	c1 e1 18             	shl    $0x18,%ecx
    73f2:	09 ca                	or     %ecx,%edx
    73f4:	74 43                	je     7439 <ValidMBR+0x159>
    73f6:	0f b6 88 d7 01 00 00 	movzbl 0x1d7(%rax),%ecx
    73fd:	0f b6 98 d8 01 00 00 	movzbl 0x1d8(%rax),%ebx
    7404:	c1 e1 08             	shl    $0x8,%ecx
    7407:	c1 e3 10             	shl    $0x10,%ebx
    740a:	09 d9                	or     %ebx,%ecx
    740c:	0f b6 98 d6 01 00 00 	movzbl 0x1d6(%rax),%ebx
    7413:	09 d9                	or     %ebx,%ecx
    7415:	0f b6 98 d9 01 00 00 	movzbl 0x1d9(%rax),%ebx
    741c:	c1 e3 18             	shl    $0x18,%ebx
    741f:	09 d9                	or     %ebx,%ecx
    7421:	41 39 c9             	cmp    %ecx,%r9d
    7424:	72 05                	jb     742b <ValidMBR+0x14b>
    7426:	41 39 c8             	cmp    %ecx,%r8d
    7429:	76 65                	jbe    7490 <ValidMBR+0x1b0>
    742b:	8d 54 0a ff          	lea    -0x1(%rdx,%rcx,1),%edx
    742f:	41 39 d0             	cmp    %edx,%r8d
    7432:	77 05                	ja     7439 <ValidMBR+0x159>
    7434:	41 39 d1             	cmp    %edx,%r9d
    7437:	73 57                	jae    7490 <ValidMBR+0x1b0>
    7439:	48 83 c6 01          	add    $0x1,%rsi
    743d:	48 83 c0 10          	add    $0x10,%rax
    7441:	48 83 fe 04          	cmp    $0x4,%rsi
    7445:	0f 85 75 ff ff ff    	jne    73c0 <ValidMBR+0xe0>
    744b:	41 b8 01 00 00 00    	mov    $0x1,%r8d
    7451:	48 83 c7 10          	add    $0x10,%rdi
    7455:	49 83 c3 01          	add    $0x1,%r11
    7459:	80 bf c2 01 00 00 00 	cmpb   $0x0,0x1c2(%rdi)
    7460:	0f 85 b1 fe ff ff    	jne    7317 <ValidMBR+0x37>
    7466:	49 83 fb 04          	cmp    $0x4,%r11
    746a:	75 e5                	jne    7451 <ValidMBR+0x171>
    746c:	44 89 c0             	mov    %r8d,%eax
    746f:	5b                   	pop    %rbx
    7470:	c3                   	ret
    7471:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    7478:	49 83 fb 04          	cmp    $0x4,%r11
    747c:	0f 84 70 fe ff ff    	je     72f2 <ValidMBR+0x12>
    7482:	48 83 c7 10          	add    $0x10,%rdi
    7486:	49 83 c3 01          	add    $0x1,%r11
    748a:	e9 7a fe ff ff       	jmp    7309 <ValidMBR+0x29>
    748f:	90                   	nop
    7490:	45 31 c0             	xor    %r8d,%r8d
    7493:	5b                   	pop    %rbx
    7494:	44 89 c0             	mov    %r8d,%eax
    7497:	c3                   	ret
    7498:	41 b8 01 00 00 00    	mov    $0x1,%r8d
    749e:	eb cc                	jmp    746c <ValidMBR+0x18c>

00000000000074a0 <DecimaltoBCD>:
    74a0:	f3 0f 1e fa          	endbr64
    74a4:	40 0f b6 ff          	movzbl %dil,%edi
    74a8:	e9 73 2c 00 00       	jmp    a120 <RtDecimaltoBCD>
    74ad:	0f 1f 00             	nopl   (%rax)

00000000000074b0 <BCDtoDecimal>:
    74b0:	f3 0f 1e fa          	endbr64
    74b4:	40 0f b6 ff          	movzbl %dil,%edi
    74b8:	e9 43 2c 00 00       	jmp    a100 <RtBCDtoDecimal>
    74bd:	0f 1f 00             	nopl   (%rax)

00000000000074c0 <LibGetSystemConfigurationTable>:
    74c0:	f3 0f 1e fa          	endbr64
    74c4:	48 8b 05 0d 5d 01 00 	mov    0x15d0d(%rip),%rax        # 1d1d8 <ST>
    74cb:	48 83 78 68 00       	cmpq   $0x0,0x68(%rax)
    74d0:	0f 84 7f 00 00 00    	je     7555 <LibGetSystemConfigurationTable+0x95>
    74d6:	41 55                	push   %r13
    74d8:	49 89 f5             	mov    %rsi,%r13
    74db:	41 54                	push   %r12
    74dd:	49 89 fc             	mov    %rdi,%r12
    74e0:	55                   	push   %rbp
    74e1:	53                   	push   %rbx
    74e2:	31 db                	xor    %ebx,%ebx
    74e4:	48 83 ec 08          	sub    $0x8,%rsp
    74e8:	eb 17                	jmp    7501 <LibGetSystemConfigurationTable+0x41>
    74ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    74f0:	48 8b 05 e1 5c 01 00 	mov    0x15ce1(%rip),%rax        # 1d1d8 <ST>
    74f7:	48 83 c3 01          	add    $0x1,%rbx
    74fb:	48 39 58 68          	cmp    %rbx,0x68(%rax)
    74ff:	76 3f                	jbe    7540 <LibGetSystemConfigurationTable+0x80>
    7501:	48 8b 70 70          	mov    0x70(%rax),%rsi
    7505:	48 8d 2c 5b          	lea    (%rbx,%rbx,2),%rbp
    7509:	4c 89 e7             	mov    %r12,%rdi
    750c:	48 c1 e5 03          	shl    $0x3,%rbp
    7510:	48 01 ee             	add    %rbp,%rsi
    7513:	e8 78 f3 ff ff       	call   6890 <CompareGuid>
    7518:	48 85 c0             	test   %rax,%rax
    751b:	75 d3                	jne    74f0 <LibGetSystemConfigurationTable+0x30>
    751d:	48 8b 05 b4 5c 01 00 	mov    0x15cb4(%rip),%rax        # 1d1d8 <ST>
    7524:	48 8b 40 70          	mov    0x70(%rax),%rax
    7528:	48 8b 44 28 10       	mov    0x10(%rax,%rbp,1),%rax
    752d:	49 89 45 00          	mov    %rax,0x0(%r13)
    7531:	48 83 c4 08          	add    $0x8,%rsp
    7535:	31 c0                	xor    %eax,%eax
    7537:	5b                   	pop    %rbx
    7538:	5d                   	pop    %rbp
    7539:	41 5c                	pop    %r12
    753b:	41 5d                	pop    %r13
    753d:	c3                   	ret
    753e:	66 90                	xchg   %ax,%ax
    7540:	48 b8 0e 00 00 00 00 	movabs $0x800000000000000e,%rax
    7547:	00 00 80 
    754a:	48 83 c4 08          	add    $0x8,%rsp
    754e:	5b                   	pop    %rbx
    754f:	5d                   	pop    %rbp
    7550:	41 5c                	pop    %r12
    7552:	41 5d                	pop    %r13
    7554:	c3                   	ret
    7555:	48 b8 0e 00 00 00 00 	movabs $0x800000000000000e,%rax
    755c:	00 00 80 
    755f:	c3                   	ret

0000000000007560 <LibGetUiString>:
    7560:	f3 0f 1e fa          	endbr64
    7564:	41 56                	push   %r14
    7566:	41 89 f6             	mov    %esi,%r14d
    7569:	41 55                	push   %r13
    756b:	41 89 cd             	mov    %ecx,%r13d
    756e:	48 89 f9             	mov    %rdi,%rcx
    7571:	41 54                	push   %r12
    7573:	49 89 fc             	mov    %rdi,%r12
    7576:	55                   	push   %rbp
    7577:	48 89 d5             	mov    %rdx,%rbp
    757a:	48 8d 15 5f ec 00 00 	lea    0xec5f(%rip),%rdx        # 161e0 <gEFiUiInterfaceProtocolGuid>
    7581:	53                   	push   %rbx
    7582:	48 83 ec 30          	sub    $0x30,%rsp
    7586:	48 8b 05 43 5c 01 00 	mov    0x15c43(%rip),%rax        # 1d1d0 <BS>
    758d:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    7592:	ff 90 98 00 00 00    	call   *0x98(%rax)
    7598:	48 85 c0             	test   %rax,%rax
    759b:	78 48                	js     75e5 <LibGetUiString+0x85>
    759d:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    75a2:	48 8b 58 08          	mov    0x8(%rax),%rbx
    75a6:	31 c0                	xor    %eax,%eax
    75a8:	45 85 f6             	test   %r14d,%r14d
    75ab:	75 07                	jne    75b4 <LibGetUiString+0x54>
    75ad:	eb 2e                	jmp    75dd <LibGetUiString+0x7d>
    75af:	90                   	nop
    75b0:	48 83 c3 10          	add    $0x10,%rbx
    75b4:	48 83 3b 00          	cmpq   $0x0,(%rbx)
    75b8:	75 f6                	jne    75b0 <LibGetUiString+0x50>
    75ba:	83 c0 01             	add    $0x1,%eax
    75bd:	48 83 c3 10          	add    $0x10,%rbx
    75c1:	41 39 c6             	cmp    %eax,%r14d
    75c4:	77 ee                	ja     75b4 <LibGetUiString+0x54>
    75c6:	48 8b 3b             	mov    (%rbx),%rdi
    75c9:	48 85 ff             	test   %rdi,%rdi
    75cc:	74 17                	je     75e5 <LibGetUiString+0x85>
    75ce:	66 90                	xchg   %ax,%ax
    75d0:	48 89 ee             	mov    %rbp,%rsi
    75d3:	e8 38 23 00 00       	call   9910 <strcmpa>
    75d8:	48 85 c0             	test   %rax,%rax
    75db:	74 39                	je     7616 <LibGetUiString+0xb6>
    75dd:	48 8b 3b             	mov    (%rbx),%rdi
    75e0:	48 85 ff             	test   %rdi,%rdi
    75e3:	75 eb                	jne    75d0 <LibGetUiString+0x70>
    75e5:	31 c0                	xor    %eax,%eax
    75e7:	45 84 ed             	test   %r13b,%r13b
    75ea:	75 0d                	jne    75f9 <LibGetUiString+0x99>
    75ec:	48 83 c4 30          	add    $0x30,%rsp
    75f0:	5b                   	pop    %rbx
    75f1:	5d                   	pop    %rbp
    75f2:	41 5c                	pop    %r12
    75f4:	41 5d                	pop    %r13
    75f6:	41 5e                	pop    %r14
    75f8:	c3                   	ret
    75f9:	4c 89 e7             	mov    %r12,%rdi
    75fc:	e8 0f 3b 00 00       	call   b110 <DevicePathFromHandle>
    7601:	48 89 c7             	mov    %rax,%rdi
    7604:	e8 c7 41 00 00       	call   b7d0 <DevicePathToStr>
    7609:	48 83 c4 30          	add    $0x30,%rsp
    760d:	5b                   	pop    %rbx
    760e:	5d                   	pop    %rbp
    760f:	41 5c                	pop    %r12
    7611:	41 5d                	pop    %r13
    7613:	41 5e                	pop    %r14
    7615:	c3                   	ret
    7616:	48 8b 43 08          	mov    0x8(%rbx),%rax
    761a:	48 83 c4 30          	add    $0x30,%rsp
    761e:	5b                   	pop    %rbx
    761f:	5d                   	pop    %rbp
    7620:	41 5c                	pop    %r12
    7622:	41 5d                	pop    %r13
    7624:	41 5e                	pop    %r14
    7626:	c3                   	ret
    7627:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    762e:	00 00 

0000000000007630 <_DbgOut>:
    7630:	f3 0f 1e fa          	endbr64
    7634:	48 85 c9             	test   %rcx,%rcx
    7637:	74 17                	je     7650 <_DbgOut+0x20>
    7639:	48 83 ec 28          	sub    $0x28,%rsp
    763d:	ff 51 08             	call   *0x8(%rcx)
    7640:	31 c0                	xor    %eax,%eax
    7642:	48 83 c4 28          	add    $0x28,%rsp
    7646:	c3                   	ret
    7647:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    764e:	00 00 
    7650:	31 c0                	xor    %eax,%eax
    7652:	c3                   	ret
    7653:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    765a:	00 00 00 00 
    765e:	66 90                	xchg   %ax,%ax

0000000000007660 <_SPrint>:
    7660:	f3 0f 1e fa          	endbr64
    7664:	41 54                	push   %r12
    7666:	49 89 d4             	mov    %rdx,%r12
    7669:	55                   	push   %rbp
    766a:	48 89 cd             	mov    %rcx,%rbp
    766d:	57                   	push   %rdi
    766e:	48 89 d7             	mov    %rdx,%rdi
    7671:	56                   	push   %rsi
    7672:	53                   	push   %rbx
    7673:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
    767a:	0f 29 34 24          	movaps %xmm6,(%rsp)
    767e:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
    7683:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
    7689:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
    768f:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
    7695:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
    769b:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
    76a1:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
    76a7:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
    76ae:	00 00 
    76b0:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
    76b7:	00 00 
    76b9:	e8 c2 21 00 00       	call   9880 <StrLen>
    76be:	48 8b 55 10          	mov    0x10(%rbp),%rdx
    76c2:	4c 89 e6             	mov    %r12,%rsi
    76c5:	48 89 c3             	mov    %rax,%rbx
    76c8:	48 8b 45 08          	mov    0x8(%rbp),%rax
    76cc:	48 89 d1             	mov    %rdx,%rcx
    76cf:	4c 8d 04 18          	lea    (%rax,%rbx,1),%r8
    76d3:	48 29 c1             	sub    %rax,%rcx
    76d6:	49 39 d0             	cmp    %rdx,%r8
    76d9:	48 0f 47 d9          	cmova  %rcx,%rbx
    76dd:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    76e1:	48 8d 14 1b          	lea    (%rbx,%rbx,1),%rdx
    76e5:	48 8d 3c 41          	lea    (%rcx,%rax,2),%rdi
    76e9:	e8 92 f6 ff ff       	call   6d80 <CopyMem>
    76ee:	48 8b 45 10          	mov    0x10(%rbp),%rax
    76f2:	48 03 5d 08          	add    0x8(%rbp),%rbx
    76f6:	48 89 5d 08          	mov    %rbx,0x8(%rbp)
    76fa:	48 39 c3             	cmp    %rax,%rbx
    76fd:	73 61                	jae    7760 <_SPrint+0x100>
    76ff:	48 8b 45 00          	mov    0x0(%rbp),%rax
    7703:	45 31 c0             	xor    %r8d,%r8d
    7706:	66 44 89 04 58       	mov    %r8w,(%rax,%rbx,2)
    770b:	0f 28 34 24          	movaps (%rsp),%xmm6
    770f:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
    7714:	31 c0                	xor    %eax,%eax
    7716:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
    771c:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
    7722:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
    7728:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
    772e:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
    7734:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
    773a:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
    7741:	00 00 
    7743:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
    774a:	00 00 
    774c:	48 81 c4 a0 00 00 00 	add    $0xa0,%rsp
    7753:	5b                   	pop    %rbx
    7754:	5e                   	pop    %rsi
    7755:	5f                   	pop    %rdi
    7756:	5d                   	pop    %rbp
    7757:	41 5c                	pop    %r12
    7759:	c3                   	ret
    775a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7760:	48 85 c0             	test   %rax,%rax
    7763:	74 a6                	je     770b <_SPrint+0xab>
    7765:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    7769:	31 c9                	xor    %ecx,%ecx
    776b:	66 89 0c 42          	mov    %cx,(%rdx,%rax,2)
    776f:	eb 9a                	jmp    770b <_SPrint+0xab>
    7771:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    7778:	00 00 00 00 
    777c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000007780 <_PoolPrint>:
    7780:	f3 0f 1e fa          	endbr64
    7784:	41 55                	push   %r13
    7786:	49 89 d5             	mov    %rdx,%r13
    7789:	41 54                	push   %r12
    778b:	49 89 cc             	mov    %rcx,%r12
    778e:	57                   	push   %rdi
    778f:	48 89 d7             	mov    %rdx,%rdi
    7792:	56                   	push   %rsi
    7793:	53                   	push   %rbx
    7794:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
    779b:	0f 29 34 24          	movaps %xmm6,(%rsp)
    779f:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
    77a4:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
    77aa:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
    77b0:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
    77b6:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
    77bc:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
    77c2:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
    77c8:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
    77cf:	00 00 
    77d1:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
    77d8:	00 00 
    77da:	48 8b 59 08          	mov    0x8(%rcx),%rbx
    77de:	e8 9d 20 00 00       	call   9880 <StrLen>
    77e3:	48 01 d8             	add    %rbx,%rax
    77e6:	48 8d 50 01          	lea    0x1(%rax),%rdx
    77ea:	49 39 54 24 10       	cmp    %rdx,0x10(%r12)
    77ef:	72 5f                	jb     7850 <_PoolPrint+0xd0>
    77f1:	0f 28 34 24          	movaps (%rsp),%xmm6
    77f5:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
    77fa:	4c 89 ea             	mov    %r13,%rdx
    77fd:	4c 89 e1             	mov    %r12,%rcx
    7800:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
    7806:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
    780c:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
    7812:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
    7818:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
    781e:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
    7824:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
    782b:	00 00 
    782d:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
    7834:	00 00 
    7836:	48 81 c4 a0 00 00 00 	add    $0xa0,%rsp
    783d:	5b                   	pop    %rbx
    783e:	5e                   	pop    %rsi
    783f:	5f                   	pop    %rdi
    7840:	41 5c                	pop    %r12
    7842:	41 5d                	pop    %r13
    7844:	e9 17 fe ff ff       	jmp    7660 <_SPrint>
    7849:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    7850:	48 05 c9 00 00 00    	add    $0xc9,%rax
    7856:	49 8b 3c 24          	mov    (%r12),%rdi
    785a:	49 89 44 24 10       	mov    %rax,0x10(%r12)
    785f:	48 8d 14 00          	lea    (%rax,%rax,1),%rdx
    7863:	49 8b 44 24 08       	mov    0x8(%r12),%rax
    7868:	48 8d 34 00          	lea    (%rax,%rax,1),%rsi
    786c:	e8 3f f4 ff ff       	call   6cb0 <ReallocatePool>
    7871:	49 89 04 24          	mov    %rax,(%r12)
    7875:	48 85 c0             	test   %rax,%rax
    7878:	0f 85 73 ff ff ff    	jne    77f1 <_PoolPrint+0x71>
    787e:	49 c7 44 24 08 00 00 	movq   $0x0,0x8(%r12)
    7885:	00 00 
    7887:	49 c7 44 24 10 00 00 	movq   $0x0,0x10(%r12)
    788e:	00 00 
    7890:	e9 5c ff ff ff       	jmp    77f1 <_PoolPrint+0x71>
    7895:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    789c:	00 00 00 00 

00000000000078a0 <ValueToHex.part.0>:
    78a0:	41 56                	push   %r14
    78a2:	41 55                	push   %r13
    78a4:	41 54                	push   %r12
    78a6:	55                   	push   %rbp
    78a7:	48 89 fd             	mov    %rdi,%rbp
    78aa:	53                   	push   %rbx
    78ab:	48 83 ec 20          	sub    $0x20,%rsp
    78af:	48 85 f6             	test   %rsi,%rsi
    78b2:	74 69                	je     791d <ValueToHex.part.0+0x7d>
    78b4:	49 89 e4             	mov    %rsp,%r12
    78b7:	48 89 f7             	mov    %rsi,%rdi
    78ba:	4c 8d 2d 0f ee 00 00 	lea    0xee0f(%rip),%r13        # 166d0 <Hex>
    78c1:	4d 89 e6             	mov    %r12,%r14
    78c4:	0f 1f 40 00          	nopl   0x0(%rax)
    78c8:	48 89 f8             	mov    %rdi,%rax
    78cb:	49 83 c6 01          	add    $0x1,%r14
    78cf:	be 04 00 00 00       	mov    $0x4,%esi
    78d4:	83 e0 0f             	and    $0xf,%eax
    78d7:	41 0f b6 5c 05 00    	movzbl 0x0(%r13,%rax,1),%ebx
    78dd:	41 88 5e ff          	mov    %bl,-0x1(%r14)
    78e1:	e8 8a 28 00 00       	call   a170 <RShiftU64>
    78e6:	48 89 c7             	mov    %rax,%rdi
    78e9:	48 85 c0             	test   %rax,%rax
    78ec:	75 da                	jne    78c8 <ValueToHex.part.0+0x28>
    78ee:	4d 39 e6             	cmp    %r12,%r14
    78f1:	74 2a                	je     791d <ValueToHex.part.0+0x7d>
    78f3:	48 89 ea             	mov    %rbp,%rdx
    78f6:	4c 89 f0             	mov    %r14,%rax
    78f9:	eb 09                	jmp    7904 <ValueToHex.part.0+0x64>
    78fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    7900:	0f b6 58 ff          	movzbl -0x1(%rax),%ebx
    7904:	48 83 e8 01          	sub    $0x1,%rax
    7908:	48 83 c2 02          	add    $0x2,%rdx
    790c:	66 89 5a fe          	mov    %bx,-0x2(%rdx)
    7910:	4c 39 e0             	cmp    %r12,%rax
    7913:	75 eb                	jne    7900 <ValueToHex.part.0+0x60>
    7915:	49 29 c6             	sub    %rax,%r14
    7918:	4a 8d 6c 75 00       	lea    0x0(%rbp,%r14,2),%rbp
    791d:	31 c0                	xor    %eax,%eax
    791f:	66 89 45 00          	mov    %ax,0x0(%rbp)
    7923:	48 83 c4 20          	add    $0x20,%rsp
    7927:	5b                   	pop    %rbx
    7928:	5d                   	pop    %rbp
    7929:	41 5c                	pop    %r12
    792b:	41 5d                	pop    %r13
    792d:	41 5e                	pop    %r14
    792f:	c3                   	ret

0000000000007930 <IsLocalPrint>:
    7930:	f3 0f 1e fa          	endbr64
    7934:	48 8d 05 f5 fc ff ff 	lea    -0x30b(%rip),%rax        # 7630 <_DbgOut>
    793b:	48 8d 15 1e fd ff ff 	lea    -0x2e2(%rip),%rdx        # 7660 <_SPrint>
    7942:	48 39 c7             	cmp    %rax,%rdi
    7945:	0f 94 c0             	sete   %al
    7948:	48 39 d7             	cmp    %rdx,%rdi
    794b:	0f 94 c2             	sete   %dl
    794e:	09 d0                	or     %edx,%eax
    7950:	48 8d 15 29 fe ff ff 	lea    -0x1d7(%rip),%rdx        # 7780 <_PoolPrint>
    7957:	48 39 d7             	cmp    %rdx,%rdi
    795a:	0f 94 c2             	sete   %dl
    795d:	09 d0                	or     %edx,%eax
    795f:	0f b6 c0             	movzbl %al,%eax
    7962:	c3                   	ret
    7963:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    796a:	00 00 00 00 
    796e:	66 90                	xchg   %ax,%ax

0000000000007970 <PFLUSH>:
    7970:	f3 0f 1e fa          	endbr64
    7974:	53                   	push   %rbx
    7975:	31 d2                	xor    %edx,%edx
    7977:	48 89 fb             	mov    %rdi,%rbx
    797a:	48 83 ec 20          	sub    $0x20,%rsp
    797e:	48 8b 47 40          	mov    0x40(%rdi),%rax
    7982:	66 89 10             	mov    %dx,(%rax)
    7985:	48 8b 57 30          	mov    0x30(%rdi),%rdx
    7989:	48 8b 8f 88 00 00 00 	mov    0x88(%rdi),%rcx
    7990:	ff 57 78             	call   *0x78(%rdi)
    7993:	48 8b 43 30          	mov    0x30(%rbx),%rax
    7997:	48 89 43 40          	mov    %rax,0x40(%rbx)
    799b:	48 83 c4 20          	add    $0x20,%rsp
    799f:	5b                   	pop    %rbx
    79a0:	c3                   	ret
    79a1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    79a8:	00 00 00 00 
    79ac:	0f 1f 40 00          	nopl   0x0(%rax)

00000000000079b0 <PSETATTR>:
    79b0:	f3 0f 1e fa          	endbr64
    79b4:	55                   	push   %rbp
    79b5:	48 89 f5             	mov    %rsi,%rbp
    79b8:	53                   	push   %rbx
    79b9:	48 89 fb             	mov    %rdi,%rbx
    79bc:	48 83 ec 28          	sub    $0x28,%rsp
    79c0:	e8 ab ff ff ff       	call   7970 <PFLUSH>
    79c5:	48 8b 43 50          	mov    0x50(%rbx),%rax
    79c9:	48 89 43 58          	mov    %rax,0x58(%rbx)
    79cd:	48 8b 83 80 00 00 00 	mov    0x80(%rbx),%rax
    79d4:	48 85 c0             	test   %rax,%rax
    79d7:	74 0c                	je     79e5 <PSETATTR+0x35>
    79d9:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
    79e0:	48 89 ea             	mov    %rbp,%rdx
    79e3:	ff d0                	call   *%rax
    79e5:	48 89 6b 50          	mov    %rbp,0x50(%rbx)
    79e9:	48 83 c4 28          	add    $0x28,%rsp
    79ed:	5b                   	pop    %rbx
    79ee:	5d                   	pop    %rbp
    79ef:	c3                   	ret

00000000000079f0 <PPUTC>:
    79f0:	f3 0f 1e fa          	endbr64
    79f4:	48 83 ec 18          	sub    $0x18,%rsp
    79f8:	48 8b 47 40          	mov    0x40(%rdi),%rax
    79fc:	66 83 fe 0a          	cmp    $0xa,%si
    7a00:	74 36                	je     7a38 <PPUTC+0x48>
    7a02:	66 89 30             	mov    %si,(%rax)
    7a05:	48 8b 47 40          	mov    0x40(%rdi),%rax
    7a09:	48 83 47 48 01       	addq   $0x1,0x48(%rdi)
    7a0e:	48 83 c0 02          	add    $0x2,%rax
    7a12:	48 89 47 40          	mov    %rax,0x40(%rdi)
    7a16:	48 3b 47 38          	cmp    0x38(%rdi),%rax
    7a1a:	73 0c                	jae    7a28 <PPUTC+0x38>
    7a1c:	48 83 c4 18          	add    $0x18,%rsp
    7a20:	c3                   	ret
    7a21:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    7a28:	48 83 c4 18          	add    $0x18,%rsp
    7a2c:	e9 3f ff ff ff       	jmp    7970 <PFLUSH>
    7a31:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    7a38:	ba 0d 00 00 00       	mov    $0xd,%edx
    7a3d:	66 89 10             	mov    %dx,(%rax)
    7a40:	48 8b 47 40          	mov    0x40(%rdi),%rax
    7a44:	48 83 47 48 01       	addq   $0x1,0x48(%rdi)
    7a49:	48 83 c0 02          	add    $0x2,%rax
    7a4d:	48 89 47 40          	mov    %rax,0x40(%rdi)
    7a51:	48 3b 47 38          	cmp    0x38(%rdi),%rax
    7a55:	72 ab                	jb     7a02 <PPUTC+0x12>
    7a57:	89 74 24 0c          	mov    %esi,0xc(%rsp)
    7a5b:	48 89 3c 24          	mov    %rdi,(%rsp)
    7a5f:	e8 0c ff ff ff       	call   7970 <PFLUSH>
    7a64:	48 8b 3c 24          	mov    (%rsp),%rdi
    7a68:	8b 74 24 0c          	mov    0xc(%rsp),%esi
    7a6c:	48 8b 47 40          	mov    0x40(%rdi),%rax
    7a70:	eb 90                	jmp    7a02 <PPUTC+0x12>
    7a72:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    7a79:	00 00 00 00 
    7a7d:	0f 1f 00             	nopl   (%rax)

0000000000007a80 <PGETC>:
    7a80:	f3 0f 1e fa          	endbr64
    7a84:	80 3f 00             	cmpb   $0x0,(%rdi)
    7a87:	48 8b 57 10          	mov    0x10(%rdi),%rdx
    7a8b:	48 8b 47 08          	mov    0x8(%rdi),%rax
    7a8f:	74 17                	je     7aa8 <PGETC+0x28>
    7a91:	44 0f b6 04 02       	movzbl (%rdx,%rax,1),%r8d
    7a96:	48 83 c0 01          	add    $0x1,%rax
    7a9a:	48 89 47 08          	mov    %rax,0x8(%rdi)
    7a9e:	44 89 c0             	mov    %r8d,%eax
    7aa1:	c3                   	ret
    7aa2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7aa8:	44 0f b7 04 42       	movzwl (%rdx,%rax,2),%r8d
    7aad:	48 83 c0 01          	add    $0x1,%rax
    7ab1:	48 89 47 08          	mov    %rax,0x8(%rdi)
    7ab5:	44 89 c0             	mov    %r8d,%eax
    7ab8:	c3                   	ret
    7ab9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000007ac0 <PITEM>:
    7ac0:	f3 0f 1e fa          	endbr64
    7ac4:	41 56                	push   %r14
    7ac6:	41 55                	push   %r13
    7ac8:	41 54                	push   %r12
    7aca:	45 31 e4             	xor    %r12d,%r12d
    7acd:	55                   	push   %rbp
    7ace:	53                   	push   %rbx
    7acf:	48 8b af 90 00 00 00 	mov    0x90(%rdi),%rbp
    7ad6:	48 89 fb             	mov    %rdi,%rbx
    7ad9:	48 c7 45 08 00 00 00 	movq   $0x0,0x8(%rbp)
    7ae0:	00 
    7ae1:	48 8b 8d e8 00 00 00 	mov    0xe8(%rbp),%rcx
    7ae8:	eb 1c                	jmp    7b06 <PITEM+0x46>
    7aea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7af0:	42 0f b6 14 20       	movzbl (%rax,%r12,1),%edx
    7af5:	49 8d 44 24 01       	lea    0x1(%r12),%rax
    7afa:	48 89 45 08          	mov    %rax,0x8(%rbp)
    7afe:	66 85 d2             	test   %dx,%dx
    7b01:	74 25                	je     7b28 <PITEM+0x68>
    7b03:	49 89 c4             	mov    %rax,%r12
    7b06:	4c 39 e1             	cmp    %r12,%rcx
    7b09:	74 21                	je     7b2c <PITEM+0x6c>
    7b0b:	80 7d 00 00          	cmpb   $0x0,0x0(%rbp)
    7b0f:	48 8b 45 10          	mov    0x10(%rbp),%rax
    7b13:	75 db                	jne    7af0 <PITEM+0x30>
    7b15:	42 0f b7 14 60       	movzwl (%rax,%r12,2),%edx
    7b1a:	49 8d 44 24 01       	lea    0x1(%r12),%rax
    7b1f:	48 89 45 08          	mov    %rax,0x8(%rbp)
    7b23:	66 85 d2             	test   %dx,%dx
    7b26:	75 db                	jne    7b03 <PITEM+0x43>
    7b28:	4c 89 65 08          	mov    %r12,0x8(%rbp)
    7b2c:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
    7b30:	75 07                	jne    7b39 <PITEM+0x79>
    7b32:	4c 89 a5 e8 00 00 00 	mov    %r12,0xe8(%rbp)
    7b39:	4c 8b ad e0 00 00 00 	mov    0xe0(%rbp),%r13
    7b40:	0f b6 85 fa 00 00 00 	movzbl 0xfa(%rbp),%eax
    7b47:	4d 39 e5             	cmp    %r12,%r13
    7b4a:	0f 83 d8 01 00 00    	jae    7d28 <PITEM+0x268>
    7b50:	4c 89 a5 e0 00 00 00 	mov    %r12,0xe0(%rbp)
    7b57:	84 c0                	test   %al,%al
    7b59:	0f 84 c5 00 00 00    	je     7c24 <PITEM+0x164>
    7b5f:	4c 3b a5 e8 00 00 00 	cmp    0xe8(%rbp),%r12
    7b66:	0f 83 b8 00 00 00    	jae    7c24 <PITEM+0x164>
    7b6c:	4d 89 e5             	mov    %r12,%r13
    7b6f:	eb 14                	jmp    7b85 <PITEM+0xc5>
    7b71:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    7b78:	49 83 c5 01          	add    $0x1,%r13
    7b7c:	4c 39 ad e8 00 00 00 	cmp    %r13,0xe8(%rbp)
    7b83:	76 38                	jbe    7bbd <PITEM+0xfd>
    7b85:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7b89:	bf 20 00 00 00       	mov    $0x20,%edi
    7b8e:	66 89 38             	mov    %di,(%rax)
    7b91:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7b95:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7b9a:	48 83 c0 02          	add    $0x2,%rax
    7b9e:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7ba2:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7ba6:	72 d0                	jb     7b78 <PITEM+0xb8>
    7ba8:	48 89 df             	mov    %rbx,%rdi
    7bab:	49 83 c5 01          	add    $0x1,%r13
    7baf:	e8 bc fd ff ff       	call   7970 <PFLUSH>
    7bb4:	4c 39 ad e8 00 00 00 	cmp    %r13,0xe8(%rbp)
    7bbb:	77 c8                	ja     7b85 <PITEM+0xc5>
    7bbd:	4c 8b ad e0 00 00 00 	mov    0xe0(%rbp),%r13
    7bc4:	4d 39 ec             	cmp    %r13,%r12
    7bc7:	73 5b                	jae    7c24 <PITEM+0x164>
    7bc9:	4d 89 e5             	mov    %r12,%r13
    7bcc:	eb 0f                	jmp    7bdd <PITEM+0x11d>
    7bce:	66 90                	xchg   %ax,%ax
    7bd0:	49 83 c5 01          	add    $0x1,%r13
    7bd4:	4c 39 ad e0 00 00 00 	cmp    %r13,0xe0(%rbp)
    7bdb:	76 47                	jbe    7c24 <PITEM+0x164>
    7bdd:	44 0f b7 b5 f8 00 00 	movzwl 0xf8(%rbp),%r14d
    7be4:	00 
    7be5:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7be9:	66 41 83 fe 0a       	cmp    $0xa,%r14w
    7bee:	0f 84 54 01 00 00    	je     7d48 <PITEM+0x288>
    7bf4:	66 44 89 30          	mov    %r14w,(%rax)
    7bf8:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7bfc:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7c01:	48 83 c0 02          	add    $0x2,%rax
    7c05:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7c09:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7c0d:	72 c1                	jb     7bd0 <PITEM+0x110>
    7c0f:	48 89 df             	mov    %rbx,%rdi
    7c12:	49 83 c5 01          	add    $0x1,%r13
    7c16:	e8 55 fd ff ff       	call   7970 <PFLUSH>
    7c1b:	4c 39 ad e0 00 00 00 	cmp    %r13,0xe0(%rbp)
    7c22:	77 b9                	ja     7bdd <PITEM+0x11d>
    7c24:	48 c7 45 08 00 00 00 	movq   $0x0,0x8(%rbp)
    7c2b:	00 
    7c2c:	31 c0                	xor    %eax,%eax
    7c2e:	eb 37                	jmp    7c67 <PITEM+0x1a7>
    7c30:	44 0f b6 2c 02       	movzbl (%rdx,%rax,1),%r13d
    7c35:	48 83 c0 01          	add    $0x1,%rax
    7c39:	48 89 45 08          	mov    %rax,0x8(%rbp)
    7c3d:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7c41:	66 41 83 fd 0a       	cmp    $0xa,%r13w
    7c46:	74 48                	je     7c90 <PITEM+0x1d0>
    7c48:	66 44 89 28          	mov    %r13w,(%rax)
    7c4c:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7c50:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7c55:	48 83 c0 02          	add    $0x2,%rax
    7c59:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7c5d:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7c61:	73 1d                	jae    7c80 <PITEM+0x1c0>
    7c63:	48 8b 45 08          	mov    0x8(%rbp),%rax
    7c67:	4c 39 e0             	cmp    %r12,%rax
    7c6a:	73 54                	jae    7cc0 <PITEM+0x200>
    7c6c:	80 7d 00 00          	cmpb   $0x0,0x0(%rbp)
    7c70:	48 8b 55 10          	mov    0x10(%rbp),%rdx
    7c74:	75 ba                	jne    7c30 <PITEM+0x170>
    7c76:	44 0f b7 2c 42       	movzwl (%rdx,%rax,2),%r13d
    7c7b:	eb b8                	jmp    7c35 <PITEM+0x175>
    7c7d:	0f 1f 00             	nopl   (%rax)
    7c80:	48 89 df             	mov    %rbx,%rdi
    7c83:	e8 e8 fc ff ff       	call   7970 <PFLUSH>
    7c88:	eb d9                	jmp    7c63 <PITEM+0x1a3>
    7c8a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7c90:	b9 0d 00 00 00       	mov    $0xd,%ecx
    7c95:	66 89 08             	mov    %cx,(%rax)
    7c98:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7c9c:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7ca1:	48 83 c0 02          	add    $0x2,%rax
    7ca5:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7ca9:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7cad:	72 99                	jb     7c48 <PITEM+0x188>
    7caf:	48 89 df             	mov    %rbx,%rdi
    7cb2:	e8 b9 fc ff ff       	call   7970 <PFLUSH>
    7cb7:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7cbb:	eb 8b                	jmp    7c48 <PITEM+0x188>
    7cbd:	0f 1f 00             	nopl   (%rax)
    7cc0:	80 bd fa 00 00 00 00 	cmpb   $0x0,0xfa(%rbp)
    7cc7:	75 10                	jne    7cd9 <PITEM+0x219>
    7cc9:	4c 8b a5 e0 00 00 00 	mov    0xe0(%rbp),%r12
    7cd0:	4c 3b a5 e8 00 00 00 	cmp    0xe8(%rbp),%r12
    7cd7:	72 24                	jb     7cfd <PITEM+0x23d>
    7cd9:	5b                   	pop    %rbx
    7cda:	5d                   	pop    %rbp
    7cdb:	41 5c                	pop    %r12
    7cdd:	41 5d                	pop    %r13
    7cdf:	41 5e                	pop    %r14
    7ce1:	c3                   	ret
    7ce2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7ce8:	48 89 df             	mov    %rbx,%rdi
    7ceb:	e8 80 fc ff ff       	call   7970 <PFLUSH>
    7cf0:	49 83 c4 01          	add    $0x1,%r12
    7cf4:	4c 39 a5 e8 00 00 00 	cmp    %r12,0xe8(%rbp)
    7cfb:	76 dc                	jbe    7cd9 <PITEM+0x219>
    7cfd:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7d01:	ba 20 00 00 00       	mov    $0x20,%edx
    7d06:	66 89 10             	mov    %dx,(%rax)
    7d09:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7d0d:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7d12:	48 83 c0 02          	add    $0x2,%rax
    7d16:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7d1a:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7d1e:	72 d0                	jb     7cf0 <PITEM+0x230>
    7d20:	eb c6                	jmp    7ce8 <PITEM+0x228>
    7d22:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7d28:	84 c0                	test   %al,%al
    7d2a:	0f 84 94 fe ff ff    	je     7bc4 <PITEM+0x104>
    7d30:	4c 39 ad e8 00 00 00 	cmp    %r13,0xe8(%rbp)
    7d37:	0f 86 87 fe ff ff    	jbe    7bc4 <PITEM+0x104>
    7d3d:	e9 43 fe ff ff       	jmp    7b85 <PITEM+0xc5>
    7d42:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    7d48:	be 0d 00 00 00       	mov    $0xd,%esi
    7d4d:	66 89 30             	mov    %si,(%rax)
    7d50:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7d54:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    7d59:	48 83 c0 02          	add    $0x2,%rax
    7d5d:	48 89 43 40          	mov    %rax,0x40(%rbx)
    7d61:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    7d65:	0f 82 89 fe ff ff    	jb     7bf4 <PITEM+0x134>
    7d6b:	48 89 df             	mov    %rbx,%rdi
    7d6e:	e8 fd fb ff ff       	call   7970 <PFLUSH>
    7d73:	48 8b 43 40          	mov    0x40(%rbx),%rax
    7d77:	e9 78 fe ff ff       	jmp    7bf4 <PITEM+0x134>
    7d7c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000007d80 <ValueToHex>:
    7d80:	f3 0f 1e fa          	endbr64
    7d84:	48 85 f6             	test   %rsi,%rsi
    7d87:	74 07                	je     7d90 <ValueToHex+0x10>
    7d89:	e9 12 fb ff ff       	jmp    78a0 <ValueToHex.part.0>
    7d8e:	66 90                	xchg   %ax,%ax
    7d90:	c7 07 30 00 00 00    	movl   $0x30,(%rdi)
    7d96:	c3                   	ret
    7d97:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    7d9e:	00 00 

0000000000007da0 <ValueToString>:
    7da0:	f3 0f 1e fa          	endbr64
    7da4:	41 56                	push   %r14
    7da6:	49 89 fe             	mov    %rdi,%r14
    7da9:	bf 03 01 00 00       	mov    $0x103,%edi
    7dae:	41 55                	push   %r13
    7db0:	41 54                	push   %r12
    7db2:	55                   	push   %rbp
    7db3:	53                   	push   %rbx
    7db4:	48 83 ec 40          	sub    $0x40,%rsp
    7db8:	66 89 7c 24 05       	mov    %di,0x5(%rsp)
    7dbd:	c6 44 24 07 02       	movb   $0x2,0x7(%rsp)
    7dc2:	48 85 d2             	test   %rdx,%rdx
    7dc5:	0f 84 f5 00 00 00    	je     7ec0 <ValueToString+0x120>
    7dcb:	41 89 f5             	mov    %esi,%r13d
    7dce:	48 89 d7             	mov    %rdx,%rdi
    7dd1:	0f 88 d1 00 00 00    	js     7ea8 <ValueToString+0x108>
    7dd7:	48 8d 6c 24 10       	lea    0x10(%rsp),%rbp
    7ddc:	4c 8d 64 24 08       	lea    0x8(%rsp),%r12
    7de1:	48 89 eb             	mov    %rbp,%rbx
    7de4:	0f 1f 40 00          	nopl   0x0(%rax)
    7de8:	4c 89 e2             	mov    %r12,%rdx
    7deb:	be 0a 00 00 00       	mov    $0xa,%esi
    7df0:	48 83 c3 01          	add    $0x1,%rbx
    7df4:	e8 97 23 00 00       	call   a190 <DivU64x32>
    7df9:	48 89 c7             	mov    %rax,%rdi
    7dfc:	0f b6 44 24 08       	movzbl 0x8(%rsp),%eax
    7e01:	8d 48 30             	lea    0x30(%rax),%ecx
    7e04:	88 4b ff             	mov    %cl,-0x1(%rbx)
    7e07:	48 85 ff             	test   %rdi,%rdi
    7e0a:	75 dc                	jne    7de8 <ValueToString+0x48>
    7e0c:	b8 e8 03 00 00       	mov    $0x3e8,%eax
    7e11:	45 84 ed             	test   %r13b,%r13b
    7e14:	75 5a                	jne    7e70 <ValueToString+0xd0>
    7e16:	48 39 eb             	cmp    %rbp,%rbx
    7e19:	75 0c                	jne    7e27 <ValueToString+0x87>
    7e1b:	e9 b8 00 00 00       	jmp    7ed8 <ValueToString+0x138>
    7e20:	0f b6 4b ff          	movzbl -0x1(%rbx),%ecx
    7e24:	49 89 d6             	mov    %rdx,%r14
    7e27:	48 83 e8 01          	sub    $0x1,%rax
    7e2b:	75 13                	jne    7e40 <ValueToString+0xa0>
    7e2d:	ba 2c 00 00 00       	mov    $0x2c,%edx
    7e32:	49 83 c6 02          	add    $0x2,%r14
    7e36:	b8 03 00 00 00       	mov    $0x3,%eax
    7e3b:	66 41 89 56 fe       	mov    %dx,-0x2(%r14)
    7e40:	0f b6 c9             	movzbl %cl,%ecx
    7e43:	48 83 eb 01          	sub    $0x1,%rbx
    7e47:	49 8d 56 02          	lea    0x2(%r14),%rdx
    7e4b:	66 41 89 0e          	mov    %cx,(%r14)
    7e4f:	48 39 eb             	cmp    %rbp,%rbx
    7e52:	75 cc                	jne    7e20 <ValueToString+0x80>
    7e54:	31 c0                	xor    %eax,%eax
    7e56:	66 89 02             	mov    %ax,(%rdx)
    7e59:	48 83 c4 40          	add    $0x40,%rsp
    7e5d:	5b                   	pop    %rbx
    7e5e:	5d                   	pop    %rbp
    7e5f:	41 5c                	pop    %r12
    7e61:	41 5d                	pop    %r13
    7e63:	41 5e                	pop    %r14
    7e65:	c3                   	ret
    7e66:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    7e6d:	00 00 00 
    7e70:	48 ba 56 55 55 55 55 	movabs $0x5555555555555556,%rdx
    7e77:	55 55 55 
    7e7a:	48 89 de             	mov    %rbx,%rsi
    7e7d:	48 29 ee             	sub    %rbp,%rsi
    7e80:	48 89 f0             	mov    %rsi,%rax
    7e83:	48 f7 ea             	imul   %rdx
    7e86:	48 89 f0             	mov    %rsi,%rax
    7e89:	48 c1 f8 3f          	sar    $0x3f,%rax
    7e8d:	48 29 c2             	sub    %rax,%rdx
    7e90:	48 8d 04 52          	lea    (%rdx,%rdx,2),%rax
    7e94:	48 29 c6             	sub    %rax,%rsi
    7e97:	0f b6 44 34 05       	movzbl 0x5(%rsp,%rsi,1),%eax
    7e9c:	48 83 c0 01          	add    $0x1,%rax
    7ea0:	e9 71 ff ff ff       	jmp    7e16 <ValueToString+0x76>
    7ea5:	0f 1f 00             	nopl   (%rax)
    7ea8:	b9 2d 00 00 00       	mov    $0x2d,%ecx
    7ead:	48 f7 df             	neg    %rdi
    7eb0:	49 83 c6 02          	add    $0x2,%r14
    7eb4:	66 41 89 4e fe       	mov    %cx,-0x2(%r14)
    7eb9:	e9 19 ff ff ff       	jmp    7dd7 <ValueToString+0x37>
    7ebe:	66 90                	xchg   %ax,%ax
    7ec0:	41 c7 06 30 00 00 00 	movl   $0x30,(%r14)
    7ec7:	48 83 c4 40          	add    $0x40,%rsp
    7ecb:	5b                   	pop    %rbx
    7ecc:	5d                   	pop    %rbp
    7ecd:	41 5c                	pop    %r12
    7ecf:	41 5d                	pop    %r13
    7ed1:	41 5e                	pop    %r14
    7ed3:	c3                   	ret
    7ed4:	0f 1f 40 00          	nopl   0x0(%rax)
    7ed8:	4c 89 f2             	mov    %r14,%rdx
    7edb:	e9 74 ff ff ff       	jmp    7e54 <ValueToString+0xb4>

0000000000007ee0 <FloatToString>:
    7ee0:	f3 0f 1e fa          	endbr64
    7ee4:	55                   	push   %rbp
    7ee5:	f2 48 0f 2c e8       	cvttsd2si %xmm0,%rbp
    7eea:	40 0f b6 f6          	movzbl %sil,%esi
    7eee:	53                   	push   %rbx
    7eef:	48 89 fb             	mov    %rdi,%rbx
    7ef2:	48 83 ec 18          	sub    $0x18,%rsp
    7ef6:	48 89 ea             	mov    %rbp,%rdx
    7ef9:	f2 0f 11 44 24 08    	movsd  %xmm0,0x8(%rsp)
    7eff:	e8 9c fe ff ff       	call   7da0 <ValueToString>
    7f04:	48 89 df             	mov    %rbx,%rdi
    7f07:	e8 74 19 00 00       	call   9880 <StrLen>
    7f0c:	66 0f ef c9          	pxor   %xmm1,%xmm1
    7f10:	f2 0f 10 44 24 08    	movsd  0x8(%rsp),%xmm0
    7f16:	b9 2e 00 00 00       	mov    $0x2e,%ecx
    7f1b:	f2 48 0f 2a cd       	cvtsi2sd %rbp,%xmm1
    7f20:	66 0f ef d2          	pxor   %xmm2,%xmm2
    7f24:	66 89 0c 43          	mov    %cx,(%rbx,%rax,2)
    7f28:	48 83 c0 01          	add    $0x1,%rax
    7f2c:	f2 0f 5c c1          	subsd  %xmm1,%xmm0
    7f30:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
    7f34:	0f 2f d0             	comiss %xmm0,%xmm2
    7f37:	76 07                	jbe    7f40 <FloatToString+0x60>
    7f39:	0f 57 05 40 d4 00 00 	xorps  0xd440(%rip),%xmm0        # 15380 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x580>
    7f40:	f3 0f 10 0d 48 d4 00 	movss  0xd448(%rip),%xmm1        # 15390 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x590>
    7f47:	00 
    7f48:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
    7f4c:	0f 2e c2             	ucomiss %xmm2,%xmm0
    7f4f:	7a 07                	jp     7f58 <FloatToString+0x78>
    7f51:	74 27                	je     7f7a <FloatToString+0x9a>
    7f53:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    7f58:	f3 48 0f 2c d0       	cvttss2si %xmm0,%rdx
    7f5d:	48 85 d2             	test   %rdx,%rdx
    7f60:	75 1d                	jne    7f7f <FloatToString+0x9f>
    7f62:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
    7f66:	ba 30 00 00 00       	mov    $0x30,%edx
    7f6b:	66 89 14 43          	mov    %dx,(%rbx,%rax,2)
    7f6f:	48 83 c0 01          	add    $0x1,%rax
    7f73:	0f 2e c2             	ucomiss %xmm2,%xmm0
    7f76:	7a e0                	jp     7f58 <FloatToString+0x78>
    7f78:	75 de                	jne    7f58 <FloatToString+0x78>
    7f7a:	f3 48 0f 2c d0       	cvttss2si %xmm0,%rdx
    7f7f:	66 0f ef d2          	pxor   %xmm2,%xmm2
    7f83:	f3 48 0f 2a d2       	cvtsi2ss %rdx,%xmm2
    7f88:	0f 2e c2             	ucomiss %xmm2,%xmm0
    7f8b:	7a 03                	jp     7f90 <FloatToString+0xb0>
    7f8d:	74 1a                	je     7fa9 <FloatToString+0xc9>
    7f8f:	90                   	nop
    7f90:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
    7f94:	66 0f ef d2          	pxor   %xmm2,%xmm2
    7f98:	f3 48 0f 2c d0       	cvttss2si %xmm0,%rdx
    7f9d:	f3 48 0f 2a d2       	cvtsi2ss %rdx,%xmm2
    7fa2:	0f 2e d0             	ucomiss %xmm0,%xmm2
    7fa5:	7a e9                	jp     7f90 <FloatToString+0xb0>
    7fa7:	75 e7                	jne    7f90 <FloatToString+0xb0>
    7fa9:	48 83 c4 18          	add    $0x18,%rsp
    7fad:	48 8d 3c 43          	lea    (%rbx,%rax,2),%rdi
    7fb1:	31 f6                	xor    %esi,%esi
    7fb3:	5b                   	pop    %rbx
    7fb4:	5d                   	pop    %rbp
    7fb5:	e9 e6 fd ff ff       	jmp    7da0 <ValueToString>
    7fba:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000007fc0 <TimeToString>:
    7fc0:	f3 0f 1e fa          	endbr64
    7fc4:	48 83 ec 28          	sub    $0x28,%rsp
    7fc8:	0f b6 46 04          	movzbl 0x4(%rsi),%eax
    7fcc:	48 89 f2             	mov    %rsi,%rdx
    7fcf:	84 c0                	test   %al,%al
    7fd1:	74 75                	je     8048 <TimeToString+0x88>
    7fd3:	0f b6 c8             	movzbl %al,%ecx
    7fd6:	be 61 00 00 00       	mov    $0x61,%esi
    7fdb:	3c 0b                	cmp    $0xb,%al
    7fdd:	76 0d                	jbe    7fec <TimeToString+0x2c>
    7fdf:	3c 0c                	cmp    $0xc,%al
    7fe1:	74 75                	je     8058 <TimeToString+0x98>
    7fe3:	48 83 e9 0c          	sub    $0xc,%rcx
    7fe7:	be 70 00 00 00       	mov    $0x70,%esi
    7fec:	44 0f b7 0a          	movzwl (%rdx),%r9d
    7ff0:	44 0f b6 52 02       	movzbl 0x2(%rdx),%r10d
    7ff5:	44 0f b6 42 03       	movzbl 0x3(%rdx),%r8d
    7ffa:	89 74 24 10          	mov    %esi,0x10(%rsp)
    7ffe:	31 f6                	xor    %esi,%esi
    8000:	44 89 c8             	mov    %r9d,%eax
    8003:	66 c1 e8 02          	shr    $0x2,%ax
    8007:	0f b7 c0             	movzwl %ax,%eax
    800a:	69 c0 7b 14 00 00    	imul   $0x147b,%eax,%eax
    8010:	c1 e8 11             	shr    $0x11,%eax
    8013:	8d 04 80             	lea    (%rax,%rax,4),%eax
    8016:	8d 04 80             	lea    (%rax,%rax,4),%eax
    8019:	c1 e0 02             	shl    $0x2,%eax
    801c:	41 29 c1             	sub    %eax,%r9d
    801f:	0f b6 42 05          	movzbl 0x5(%rdx),%eax
    8023:	48 89 0c 24          	mov    %rcx,(%rsp)
    8027:	48 8d 15 42 d1 00 00 	lea    0xd142(%rip),%rdx        # 15170 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x370>
    802e:	45 0f b7 c9          	movzwl %r9w,%r9d
    8032:	44 89 d1             	mov    %r10d,%ecx
    8035:	89 44 24 08          	mov    %eax,0x8(%rsp)
    8039:	31 c0                	xor    %eax,%eax
    803b:	e8 10 0e 00 00       	call   8e50 <UnicodeSPrint>
    8040:	48 83 c4 28          	add    $0x28,%rsp
    8044:	c3                   	ret
    8045:	0f 1f 00             	nopl   (%rax)
    8048:	be 61 00 00 00       	mov    $0x61,%esi
    804d:	b9 0c 00 00 00       	mov    $0xc,%ecx
    8052:	eb 98                	jmp    7fec <TimeToString+0x2c>
    8054:	0f 1f 40 00          	nopl   0x0(%rax)
    8058:	be 70 00 00 00       	mov    $0x70,%esi
    805d:	b9 0c 00 00 00       	mov    $0xc,%ecx
    8062:	eb 88                	jmp    7fec <TimeToString+0x2c>
    8064:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    806b:	00 00 00 00 
    806f:	90                   	nop

0000000000008070 <_Print>:
    8070:	f3 0f 1e fa          	endbr64
    8074:	41 56                	push   %r14
    8076:	41 55                	push   %r13
    8078:	4c 8d 2d 41 d1 00 00 	lea    0xd141(%rip),%r13        # 151c0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x3c0>
    807f:	41 54                	push   %r12
    8081:	4c 8d 25 28 d1 00 00 	lea    0xd128(%rip),%r12        # 151b0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x3b0>
    8088:	55                   	push   %rbp
    8089:	53                   	push   %rbx
    808a:	48 89 fb             	mov    %rdi,%rbx
    808d:	48 81 ec b0 02 00 00 	sub    $0x2b0,%rsp
    8094:	48 c7 47 48 00 00 00 	movq   $0x0,0x48(%rdi)
    809b:	00 
    809c:	48 8d 84 24 20 01 00 	lea    0x120(%rsp),%rax
    80a3:	00 
    80a4:	48 c7 47 08 00 00 00 	movq   $0x0,0x8(%rdi)
    80ab:	00 
    80ac:	48 89 47 30          	mov    %rax,0x30(%rdi)
    80b0:	48 89 47 40          	mov    %rax,0x40(%rdi)
    80b4:	48 8d 84 24 ae 02 00 	lea    0x2ae(%rsp),%rax
    80bb:	00 
    80bc:	48 89 47 38          	mov    %rax,0x38(%rdi)
    80c0:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    80c5:	48 89 87 90 00 00 00 	mov    %rax,0x90(%rdi)
    80cc:	31 c0                	xor    %eax,%eax
    80ce:	eb 48                	jmp    8118 <_Print+0xa8>
    80d0:	41 0f b6 2c 00       	movzbl (%r8,%rax,1),%ebp
    80d5:	48 8d 48 01          	lea    0x1(%rax),%rcx
    80d9:	48 89 4b 08          	mov    %rcx,0x8(%rbx)
    80dd:	66 85 ed             	test   %bp,%bp
    80e0:	74 54                	je     8136 <_Print+0xc6>
    80e2:	66 83 fd 25          	cmp    $0x25,%bp
    80e6:	74 70                	je     8158 <_Print+0xe8>
    80e8:	48 8b 43 40          	mov    0x40(%rbx),%rax
    80ec:	66 83 fd 0a          	cmp    $0xa,%bp
    80f0:	0f 84 3a 07 00 00    	je     8830 <_Print+0x7c0>
    80f6:	66 89 28             	mov    %bp,(%rax)
    80f9:	48 8b 43 40          	mov    0x40(%rbx),%rax
    80fd:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    8102:	48 83 c0 02          	add    $0x2,%rax
    8106:	48 89 43 40          	mov    %rax,0x40(%rbx)
    810a:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    810e:	0f 83 ac 06 00 00    	jae    87c0 <_Print+0x750>
    8114:	48 8b 43 08          	mov    0x8(%rbx),%rax
    8118:	0f b6 3b             	movzbl (%rbx),%edi
    811b:	4c 8b 43 10          	mov    0x10(%rbx),%r8
    811f:	40 84 ff             	test   %dil,%dil
    8122:	75 ac                	jne    80d0 <_Print+0x60>
    8124:	41 0f b7 2c 40       	movzwl (%r8,%rax,2),%ebp
    8129:	48 8d 48 01          	lea    0x1(%rax),%rcx
    812d:	48 89 4b 08          	mov    %rcx,0x8(%rbx)
    8131:	66 85 ed             	test   %bp,%bp
    8134:	75 ac                	jne    80e2 <_Print+0x72>
    8136:	48 89 df             	mov    %rbx,%rdi
    8139:	e8 32 f8 ff ff       	call   7970 <PFLUSH>
    813e:	48 8b 43 48          	mov    0x48(%rbx),%rax
    8142:	48 81 c4 b0 02 00 00 	add    $0x2b0,%rsp
    8149:	5b                   	pop    %rbx
    814a:	5d                   	pop    %rbp
    814b:	41 5c                	pop    %r12
    814d:	41 5d                	pop    %r13
    814f:	41 5e                	pop    %r14
    8151:	c3                   	ret
    8152:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    8158:	48 8d 94 24 00 01 00 	lea    0x100(%rsp),%rdx
    815f:	00 
    8160:	c6 44 24 20 00       	movb   $0x0,0x20(%rsp)
    8165:	48 8d 70 02          	lea    0x2(%rax),%rsi
    8169:	48 89 94 24 10 01 00 	mov    %rdx,0x110(%rsp)
    8170:	00 
    8171:	48 8d ac 24 08 01 00 	lea    0x108(%rsp),%rbp
    8178:	00 
    8179:	48 c7 84 24 08 01 00 	movq   $0xffffffffffffffff,0x108(%rsp)
    8180:	00 ff ff ff ff 
    8185:	48 c7 84 24 00 01 00 	movq   $0x0,0x100(%rsp)
    818c:	00 00 00 00 00 
    8191:	c7 84 24 18 01 00 00 	movl   $0x10020,0x118(%rsp)
    8198:	20 00 01 00 
    819c:	c6 84 24 1c 01 00 00 	movb   $0x0,0x11c(%rsp)
    81a3:	00 
    81a4:	48 c7 44 24 30 00 00 	movq   $0x0,0x30(%rsp)
    81ab:	00 00 
    81ad:	48 c7 43 58 00 00 00 	movq   $0x0,0x58(%rbx)
    81b4:	00 
    81b5:	40 84 ff             	test   %dil,%dil
    81b8:	0f 84 2f 02 00 00    	je     83ed <_Print+0x37d>
    81be:	41 0f b6 04 08       	movzbl (%r8,%rcx,1),%eax
    81c3:	48 89 73 08          	mov    %rsi,0x8(%rbx)
    81c7:	48 89 f1             	mov    %rsi,%rcx
    81ca:	66 85 c0             	test   %ax,%ax
    81cd:	74 41                	je     8210 <_Print+0x1a0>
    81cf:	8d 50 db             	lea    -0x25(%rax),%edx
    81d2:	66 83 fa 53          	cmp    $0x53,%dx
    81d6:	77 18                	ja     81f0 <_Print+0x180>
    81d8:	0f b7 d2             	movzwl %dx,%edx
    81db:	49 63 54 95 00       	movslq 0x0(%r13,%rdx,4),%rdx
    81e0:	4c 01 ea             	add    %r13,%rdx
    81e3:	3e ff e2             	notrack jmp *%rdx
    81e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    81ed:	00 00 00 
    81f0:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    81f5:	c7 44 24 38 3f 00 00 	movl   $0x3f,0x38(%rsp)
    81fc:	00 
    81fd:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    8202:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    8208:	48 89 df             	mov    %rbx,%rdi
    820b:	e8 b0 f8 ff ff       	call   7ac0 <PITEM>
    8210:	48 8b 6b 58          	mov    0x58(%rbx),%rbp
    8214:	48 85 ed             	test   %rbp,%rbp
    8217:	0f 84 f7 fe ff ff    	je     8114 <_Print+0xa4>
    821d:	48 89 df             	mov    %rbx,%rdi
    8220:	e8 4b f7 ff ff       	call   7970 <PFLUSH>
    8225:	48 8b 43 50          	mov    0x50(%rbx),%rax
    8229:	48 89 43 58          	mov    %rax,0x58(%rbx)
    822d:	48 8b 83 80 00 00 00 	mov    0x80(%rbx),%rax
    8234:	48 85 c0             	test   %rax,%rax
    8237:	74 0c                	je     8245 <_Print+0x1d5>
    8239:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
    8240:	48 89 ea             	mov    %rbp,%rdx
    8243:	ff d0                	call   *%rax
    8245:	48 89 6b 50          	mov    %rbp,0x50(%rbx)
    8249:	e9 c6 fe ff ff       	jmp    8114 <_Print+0xa4>
    824e:	66 90                	xchg   %ax,%ax
    8250:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
    8257:	00 
    8258:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
    825f:	eb 24                	jmp    8285 <_Print+0x215>
    8261:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8268:	48 8b 43 10          	mov    0x10(%rbx),%rax
    826c:	0f b6 04 08          	movzbl (%rax,%rcx,1),%eax
    8270:	48 8d 71 01          	lea    0x1(%rcx),%rsi
    8274:	8d 50 d0             	lea    -0x30(%rax),%edx
    8277:	48 89 73 08          	mov    %rsi,0x8(%rbx)
    827b:	66 83 fa 09          	cmp    $0x9,%dx
    827f:	0f 87 8b 05 00 00    	ja     8810 <_Print+0x7a0>
    8285:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
    828c:	00 
    828d:	48 8b 0a             	mov    (%rdx),%rcx
    8290:	48 8d 0c 89          	lea    (%rcx,%rcx,4),%rcx
    8294:	48 8d 44 48 d0       	lea    -0x30(%rax,%rcx,2),%rax
    8299:	48 89 02             	mov    %rax,(%rdx)
    829c:	0f b6 3b             	movzbl (%rbx),%edi
    829f:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
    82a3:	40 84 ff             	test   %dil,%dil
    82a6:	75 c0                	jne    8268 <_Print+0x1f8>
    82a8:	4c 8b 43 10          	mov    0x10(%rbx),%r8
    82ac:	41 0f b7 04 48       	movzwl (%r8,%rcx,2),%eax
    82b1:	eb bd                	jmp    8270 <_Print+0x200>
    82b3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    82b8:	8b 43 18             	mov    0x18(%rbx),%eax
    82bb:	83 f8 2f             	cmp    $0x2f,%eax
    82be:	0f 87 24 06 00 00    	ja     88e8 <_Print+0x878>
    82c4:	89 c2                	mov    %eax,%edx
    82c6:	83 c0 08             	add    $0x8,%eax
    82c9:	48 03 53 28          	add    0x28(%rbx),%rdx
    82cd:	89 43 18             	mov    %eax,0x18(%rbx)
    82d0:	48 8b 3a             	mov    (%rdx),%rdi
    82d3:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    82d8:	e8 f3 34 00 00       	call   b7d0 <DevicePathToStr>
    82dd:	ba 64 00 00 00       	mov    $0x64,%edx
    82e2:	48 89 ef             	mov    %rbp,%rdi
    82e5:	49 89 c6             	mov    %rax,%r14
    82e8:	48 89 c6             	mov    %rax,%rsi
    82eb:	e8 30 15 00 00       	call   9820 <StrnCpy>
    82f0:	31 c0                	xor    %eax,%eax
    82f2:	4c 89 f7             	mov    %r14,%rdi
    82f5:	66 89 84 24 fe 00 00 	mov    %ax,0xfe(%rsp)
    82fc:	00 
    82fd:	e8 3e ea ff ff       	call   6d40 <FreePool>
    8302:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    8307:	e9 fc fe ff ff       	jmp    8208 <_Print+0x198>
    830c:	0f 1f 40 00          	nopl   0x0(%rax)
    8310:	0f b6 94 24 1c 01 00 	movzbl 0x11c(%rsp),%edx
    8317:	00 
    8318:	8b 43 18             	mov    0x18(%rbx),%eax
    831b:	84 d2                	test   %dl,%dl
    831d:	0f 84 33 03 00 00    	je     8656 <_Print+0x5e6>
    8323:	83 f8 2f             	cmp    $0x2f,%eax
    8326:	0f 87 ec 05 00 00    	ja     8918 <_Print+0x8a8>
    832c:	89 c2                	mov    %eax,%edx
    832e:	83 c0 08             	add    $0x8,%eax
    8331:	48 03 53 28          	add    0x28(%rbx),%rdx
    8335:	89 43 18             	mov    %eax,0x18(%rbx)
    8338:	48 8b 32             	mov    (%rdx),%rsi
    833b:	48 85 f6             	test   %rsi,%rsi
    833e:	0f 84 32 03 00 00    	je     8676 <_Print+0x606>
    8344:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    8349:	48 89 ef             	mov    %rbp,%rdi
    834c:	e8 4f f5 ff ff       	call   78a0 <ValueToHex.part.0>
    8351:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    8356:	e9 ad fe ff ff       	jmp    8208 <_Print+0x198>
    835b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    8360:	80 bc 24 1c 01 00 00 	cmpb   $0x0,0x11c(%rsp)
    8367:	00 
    8368:	8b 43 18             	mov    0x18(%rbx),%eax
    836b:	0f 85 5f 04 00 00    	jne    87d0 <_Print+0x760>
    8371:	83 f8 2f             	cmp    $0x2f,%eax
    8374:	0f 86 20 06 00 00    	jbe    899a <_Print+0x92a>
    837a:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    837e:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8382:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8386:	8b 12                	mov    (%rdx),%edx
    8388:	e9 5b 04 00 00       	jmp    87e8 <_Print+0x778>
    838d:	0f 1f 00             	nopl   (%rax)
    8390:	8b 43 18             	mov    0x18(%rbx),%eax
    8393:	83 f8 2f             	cmp    $0x2f,%eax
    8396:	0f 87 04 05 00 00    	ja     88a0 <_Print+0x830>
    839c:	89 c2                	mov    %eax,%edx
    839e:	83 c0 08             	add    $0x8,%eax
    83a1:	48 03 53 28          	add    0x28(%rbx),%rdx
    83a5:	89 43 18             	mov    %eax,0x18(%rbx)
    83a8:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    83ad:	48 8b 32             	mov    (%rdx),%rsi
    83b0:	48 89 ef             	mov    %rbp,%rdi
    83b3:	e8 08 fc ff ff       	call   7fc0 <TimeToString>
    83b8:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    83bd:	e9 46 fe ff ff       	jmp    8208 <_Print+0x198>
    83c2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    83c8:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    83ce:	c6 84 24 1c 01 00 00 	movb   $0x1,0x11c(%rsp)
    83d5:	01 
    83d6:	0f 85 2c fe ff ff    	jne    8208 <_Print+0x198>
    83dc:	0f 1f 40 00          	nopl   0x0(%rax)
    83e0:	48 83 c6 01          	add    $0x1,%rsi
    83e4:	40 84 ff             	test   %dil,%dil
    83e7:	0f 85 d1 fd ff ff    	jne    81be <_Print+0x14e>
    83ed:	41 0f b7 04 48       	movzwl (%r8,%rcx,2),%eax
    83f2:	e9 cc fd ff ff       	jmp    81c3 <_Print+0x153>
    83f7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    83fe:	00 00 
    8400:	8b 43 18             	mov    0x18(%rbx),%eax
    8403:	83 f8 2f             	cmp    $0x2f,%eax
    8406:	0f 87 64 04 00 00    	ja     8870 <_Print+0x800>
    840c:	89 c2                	mov    %eax,%edx
    840e:	83 c0 08             	add    $0x8,%eax
    8411:	48 03 53 28          	add    0x28(%rbx),%rdx
    8415:	89 43 18             	mov    %eax,0x18(%rbx)
    8418:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    841d:	48 8b 32             	mov    (%rdx),%rsi
    8420:	48 89 ef             	mov    %rbp,%rdi
    8423:	e8 f8 35 00 00       	call   ba20 <StatusToString>
    8428:	e9 24 ff ff ff       	jmp    8351 <_Print+0x2e1>
    842d:	0f 1f 00             	nopl   (%rax)
    8430:	4c 8b 73 60          	mov    0x60(%rbx),%r14
    8434:	48 89 df             	mov    %rbx,%rdi
    8437:	e8 34 f5 ff ff       	call   7970 <PFLUSH>
    843c:	48 8b 43 50          	mov    0x50(%rbx),%rax
    8440:	48 89 43 58          	mov    %rax,0x58(%rbx)
    8444:	48 8b 83 80 00 00 00 	mov    0x80(%rbx),%rax
    844b:	48 85 c0             	test   %rax,%rax
    844e:	74 0c                	je     845c <_Print+0x3ec>
    8450:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
    8457:	4c 89 f2             	mov    %r14,%rdx
    845a:	ff d0                	call   *%rax
    845c:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    8462:	4c 89 73 50          	mov    %r14,0x50(%rbx)
    8466:	0f 85 9c fd ff ff    	jne    8208 <_Print+0x198>
    846c:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
    8470:	0f b6 3b             	movzbl (%rbx),%edi
    8473:	4c 8b 43 10          	mov    0x10(%rbx),%r8
    8477:	48 8d 71 01          	lea    0x1(%rcx),%rsi
    847b:	e9 35 fd ff ff       	jmp    81b5 <_Print+0x145>
    8480:	8b 43 18             	mov    0x18(%rbx),%eax
    8483:	83 f8 2f             	cmp    $0x2f,%eax
    8486:	0f 87 74 04 00 00    	ja     8900 <_Print+0x890>
    848c:	89 c2                	mov    %eax,%edx
    848e:	83 c0 08             	add    $0x8,%eax
    8491:	48 03 53 28          	add    0x28(%rbx),%rdx
    8495:	89 43 18             	mov    %eax,0x18(%rbx)
    8498:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    849d:	48 8b 32             	mov    (%rdx),%rsi
    84a0:	48 89 ef             	mov    %rbp,%rdi
    84a3:	e8 f8 e3 ff ff       	call   68a0 <GuidToString>
    84a8:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    84ad:	e9 56 fd ff ff       	jmp    8208 <_Print+0x198>
    84b2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    84b8:	8b 43 1c             	mov    0x1c(%rbx),%eax
    84bb:	3d af 00 00 00       	cmp    $0xaf,%eax
    84c0:	0f 87 f2 03 00 00    	ja     88b8 <_Print+0x848>
    84c6:	89 c2                	mov    %eax,%edx
    84c8:	83 c0 10             	add    $0x10,%eax
    84cb:	48 03 53 28          	add    0x28(%rbx),%rdx
    84cf:	89 43 1c             	mov    %eax,0x1c(%rbx)
    84d2:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    84d7:	0f b6 b4 24 1b 01 00 	movzbl 0x11b(%rsp),%esi
    84de:	00 
    84df:	f2 0f 10 02          	movsd  (%rdx),%xmm0
    84e3:	48 89 ef             	mov    %rbp,%rdi
    84e6:	e8 f5 f9 ff ff       	call   7ee0 <FloatToString>
    84eb:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    84f0:	e9 13 fd ff ff       	jmp    8208 <_Print+0x198>
    84f5:	0f 1f 00             	nopl   (%rax)
    84f8:	4c 8b 73 68          	mov    0x68(%rbx),%r14
    84fc:	e9 33 ff ff ff       	jmp    8434 <_Print+0x3c4>
    8501:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8508:	8b 43 18             	mov    0x18(%rbx),%eax
    850b:	83 f8 2f             	cmp    $0x2f,%eax
    850e:	0f 87 1c 04 00 00    	ja     8930 <_Print+0x8c0>
    8514:	89 c2                	mov    %eax,%edx
    8516:	83 c0 08             	add    $0x8,%eax
    8519:	48 03 53 28          	add    0x28(%rbx),%rdx
    851d:	89 43 18             	mov    %eax,0x18(%rbx)
    8520:	48 8b 02             	mov    (%rdx),%rax
    8523:	48 85 c0             	test   %rax,%rax
    8526:	49 0f 44 c4          	cmove  %r12,%rax
    852a:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    852f:	e9 d4 fc ff ff       	jmp    8208 <_Print+0x198>
    8534:	0f 1f 40 00          	nopl   0x0(%rax)
    8538:	41 b9 30 00 00 00    	mov    $0x30,%r9d
    853e:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    8544:	66 44 89 8c 24 18 01 	mov    %r9w,0x118(%rsp)
    854b:	00 00 
    854d:	0f 84 8d fe ff ff    	je     83e0 <_Print+0x370>
    8553:	e9 b0 fc ff ff       	jmp    8208 <_Print+0x198>
    8558:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    855f:	00 
    8560:	4c 8b 73 70          	mov    0x70(%rbx),%r14
    8564:	e9 cb fe ff ff       	jmp    8434 <_Print+0x3c4>
    8569:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8570:	80 bc 24 1c 01 00 00 	cmpb   $0x0,0x11c(%rsp)
    8577:	00 
    8578:	8b 43 18             	mov    0x18(%rbx),%eax
    857b:	0f 85 4f 02 00 00    	jne    87d0 <_Print+0x760>
    8581:	83 f8 2f             	cmp    $0x2f,%eax
    8584:	0f 87 ff 03 00 00    	ja     8989 <_Print+0x919>
    858a:	89 c2                	mov    %eax,%edx
    858c:	83 c0 08             	add    $0x8,%eax
    858f:	48 03 53 28          	add    0x28(%rbx),%rdx
    8593:	89 43 18             	mov    %eax,0x18(%rbx)
    8596:	48 63 12             	movslq (%rdx),%rdx
    8599:	e9 4a 02 00 00       	jmp    87e8 <_Print+0x778>
    859e:	66 90                	xchg   %ax,%ax
    85a0:	8b 43 18             	mov    0x18(%rbx),%eax
    85a3:	83 f8 2f             	cmp    $0x2f,%eax
    85a6:	0f 87 b4 03 00 00    	ja     8960 <_Print+0x8f0>
    85ac:	89 c2                	mov    %eax,%edx
    85ae:	83 c0 08             	add    $0x8,%eax
    85b1:	48 03 53 28          	add    0x28(%rbx),%rdx
    85b5:	89 43 18             	mov    %eax,0x18(%rbx)
    85b8:	48 8b 02             	mov    (%rdx),%rax
    85bb:	31 f6                	xor    %esi,%esi
    85bd:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    85c2:	66 89 74 24 3a       	mov    %si,0x3a(%rsp)
    85c7:	66 89 44 24 38       	mov    %ax,0x38(%rsp)
    85cc:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    85d1:	e9 32 fc ff ff       	jmp    8208 <_Print+0x198>
    85d6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    85dd:	00 00 00 
    85e0:	8b 43 18             	mov    0x18(%rbx),%eax
    85e3:	83 f8 2f             	cmp    $0x2f,%eax
    85e6:	0f 87 5c 03 00 00    	ja     8948 <_Print+0x8d8>
    85ec:	89 c2                	mov    %eax,%edx
    85ee:	83 c0 08             	add    $0x8,%eax
    85f1:	48 03 53 28          	add    0x28(%rbx),%rdx
    85f5:	89 43 18             	mov    %eax,0x18(%rbx)
    85f8:	48 8b 12             	mov    (%rdx),%rdx
    85fb:	48 8d 05 a6 cb 00 00 	lea    0xcba6(%rip),%rax        # 151a8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x3a8>
    8602:	c6 44 24 20 01       	movb   $0x1,0x20(%rsp)
    8607:	48 85 d2             	test   %rdx,%rdx
    860a:	48 0f 45 c2          	cmovne %rdx,%rax
    860e:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    8613:	e9 f0 fb ff ff       	jmp    8208 <_Print+0x198>
    8618:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    861f:	00 
    8620:	0f b6 94 24 1c 01 00 	movzbl 0x11c(%rsp),%edx
    8627:	00 
    8628:	b9 30 00 00 00       	mov    $0x30,%ecx
    862d:	66 89 8c 24 18 01 00 	mov    %cx,0x118(%rsp)
    8634:	00 
    8635:	80 fa 01             	cmp    $0x1,%dl
    8638:	48 19 c0             	sbb    %rax,%rax
    863b:	48 83 e0 f8          	and    $0xfffffffffffffff8,%rax
    863f:	48 83 c0 10          	add    $0x10,%rax
    8643:	48 89 84 24 00 01 00 	mov    %rax,0x100(%rsp)
    864a:	00 
    864b:	8b 43 18             	mov    0x18(%rbx),%eax
    864e:	84 d2                	test   %dl,%dl
    8650:	0f 85 cd fc ff ff    	jne    8323 <_Print+0x2b3>
    8656:	83 f8 2f             	cmp    $0x2f,%eax
    8659:	0f 87 71 02 00 00    	ja     88d0 <_Print+0x860>
    865f:	89 c2                	mov    %eax,%edx
    8661:	83 c0 08             	add    $0x8,%eax
    8664:	48 03 53 28          	add    0x28(%rbx),%rdx
    8668:	89 43 18             	mov    %eax,0x18(%rbx)
    866b:	8b 32                	mov    (%rdx),%esi
    866d:	48 85 f6             	test   %rsi,%rsi
    8670:	0f 85 ce fc ff ff    	jne    8344 <_Print+0x2d4>
    8676:	c7 44 24 38 30 00 00 	movl   $0x30,0x38(%rsp)
    867d:	00 
    867e:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    8683:	e9 c9 fc ff ff       	jmp    8351 <_Print+0x2e1>
    8688:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    868f:	00 
    8690:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    8696:	c6 84 24 1a 01 00 00 	movb   $0x0,0x11a(%rsp)
    869d:	00 
    869e:	0f 84 3c fd ff ff    	je     83e0 <_Print+0x370>
    86a4:	e9 5f fb ff ff       	jmp    8208 <_Print+0x198>
    86a9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    86b0:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    86b6:	c6 84 24 1b 01 00 00 	movb   $0x1,0x11b(%rsp)
    86bd:	01 
    86be:	0f 84 1c fd ff ff    	je     83e0 <_Print+0x370>
    86c4:	e9 3f fb ff ff       	jmp    8208 <_Print+0x198>
    86c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    86d0:	8b 43 18             	mov    0x18(%rbx),%eax
    86d3:	48 8b 8c 24 10 01 00 	mov    0x110(%rsp),%rcx
    86da:	00 
    86db:	83 f8 2f             	cmp    $0x2f,%eax
    86de:	0f 87 94 02 00 00    	ja     8978 <_Print+0x908>
    86e4:	89 c2                	mov    %eax,%edx
    86e6:	83 c0 08             	add    $0x8,%eax
    86e9:	48 03 53 28          	add    0x28(%rbx),%rdx
    86ed:	89 43 18             	mov    %eax,0x18(%rbx)
    86f0:	48 8b 02             	mov    (%rdx),%rax
    86f3:	48 89 01             	mov    %rax,(%rcx)
    86f6:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    86fc:	0f 84 6a fd ff ff    	je     846c <_Print+0x3fc>
    8702:	e9 01 fb ff ff       	jmp    8208 <_Print+0x198>
    8707:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    870e:	00 00 
    8710:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    8715:	c7 44 24 38 25 00 00 	movl   $0x25,0x38(%rsp)
    871c:	00 
    871d:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    8722:	e9 e1 fa ff ff       	jmp    8208 <_Print+0x198>
    8727:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    872e:	00 00 
    8730:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    8736:	48 89 ac 24 10 01 00 	mov    %rbp,0x110(%rsp)
    873d:	00 
    873e:	0f 84 9c fc ff ff    	je     83e0 <_Print+0x370>
    8744:	e9 bf fa ff ff       	jmp    8208 <_Print+0x198>
    8749:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8750:	4c 8b 73 68          	mov    0x68(%rbx),%r14
    8754:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    875a:	0f 85 a8 fa ff ff    	jne    8208 <_Print+0x198>
    8760:	4d 85 f6             	test   %r14,%r14
    8763:	0f 84 77 fc ff ff    	je     83e0 <_Print+0x370>
    8769:	48 89 df             	mov    %rbx,%rdi
    876c:	e8 ff f1 ff ff       	call   7970 <PFLUSH>
    8771:	48 8b 43 50          	mov    0x50(%rbx),%rax
    8775:	48 89 43 58          	mov    %rax,0x58(%rbx)
    8779:	48 8b 83 80 00 00 00 	mov    0x80(%rbx),%rax
    8780:	48 85 c0             	test   %rax,%rax
    8783:	74 0c                	je     8791 <_Print+0x721>
    8785:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
    878c:	4c 89 f2             	mov    %r14,%rdx
    878f:	ff d0                	call   *%rax
    8791:	4c 89 73 50          	mov    %r14,0x50(%rbx)
    8795:	48 c7 43 58 00 00 00 	movq   $0x0,0x58(%rbx)
    879c:	00 
    879d:	e9 72 f9 ff ff       	jmp    8114 <_Print+0xa4>
    87a2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    87a8:	4c 8b 73 70          	mov    0x70(%rbx),%r14
    87ac:	eb a6                	jmp    8754 <_Print+0x6e4>
    87ae:	66 90                	xchg   %ax,%ax
    87b0:	4c 8b 73 60          	mov    0x60(%rbx),%r14
    87b4:	eb 9e                	jmp    8754 <_Print+0x6e4>
    87b6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    87bd:	00 00 00 
    87c0:	48 89 df             	mov    %rbx,%rdi
    87c3:	e8 a8 f1 ff ff       	call   7970 <PFLUSH>
    87c8:	e9 47 f9 ff ff       	jmp    8114 <_Print+0xa4>
    87cd:	0f 1f 00             	nopl   (%rax)
    87d0:	83 f8 2f             	cmp    $0x2f,%eax
    87d3:	0f 87 af 00 00 00    	ja     8888 <_Print+0x818>
    87d9:	89 c2                	mov    %eax,%edx
    87db:	83 c0 08             	add    $0x8,%eax
    87de:	48 03 53 28          	add    0x28(%rbx),%rdx
    87e2:	89 43 18             	mov    %eax,0x18(%rbx)
    87e5:	48 8b 12             	mov    (%rdx),%rdx
    87e8:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    87ed:	0f b6 b4 24 1b 01 00 	movzbl 0x11b(%rsp),%esi
    87f4:	00 
    87f5:	48 89 ef             	mov    %rbp,%rdi
    87f8:	e8 a3 f5 ff ff       	call   7da0 <ValueToString>
    87fd:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    8802:	e9 01 fa ff ff       	jmp    8208 <_Print+0x198>
    8807:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    880e:	00 00 
    8810:	48 83 7c 24 30 00    	cmpq   $0x0,0x30(%rsp)
    8816:	48 89 4b 08          	mov    %rcx,0x8(%rbx)
    881a:	0f 85 e8 f9 ff ff    	jne    8208 <_Print+0x198>
    8820:	4c 8b 43 10          	mov    0x10(%rbx),%r8
    8824:	e9 8c f9 ff ff       	jmp    81b5 <_Print+0x145>
    8829:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8830:	41 ba 0d 00 00 00    	mov    $0xd,%r10d
    8836:	66 44 89 10          	mov    %r10w,(%rax)
    883a:	48 8b 43 40          	mov    0x40(%rbx),%rax
    883e:	48 83 43 48 01       	addq   $0x1,0x48(%rbx)
    8843:	48 83 c0 02          	add    $0x2,%rax
    8847:	48 89 43 40          	mov    %rax,0x40(%rbx)
    884b:	48 3b 43 38          	cmp    0x38(%rbx),%rax
    884f:	0f 82 a1 f8 ff ff    	jb     80f6 <_Print+0x86>
    8855:	48 89 df             	mov    %rbx,%rdi
    8858:	e8 13 f1 ff ff       	call   7970 <PFLUSH>
    885d:	48 8b 43 40          	mov    0x40(%rbx),%rax
    8861:	e9 90 f8 ff ff       	jmp    80f6 <_Print+0x86>
    8866:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    886d:	00 00 00 
    8870:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    8874:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8878:	48 89 43 20          	mov    %rax,0x20(%rbx)
    887c:	e9 97 fb ff ff       	jmp    8418 <_Print+0x3a8>
    8881:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8888:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    888c:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8890:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8894:	e9 4c ff ff ff       	jmp    87e5 <_Print+0x775>
    8899:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    88a0:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    88a4:	48 8d 42 08          	lea    0x8(%rdx),%rax
    88a8:	48 89 43 20          	mov    %rax,0x20(%rbx)
    88ac:	e9 f7 fa ff ff       	jmp    83a8 <_Print+0x338>
    88b1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    88b8:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    88bc:	48 8d 42 08          	lea    0x8(%rdx),%rax
    88c0:	48 89 43 20          	mov    %rax,0x20(%rbx)
    88c4:	e9 09 fc ff ff       	jmp    84d2 <_Print+0x462>
    88c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    88d0:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    88d4:	48 8d 42 08          	lea    0x8(%rdx),%rax
    88d8:	48 89 43 20          	mov    %rax,0x20(%rbx)
    88dc:	8b 32                	mov    (%rdx),%esi
    88de:	e9 8a fd ff ff       	jmp    866d <_Print+0x5fd>
    88e3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    88e8:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    88ec:	48 8d 42 08          	lea    0x8(%rdx),%rax
    88f0:	48 89 43 20          	mov    %rax,0x20(%rbx)
    88f4:	e9 d7 f9 ff ff       	jmp    82d0 <_Print+0x260>
    88f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8900:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    8904:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8908:	48 89 43 20          	mov    %rax,0x20(%rbx)
    890c:	e9 87 fb ff ff       	jmp    8498 <_Print+0x428>
    8911:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8918:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    891c:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8920:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8924:	e9 0f fa ff ff       	jmp    8338 <_Print+0x2c8>
    8929:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8930:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    8934:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8938:	48 89 43 20          	mov    %rax,0x20(%rbx)
    893c:	e9 df fb ff ff       	jmp    8520 <_Print+0x4b0>
    8941:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8948:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    894c:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8950:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8954:	e9 9f fc ff ff       	jmp    85f8 <_Print+0x588>
    8959:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8960:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    8964:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8968:	48 89 43 20          	mov    %rax,0x20(%rbx)
    896c:	e9 47 fc ff ff       	jmp    85b8 <_Print+0x548>
    8971:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    8978:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    897c:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8980:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8984:	e9 67 fd ff ff       	jmp    86f0 <_Print+0x680>
    8989:	48 8b 53 20          	mov    0x20(%rbx),%rdx
    898d:	48 8d 42 08          	lea    0x8(%rdx),%rax
    8991:	48 89 43 20          	mov    %rax,0x20(%rbx)
    8995:	e9 fc fb ff ff       	jmp    8596 <_Print+0x526>
    899a:	89 c2                	mov    %eax,%edx
    899c:	83 c0 08             	add    $0x8,%eax
    899f:	48 03 53 28          	add    0x28(%rbx),%rdx
    89a3:	89 43 18             	mov    %eax,0x18(%rbx)
    89a6:	8b 12                	mov    (%rdx),%edx
    89a8:	e9 3b fe ff ff       	jmp    87e8 <_Print+0x778>
    89ad:	0f 1f 00             	nopl   (%rax)

00000000000089b0 <DbgPrint>:
    89b0:	f3 0f 1e fa          	endbr64
    89b4:	41 55                	push   %r13
    89b6:	41 54                	push   %r12
    89b8:	55                   	push   %rbp
    89b9:	48 89 f5             	mov    %rsi,%rbp
    89bc:	53                   	push   %rbx
    89bd:	48 89 fb             	mov    %rdi,%rbx
    89c0:	48 81 ec 98 01 00 00 	sub    $0x198,%rsp
    89c7:	48 89 94 24 f0 00 00 	mov    %rdx,0xf0(%rsp)
    89ce:	00 
    89cf:	48 89 8c 24 f8 00 00 	mov    %rcx,0xf8(%rsp)
    89d6:	00 
    89d7:	4c 89 84 24 00 01 00 	mov    %r8,0x100(%rsp)
    89de:	00 
    89df:	4c 89 8c 24 08 01 00 	mov    %r9,0x108(%rsp)
    89e6:	00 
    89e7:	84 c0                	test   %al,%al
    89e9:	74 40                	je     8a2b <DbgPrint+0x7b>
    89eb:	0f 29 84 24 10 01 00 	movaps %xmm0,0x110(%rsp)
    89f2:	00 
    89f3:	0f 29 8c 24 20 01 00 	movaps %xmm1,0x120(%rsp)
    89fa:	00 
    89fb:	0f 29 94 24 30 01 00 	movaps %xmm2,0x130(%rsp)
    8a02:	00 
    8a03:	0f 29 9c 24 40 01 00 	movaps %xmm3,0x140(%rsp)
    8a0a:	00 
    8a0b:	0f 29 a4 24 50 01 00 	movaps %xmm4,0x150(%rsp)
    8a12:	00 
    8a13:	0f 29 ac 24 60 01 00 	movaps %xmm5,0x160(%rsp)
    8a1a:	00 
    8a1b:	0f 29 b4 24 70 01 00 	movaps %xmm6,0x170(%rsp)
    8a22:	00 
    8a23:	0f 29 bc 24 80 01 00 	movaps %xmm7,0x180(%rsp)
    8a2a:	00 
    8a2b:	48 89 d8             	mov    %rbx,%rax
    8a2e:	48 23 05 ab dc 00 00 	and    0xdcab(%rip),%rax        # 166e0 <EFIDebug>
    8a35:	75 19                	jne    8a50 <DbgPrint+0xa0>
    8a37:	48 81 c4 98 01 00 00 	add    $0x198,%rsp
    8a3e:	31 c0                	xor    %eax,%eax
    8a40:	5b                   	pop    %rbx
    8a41:	5d                   	pop    %rbp
    8a42:	41 5c                	pop    %r12
    8a44:	41 5d                	pop    %r13
    8a46:	c3                   	ret
    8a47:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    8a4e:	00 00 
    8a50:	48 8d 84 24 c0 01 00 	lea    0x1c0(%rsp),%rax
    8a57:	00 
    8a58:	4c 8d 6c 24 40       	lea    0x40(%rsp),%r13
    8a5d:	be 98 00 00 00       	mov    $0x98,%esi
    8a62:	c7 44 24 20 10 00 00 	movl   $0x10,0x20(%rsp)
    8a69:	00 
    8a6a:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    8a6f:	4c 89 ef             	mov    %r13,%rdi
    8a72:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    8a79:	00 
    8a7a:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    8a7f:	c7 44 24 24 30 00 00 	movl   $0x30,0x24(%rsp)
    8a86:	00 
    8a87:	e8 d4 e2 ff ff       	call   6d60 <ZeroMem>
    8a8c:	f3 0f 6f 44 24 20    	movdqu 0x20(%rsp),%xmm0
    8a92:	c6 44 24 40 01       	movb   $0x1,0x40(%rsp)
    8a97:	48 8d 05 92 eb ff ff 	lea    -0x146e(%rip),%rax        # 7630 <_DbgOut>
    8a9e:	48 89 84 24 b8 00 00 	mov    %rax,0xb8(%rsp)
    8aa5:	00 
    8aa6:	48 8b 15 63 47 01 00 	mov    0x14763(%rip),%rdx        # 1d210 <LibRuntimeDebugOut>
    8aad:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    8ab2:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
    8ab7:	48 c7 84 24 90 00 00 	movq   $0x47,0x90(%rsp)
    8abe:	00 47 00 00 00 
    8ac3:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
    8ac8:	0f 11 44 24 58       	movups %xmm0,0x58(%rsp)
    8acd:	48 85 d2             	test   %rdx,%rdx
    8ad0:	0f 84 b2 00 00 00    	je     8b88 <DbgPrint+0x1d8>
    8ad6:	48 8b 42 48          	mov    0x48(%rdx),%rax
    8ada:	4c 63 60 08          	movslq 0x8(%rax),%r12
    8ade:	48 89 94 24 c8 00 00 	mov    %rdx,0xc8(%rsp)
    8ae5:	00 
    8ae6:	4c 89 a4 24 90 00 00 	mov    %r12,0x90(%rsp)
    8aed:	00 
    8aee:	48 8b 72 28          	mov    0x28(%rdx),%rsi
    8af2:	4c 89 e0             	mov    %r12,%rax
    8af5:	25 f0 00 00 00       	and    $0xf0,%eax
    8afa:	48 89 b4 24 c0 00 00 	mov    %rsi,0xc0(%rsp)
    8b01:	00 
    8b02:	89 c2                	mov    %eax,%edx
    8b04:	89 c1                	mov    %eax,%ecx
    8b06:	83 c8 0e             	or     $0xe,%eax
    8b09:	83 ca 07             	or     $0x7,%edx
    8b0c:	83 c9 0f             	or     $0xf,%ecx
    8b0f:	f6 c3 02             	test   $0x2,%bl
    8b12:	48 89 94 24 a0 00 00 	mov    %rdx,0xa0(%rsp)
    8b19:	00 
    8b1a:	48 0f 45 d1          	cmovne %rcx,%rdx
    8b1e:	f7 c3 00 00 00 80    	test   $0x80000000,%ebx
    8b24:	48 89 8c 24 a8 00 00 	mov    %rcx,0xa8(%rsp)
    8b2b:	00 
    8b2c:	48 89 84 24 b0 00 00 	mov    %rax,0xb0(%rsp)
    8b33:	00 
    8b34:	48 0f 45 d0          	cmovne %rax,%rdx
    8b38:	48 85 f6             	test   %rsi,%rsi
    8b3b:	74 12                	je     8b4f <DbgPrint+0x19f>
    8b3d:	48 89 94 24 90 00 00 	mov    %rdx,0x90(%rsp)
    8b44:	00 
    8b45:	48 8b 8c 24 c8 00 00 	mov    0xc8(%rsp),%rcx
    8b4c:	00 
    8b4d:	ff d6                	call   *%rsi
    8b4f:	4c 89 ef             	mov    %r13,%rdi
    8b52:	e8 19 f5 ff ff       	call   8070 <_Print>
    8b57:	48 8b 84 24 c0 00 00 	mov    0xc0(%rsp),%rax
    8b5e:	00 
    8b5f:	48 85 c0             	test   %rax,%rax
    8b62:	0f 84 cf fe ff ff    	je     8a37 <DbgPrint+0x87>
    8b68:	48 8b 8c 24 c8 00 00 	mov    0xc8(%rsp),%rcx
    8b6f:	00 
    8b70:	4c 89 e2             	mov    %r12,%rdx
    8b73:	ff d0                	call   *%rax
    8b75:	48 81 c4 98 01 00 00 	add    $0x198,%rsp
    8b7c:	31 c0                	xor    %eax,%eax
    8b7e:	5b                   	pop    %rbx
    8b7f:	5d                   	pop    %rbp
    8b80:	41 5c                	pop    %r12
    8b82:	41 5d                	pop    %r13
    8b84:	c3                   	ret
    8b85:	0f 1f 00             	nopl   (%rax)
    8b88:	48 8b 05 49 46 01 00 	mov    0x14649(%rip),%rax        # 1d1d8 <ST>
    8b8f:	48 8b 50 50          	mov    0x50(%rax),%rdx
    8b93:	48 85 d2             	test   %rdx,%rdx
    8b96:	0f 85 3a ff ff ff    	jne    8ad6 <DbgPrint+0x126>
    8b9c:	b8 4e 00 00 00       	mov    $0x4e,%eax
    8ba1:	b9 4f 00 00 00       	mov    $0x4f,%ecx
    8ba6:	ba 47 00 00 00       	mov    $0x47,%edx
    8bab:	48 8b b4 24 c0 00 00 	mov    0xc0(%rsp),%rsi
    8bb2:	00 
    8bb3:	41 bc 47 00 00 00    	mov    $0x47,%r12d
    8bb9:	e9 51 ff ff ff       	jmp    8b0f <DbgPrint+0x15f>
    8bbe:	66 90                	xchg   %ax,%ax

0000000000008bc0 <_PoolCatPrint>:
    8bc0:	f3 0f 1e fa          	endbr64
    8bc4:	41 56                	push   %r14
    8bc6:	41 55                	push   %r13
    8bc8:	49 89 cd             	mov    %rcx,%r13
    8bcb:	41 54                	push   %r12
    8bcd:	49 89 d4             	mov    %rdx,%r12
    8bd0:	55                   	push   %rbp
    8bd1:	48 89 fd             	mov    %rdi,%rbp
    8bd4:	53                   	push   %rbx
    8bd5:	48 89 f3             	mov    %rsi,%rbx
    8bd8:	be 98 00 00 00       	mov    $0x98,%esi
    8bdd:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
    8be4:	49 89 e6             	mov    %rsp,%r14
    8be7:	4c 89 f7             	mov    %r14,%rdi
    8bea:	e8 71 e1 ff ff       	call   6d60 <ZeroMem>
    8bef:	4c 89 6c 24 78       	mov    %r13,0x78(%rsp)
    8bf4:	4c 89 f7             	mov    %r14,%rdi
    8bf7:	4c 89 a4 24 88 00 00 	mov    %r12,0x88(%rsp)
    8bfe:	00 
    8bff:	48 89 6c 24 10       	mov    %rbp,0x10(%rsp)
    8c04:	f3 0f 6f 03          	movdqu (%rbx),%xmm0
    8c08:	0f 11 44 24 18       	movups %xmm0,0x18(%rsp)
    8c0d:	48 8b 43 10          	mov    0x10(%rbx),%rax
    8c11:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    8c16:	e8 55 f4 ff ff       	call   8070 <_Print>
    8c1b:	48 81 c4 a0 00 00 00 	add    $0xa0,%rsp
    8c22:	5b                   	pop    %rbx
    8c23:	5d                   	pop    %rbp
    8c24:	41 5c                	pop    %r12
    8c26:	41 5d                	pop    %r13
    8c28:	41 5e                	pop    %r14
    8c2a:	c3                   	ret
    8c2b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000008c30 <UnicodeVSPrint>:
    8c30:	f3 0f 1e fa          	endbr64
    8c34:	48 d1 ee             	shr    $1,%rsi
    8c37:	48 83 ec 28          	sub    $0x28,%rsp
    8c3b:	49 89 c8             	mov    %rcx,%r8
    8c3e:	49 89 f9             	mov    %rdi,%r9
    8c41:	48 83 ee 01          	sub    $0x1,%rsi
    8c45:	48 89 d7             	mov    %rdx,%rdi
    8c48:	48 89 e2             	mov    %rsp,%rdx
    8c4b:	4c 89 0c 24          	mov    %r9,(%rsp)
    8c4f:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
    8c54:	48 8d 0d 05 ea ff ff 	lea    -0x15fb(%rip),%rcx        # 7660 <_SPrint>
    8c5b:	4c 89 c6             	mov    %r8,%rsi
    8c5e:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    8c65:	00 00 
    8c67:	e8 54 ff ff ff       	call   8bc0 <_PoolCatPrint>
    8c6c:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    8c71:	48 83 c4 28          	add    $0x28,%rsp
    8c75:	c3                   	ret
    8c76:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    8c7d:	00 00 00 

0000000000008c80 <VPoolPrint>:
    8c80:	f3 0f 1e fa          	endbr64
    8c84:	41 55                	push   %r13
    8c86:	41 54                	push   %r12
    8c88:	49 89 f4             	mov    %rsi,%r12
    8c8b:	be 18 00 00 00       	mov    $0x18,%esi
    8c90:	55                   	push   %rbp
    8c91:	48 89 fd             	mov    %rdi,%rbp
    8c94:	48 83 ec 20          	sub    $0x20,%rsp
    8c98:	49 89 e5             	mov    %rsp,%r13
    8c9b:	4c 89 ef             	mov    %r13,%rdi
    8c9e:	e8 bd e0 ff ff       	call   6d60 <ZeroMem>
    8ca3:	4c 89 ea             	mov    %r13,%rdx
    8ca6:	4c 89 e6             	mov    %r12,%rsi
    8ca9:	48 89 ef             	mov    %rbp,%rdi
    8cac:	48 8d 0d cd ea ff ff 	lea    -0x1533(%rip),%rcx        # 7780 <_PoolPrint>
    8cb3:	e8 08 ff ff ff       	call   8bc0 <_PoolCatPrint>
    8cb8:	48 8b 04 24          	mov    (%rsp),%rax
    8cbc:	48 83 c4 20          	add    $0x20,%rsp
    8cc0:	5d                   	pop    %rbp
    8cc1:	41 5c                	pop    %r12
    8cc3:	41 5d                	pop    %r13
    8cc5:	c3                   	ret
    8cc6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    8ccd:	00 00 00 

0000000000008cd0 <CatPrint>:
    8cd0:	f3 0f 1e fa          	endbr64
    8cd4:	53                   	push   %rbx
    8cd5:	48 89 fb             	mov    %rdi,%rbx
    8cd8:	48 89 f7             	mov    %rsi,%rdi
    8cdb:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
    8ce2:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    8ce7:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    8cec:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    8cf1:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    8cf6:	84 c0                	test   %al,%al
    8cf8:	74 37                	je     8d31 <CatPrint+0x61>
    8cfa:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    8cff:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    8d04:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    8d09:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    8d10:	00 
    8d11:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    8d18:	00 
    8d19:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    8d20:	00 
    8d21:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    8d28:	00 
    8d29:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    8d30:	00 
    8d31:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    8d38:	00 
    8d39:	48 89 e6             	mov    %rsp,%rsi
    8d3c:	48 89 da             	mov    %rbx,%rdx
    8d3f:	c7 04 24 10 00 00 00 	movl   $0x10,(%rsp)
    8d46:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    8d4b:	48 8d 0d 2e ea ff ff 	lea    -0x15d2(%rip),%rcx        # 7780 <_PoolPrint>
    8d52:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    8d57:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    8d5c:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    8d63:	00 
    8d64:	e8 57 fe ff ff       	call   8bc0 <_PoolCatPrint>
    8d69:	48 8b 03             	mov    (%rbx),%rax
    8d6c:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
    8d73:	5b                   	pop    %rbx
    8d74:	c3                   	ret
    8d75:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    8d7c:	00 00 00 00 

0000000000008d80 <PoolPrint>:
    8d80:	f3 0f 1e fa          	endbr64
    8d84:	41 54                	push   %r12
    8d86:	55                   	push   %rbp
    8d87:	48 89 fd             	mov    %rdi,%rbp
    8d8a:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
    8d91:	48 89 74 24 48       	mov    %rsi,0x48(%rsp)
    8d96:	48 89 54 24 50       	mov    %rdx,0x50(%rsp)
    8d9b:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
    8da0:	4c 89 44 24 60       	mov    %r8,0x60(%rsp)
    8da5:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
    8daa:	84 c0                	test   %al,%al
    8dac:	74 3d                	je     8deb <PoolPrint+0x6b>
    8dae:	0f 29 44 24 70       	movaps %xmm0,0x70(%rsp)
    8db3:	0f 29 8c 24 80 00 00 	movaps %xmm1,0x80(%rsp)
    8dba:	00 
    8dbb:	0f 29 94 24 90 00 00 	movaps %xmm2,0x90(%rsp)
    8dc2:	00 
    8dc3:	0f 29 9c 24 a0 00 00 	movaps %xmm3,0xa0(%rsp)
    8dca:	00 
    8dcb:	0f 29 a4 24 b0 00 00 	movaps %xmm4,0xb0(%rsp)
    8dd2:	00 
    8dd3:	0f 29 ac 24 c0 00 00 	movaps %xmm5,0xc0(%rsp)
    8dda:	00 
    8ddb:	0f 29 b4 24 d0 00 00 	movaps %xmm6,0xd0(%rsp)
    8de2:	00 
    8de3:	0f 29 bc 24 e0 00 00 	movaps %xmm7,0xe0(%rsp)
    8dea:	00 
    8deb:	4c 8d 64 24 20       	lea    0x20(%rsp),%r12
    8df0:	48 8d 84 24 10 01 00 	lea    0x110(%rsp),%rax
    8df7:	00 
    8df8:	be 18 00 00 00       	mov    $0x18,%esi
    8dfd:	c7 04 24 08 00 00 00 	movl   $0x8,(%rsp)
    8e04:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    8e09:	4c 89 e7             	mov    %r12,%rdi
    8e0c:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    8e11:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    8e16:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    8e1d:	00 
    8e1e:	e8 3d df ff ff       	call   6d60 <ZeroMem>
    8e23:	48 89 e6             	mov    %rsp,%rsi
    8e26:	4c 89 e2             	mov    %r12,%rdx
    8e29:	48 89 ef             	mov    %rbp,%rdi
    8e2c:	48 8d 0d 4d e9 ff ff 	lea    -0x16b3(%rip),%rcx        # 7780 <_PoolPrint>
    8e33:	e8 88 fd ff ff       	call   8bc0 <_PoolCatPrint>
    8e38:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
    8e3d:	48 81 c4 f8 00 00 00 	add    $0xf8,%rsp
    8e44:	5d                   	pop    %rbp
    8e45:	41 5c                	pop    %r12
    8e47:	c3                   	ret
    8e48:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    8e4f:	00 

0000000000008e50 <UnicodeSPrint>:
    8e50:	f3 0f 1e fa          	endbr64
    8e54:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
    8e5b:	49 89 fa             	mov    %rdi,%r10
    8e5e:	48 89 d7             	mov    %rdx,%rdi
    8e61:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
    8e66:	4c 89 44 24 60       	mov    %r8,0x60(%rsp)
    8e6b:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
    8e70:	84 c0                	test   %al,%al
    8e72:	74 3d                	je     8eb1 <UnicodeSPrint+0x61>
    8e74:	0f 29 44 24 70       	movaps %xmm0,0x70(%rsp)
    8e79:	0f 29 8c 24 80 00 00 	movaps %xmm1,0x80(%rsp)
    8e80:	00 
    8e81:	0f 29 94 24 90 00 00 	movaps %xmm2,0x90(%rsp)
    8e88:	00 
    8e89:	0f 29 9c 24 a0 00 00 	movaps %xmm3,0xa0(%rsp)
    8e90:	00 
    8e91:	0f 29 a4 24 b0 00 00 	movaps %xmm4,0xb0(%rsp)
    8e98:	00 
    8e99:	0f 29 ac 24 c0 00 00 	movaps %xmm5,0xc0(%rsp)
    8ea0:	00 
    8ea1:	0f 29 b4 24 d0 00 00 	movaps %xmm6,0xd0(%rsp)
    8ea8:	00 
    8ea9:	0f 29 bc 24 e0 00 00 	movaps %xmm7,0xe0(%rsp)
    8eb0:	00 
    8eb1:	48 d1 ee             	shr    $1,%rsi
    8eb4:	48 8d 84 24 00 01 00 	lea    0x100(%rsp),%rax
    8ebb:	00 
    8ebc:	48 8d 54 24 20       	lea    0x20(%rsp),%rdx
    8ec1:	c7 04 24 18 00 00 00 	movl   $0x18,(%rsp)
    8ec8:	48 83 ee 01          	sub    $0x1,%rsi
    8ecc:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    8ed1:	48 8d 0d 88 e7 ff ff 	lea    -0x1878(%rip),%rcx        # 7660 <_SPrint>
    8ed8:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    8edd:	48 89 74 24 30       	mov    %rsi,0x30(%rsp)
    8ee2:	48 89 e6             	mov    %rsp,%rsi
    8ee5:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    8eea:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    8ef1:	00 
    8ef2:	4c 89 54 24 20       	mov    %r10,0x20(%rsp)
    8ef7:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    8efe:	00 00 
    8f00:	e8 bb fc ff ff       	call   8bc0 <_PoolCatPrint>
    8f05:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    8f0a:	48 81 c4 f8 00 00 00 	add    $0xf8,%rsp
    8f11:	c3                   	ret
    8f12:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    8f19:	00 00 00 00 
    8f1d:	0f 1f 00             	nopl   (%rax)

0000000000008f20 <AsciiVSPrint>:
    8f20:	f3 0f 1e fa          	endbr64
    8f24:	41 57                	push   %r15
    8f26:	49 89 d7             	mov    %rdx,%r15
    8f29:	41 56                	push   %r14
    8f2b:	49 89 ce             	mov    %rcx,%r14
    8f2e:	41 55                	push   %r13
    8f30:	49 89 f5             	mov    %rsi,%r13
    8f33:	41 54                	push   %r12
    8f35:	45 31 e4             	xor    %r12d,%r12d
    8f38:	55                   	push   %rbp
    8f39:	53                   	push   %rbx
    8f3a:	48 89 fb             	mov    %rdi,%rbx
    8f3d:	48 8d 3c 36          	lea    (%rsi,%rsi,1),%rdi
    8f41:	48 83 ec 28          	sub    $0x28,%rsp
    8f45:	e8 d6 dc ff ff       	call   6c20 <AllocatePool>
    8f4a:	48 85 c0             	test   %rax,%rax
    8f4d:	74 7f                	je     8fce <AsciiVSPrint+0xae>
    8f4f:	4c 89 fe             	mov    %r15,%rsi
    8f52:	48 89 c5             	mov    %rax,%rbp
    8f55:	48 8d 3d b4 c3 00 00 	lea    0xc3b4(%rip),%rdi        # 15310 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x510>
    8f5c:	31 c0                	xor    %eax,%eax
    8f5e:	e8 1d fe ff ff       	call   8d80 <PoolPrint>
    8f63:	49 89 c7             	mov    %rax,%r15
    8f66:	48 85 c0             	test   %rax,%rax
    8f69:	74 5b                	je     8fc6 <AsciiVSPrint+0xa6>
    8f6b:	49 d1 ed             	shr    $1,%r13
    8f6e:	48 89 c7             	mov    %rax,%rdi
    8f71:	48 89 e2             	mov    %rsp,%rdx
    8f74:	4c 89 f6             	mov    %r14,%rsi
    8f77:	49 83 ed 01          	sub    $0x1,%r13
    8f7b:	48 8d 0d de e6 ff ff 	lea    -0x1922(%rip),%rcx        # 7660 <_SPrint>
    8f82:	48 89 2c 24          	mov    %rbp,(%rsp)
    8f86:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
    8f8b:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    8f92:	00 00 
    8f94:	e8 27 fc ff ff       	call   8bc0 <_PoolCatPrint>
    8f99:	4c 8b 64 24 08       	mov    0x8(%rsp),%r12
    8f9e:	4c 89 ff             	mov    %r15,%rdi
    8fa1:	e8 9a dd ff ff       	call   6d40 <FreePool>
    8fa6:	4d 85 e4             	test   %r12,%r12
    8fa9:	74 16                	je     8fc1 <AsciiVSPrint+0xa1>
    8fab:	31 c0                	xor    %eax,%eax
    8fad:	0f 1f 00             	nopl   (%rax)
    8fb0:	0f b7 54 45 00       	movzwl 0x0(%rbp,%rax,2),%edx
    8fb5:	88 14 03             	mov    %dl,(%rbx,%rax,1)
    8fb8:	48 83 c0 01          	add    $0x1,%rax
    8fbc:	4c 39 e0             	cmp    %r12,%rax
    8fbf:	75 ef                	jne    8fb0 <AsciiVSPrint+0x90>
    8fc1:	42 c6 04 23 00       	movb   $0x0,(%rbx,%r12,1)
    8fc6:	48 89 ef             	mov    %rbp,%rdi
    8fc9:	e8 72 dd ff ff       	call   6d40 <FreePool>
    8fce:	48 83 c4 28          	add    $0x28,%rsp
    8fd2:	4c 89 e0             	mov    %r12,%rax
    8fd5:	5b                   	pop    %rbx
    8fd6:	5d                   	pop    %rbp
    8fd7:	41 5c                	pop    %r12
    8fd9:	41 5d                	pop    %r13
    8fdb:	41 5e                	pop    %r14
    8fdd:	41 5f                	pop    %r15
    8fdf:	c3                   	ret

0000000000008fe0 <_IPrint>:
    8fe0:	f3 0f 1e fa          	endbr64
    8fe4:	41 57                	push   %r15
    8fe6:	49 89 f7             	mov    %rsi,%r15
    8fe9:	be 98 00 00 00       	mov    $0x98,%esi
    8fee:	41 56                	push   %r14
    8ff0:	49 89 fe             	mov    %rdi,%r14
    8ff3:	41 55                	push   %r13
    8ff5:	49 89 cd             	mov    %rcx,%r13
    8ff8:	41 54                	push   %r12
    8ffa:	55                   	push   %rbp
    8ffb:	4c 89 cd             	mov    %r9,%rbp
    8ffe:	53                   	push   %rbx
    8fff:	48 89 d3             	mov    %rdx,%rbx
    9002:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    9009:	4c 8d 64 24 30       	lea    0x30(%rsp),%r12
    900e:	4c 89 44 24 28       	mov    %r8,0x28(%rsp)
    9013:	4c 89 e7             	mov    %r12,%rdi
    9016:	e8 45 dd ff ff       	call   6d60 <ZeroMem>
    901b:	48 8b 43 08          	mov    0x8(%rbx),%rax
    901f:	48 89 9c 24 b8 00 00 	mov    %rbx,0xb8(%rsp)
    9026:	00 
    9027:	48 89 84 24 a8 00 00 	mov    %rax,0xa8(%rsp)
    902e:	00 
    902f:	48 8b 43 28          	mov    0x28(%rbx),%rax
    9033:	48 89 84 24 b0 00 00 	mov    %rax,0xb0(%rsp)
    903a:	00 
    903b:	48 8b 43 48          	mov    0x48(%rbx),%rax
    903f:	48 63 50 08          	movslq 0x8(%rax),%rdx
    9043:	48 89 d0             	mov    %rdx,%rax
    9046:	48 89 94 24 80 00 00 	mov    %rdx,0x80(%rsp)
    904d:	00 
    904e:	25 f0 00 00 00       	and    $0xf0,%eax
    9053:	89 c2                	mov    %eax,%edx
    9055:	83 ca 07             	or     $0x7,%edx
    9058:	48 89 94 24 90 00 00 	mov    %rdx,0x90(%rsp)
    905f:	00 
    9060:	89 c2                	mov    %eax,%edx
    9062:	83 c8 0e             	or     $0xe,%eax
    9065:	83 ca 0f             	or     $0xf,%edx
    9068:	48 89 84 24 a0 00 00 	mov    %rax,0xa0(%rsp)
    906f:	00 
    9070:	48 89 94 24 98 00 00 	mov    %rdx,0x98(%rsp)
    9077:	00 
    9078:	4d 85 ed             	test   %r13,%r13
    907b:	74 4b                	je     90c8 <_IPrint+0xe8>
    907d:	4c 89 6c 24 40       	mov    %r13,0x40(%rsp)
    9082:	f3 0f 6f 45 00       	movdqu 0x0(%rbp),%xmm0
    9087:	48 8b 45 10          	mov    0x10(%rbp),%rax
    908b:	0f 11 44 24 48       	movups %xmm0,0x48(%rsp)
    9090:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
    9095:	49 83 fe ff          	cmp    $0xffffffffffffffff,%r14
    9099:	74 0c                	je     90a7 <_IPrint+0xc7>
    909b:	4d 89 f8             	mov    %r15,%r8
    909e:	4c 89 f2             	mov    %r14,%rdx
    90a1:	48 89 d9             	mov    %rbx,%rcx
    90a4:	ff 53 38             	call   *0x38(%rbx)
    90a7:	4c 89 e7             	mov    %r12,%rdi
    90aa:	e8 c1 ef ff ff       	call   8070 <_Print>
    90af:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    90b6:	5b                   	pop    %rbx
    90b7:	5d                   	pop    %rbp
    90b8:	41 5c                	pop    %r12
    90ba:	41 5d                	pop    %r13
    90bc:	41 5e                	pop    %r14
    90be:	41 5f                	pop    %r15
    90c0:	c3                   	ret
    90c1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    90c8:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    90cd:	c6 44 24 30 01       	movb   $0x1,0x30(%rsp)
    90d2:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
    90d7:	eb a9                	jmp    9082 <_IPrint+0xa2>
    90d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000090e0 <Print>:
    90e0:	f3 0f 1e fa          	endbr64
    90e4:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    90eb:	49 89 fa             	mov    %rdi,%r10
    90ee:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    90f3:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    90f8:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    90fd:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    9102:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    9107:	84 c0                	test   %al,%al
    9109:	74 37                	je     9142 <Print+0x62>
    910b:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    9110:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    9115:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    911a:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    9121:	00 
    9122:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    9129:	00 
    912a:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    9131:	00 
    9132:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    9139:	00 
    913a:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    9141:	00 
    9142:	49 89 e1             	mov    %rsp,%r9
    9145:	45 31 c0             	xor    %r8d,%r8d
    9148:	4c 89 d1             	mov    %r10,%rcx
    914b:	48 c7 c6 ff ff ff ff 	mov    $0xffffffffffffffff,%rsi
    9152:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    9159:	00 
    915a:	48 c7 c7 ff ff ff ff 	mov    $0xffffffffffffffff,%rdi
    9161:	c7 04 24 08 00 00 00 	movl   $0x8,(%rsp)
    9168:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    916d:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    9172:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    9177:	48 8b 05 5a 40 01 00 	mov    0x1405a(%rip),%rax        # 1d1d8 <ST>
    917e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    9185:	00 
    9186:	48 8b 50 40          	mov    0x40(%rax),%rdx
    918a:	e8 51 fe ff ff       	call   8fe0 <_IPrint>
    918f:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    9196:	c3                   	ret
    9197:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    919e:	00 00 

00000000000091a0 <VPrint>:
    91a0:	f3 0f 1e fa          	endbr64
    91a4:	48 8b 05 2d 40 01 00 	mov    0x1402d(%rip),%rax        # 1d1d8 <ST>
    91ab:	48 89 f9             	mov    %rdi,%rcx
    91ae:	49 89 f1             	mov    %rsi,%r9
    91b1:	45 31 c0             	xor    %r8d,%r8d
    91b4:	48 c7 c6 ff ff ff ff 	mov    $0xffffffffffffffff,%rsi
    91bb:	48 c7 c7 ff ff ff ff 	mov    $0xffffffffffffffff,%rdi
    91c2:	48 8b 50 40          	mov    0x40(%rax),%rdx
    91c6:	e9 15 fe ff ff       	jmp    8fe0 <_IPrint>
    91cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000091d0 <PrintAt>:
    91d0:	f3 0f 1e fa          	endbr64
    91d4:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    91db:	49 89 d2             	mov    %rdx,%r10
    91de:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    91e3:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    91e8:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    91ed:	84 c0                	test   %al,%al
    91ef:	74 37                	je     9228 <PrintAt+0x58>
    91f1:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    91f6:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    91fb:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    9200:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    9207:	00 
    9208:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    920f:	00 
    9210:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    9217:	00 
    9218:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    921f:	00 
    9220:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    9227:	00 
    9228:	49 89 e1             	mov    %rsp,%r9
    922b:	45 31 c0             	xor    %r8d,%r8d
    922e:	4c 89 d1             	mov    %r10,%rcx
    9231:	c7 04 24 18 00 00 00 	movl   $0x18,(%rsp)
    9238:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    923f:	00 
    9240:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    9247:	00 
    9248:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    924d:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    9252:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    9257:	48 8b 05 7a 3f 01 00 	mov    0x13f7a(%rip),%rax        # 1d1d8 <ST>
    925e:	48 8b 50 40          	mov    0x40(%rax),%rdx
    9262:	e8 79 fd ff ff       	call   8fe0 <_IPrint>
    9267:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    926e:	c3                   	ret
    926f:	90                   	nop

0000000000009270 <IPrint>:
    9270:	f3 0f 1e fa          	endbr64
    9274:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    927b:	49 89 fa             	mov    %rdi,%r10
    927e:	49 89 f3             	mov    %rsi,%r11
    9281:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    9286:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    928b:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    9290:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    9295:	84 c0                	test   %al,%al
    9297:	74 37                	je     92d0 <IPrint+0x60>
    9299:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    929e:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    92a3:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    92a8:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    92af:	00 
    92b0:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    92b7:	00 
    92b8:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    92bf:	00 
    92c0:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    92c7:	00 
    92c8:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    92cf:	00 
    92d0:	49 89 e1             	mov    %rsp,%r9
    92d3:	45 31 c0             	xor    %r8d,%r8d
    92d6:	4c 89 d9             	mov    %r11,%rcx
    92d9:	4c 89 d2             	mov    %r10,%rdx
    92dc:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    92e3:	00 
    92e4:	48 c7 c6 ff ff ff ff 	mov    $0xffffffffffffffff,%rsi
    92eb:	48 c7 c7 ff ff ff ff 	mov    $0xffffffffffffffff,%rdi
    92f2:	c7 04 24 10 00 00 00 	movl   $0x10,(%rsp)
    92f9:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    92fe:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    9303:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    930a:	00 
    930b:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    9310:	e8 cb fc ff ff       	call   8fe0 <_IPrint>
    9315:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    931c:	c3                   	ret
    931d:	0f 1f 00             	nopl   (%rax)

0000000000009320 <IPrintAt>:
    9320:	f3 0f 1e fa          	endbr64
    9324:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    932b:	49 89 fa             	mov    %rdi,%r10
    932e:	48 89 f7             	mov    %rsi,%rdi
    9331:	48 89 d6             	mov    %rdx,%rsi
    9334:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    9339:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    933e:	84 c0                	test   %al,%al
    9340:	74 37                	je     9379 <IPrintAt+0x59>
    9342:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    9347:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    934c:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    9351:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    9358:	00 
    9359:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    9360:	00 
    9361:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    9368:	00 
    9369:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    9370:	00 
    9371:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    9378:	00 
    9379:	49 89 e1             	mov    %rsp,%r9
    937c:	45 31 c0             	xor    %r8d,%r8d
    937f:	4c 89 d2             	mov    %r10,%rdx
    9382:	c7 04 24 20 00 00 00 	movl   $0x20,(%rsp)
    9389:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    9390:	00 
    9391:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    9398:	00 
    9399:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    939e:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    93a3:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    93a8:	e8 33 fc ff ff       	call   8fe0 <_IPrint>
    93ad:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    93b4:	c3                   	ret
    93b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    93bc:	00 00 00 00 

00000000000093c0 <AsciiPrint>:
    93c0:	f3 0f 1e fa          	endbr64
    93c4:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    93cb:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    93d0:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
    93d5:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    93da:	4c 89 44 24 40       	mov    %r8,0x40(%rsp)
    93df:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
    93e4:	84 c0                	test   %al,%al
    93e6:	74 37                	je     941f <AsciiPrint+0x5f>
    93e8:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    93ed:	0f 29 4c 24 60       	movaps %xmm1,0x60(%rsp)
    93f2:	0f 29 54 24 70       	movaps %xmm2,0x70(%rsp)
    93f7:	0f 29 9c 24 80 00 00 	movaps %xmm3,0x80(%rsp)
    93fe:	00 
    93ff:	0f 29 a4 24 90 00 00 	movaps %xmm4,0x90(%rsp)
    9406:	00 
    9407:	0f 29 ac 24 a0 00 00 	movaps %xmm5,0xa0(%rsp)
    940e:	00 
    940f:	0f 29 b4 24 b0 00 00 	movaps %xmm6,0xb0(%rsp)
    9416:	00 
    9417:	0f 29 bc 24 c0 00 00 	movaps %xmm7,0xc0(%rsp)
    941e:	00 
    941f:	48 8d 84 24 e0 00 00 	lea    0xe0(%rsp),%rax
    9426:	00 
    9427:	49 89 e1             	mov    %rsp,%r9
    942a:	49 89 f8             	mov    %rdi,%r8
    942d:	31 c9                	xor    %ecx,%ecx
    942f:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    9434:	48 8d 44 24 20       	lea    0x20(%rsp),%rax
    9439:	48 c7 c6 ff ff ff ff 	mov    $0xffffffffffffffff,%rsi
    9440:	48 c7 c7 ff ff ff ff 	mov    $0xffffffffffffffff,%rdi
    9447:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    944c:	48 8b 05 85 3d 01 00 	mov    0x13d85(%rip),%rax        # 1d1d8 <ST>
    9453:	c7 04 24 08 00 00 00 	movl   $0x8,(%rsp)
    945a:	48 8b 50 40          	mov    0x40(%rax),%rdx
    945e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%rsp)
    9465:	00 
    9466:	e8 75 fb ff ff       	call   8fe0 <_IPrint>
    946b:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    9472:	c3                   	ret
    9473:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    947a:	00 00 00 00 
    947e:	66 90                	xchg   %ax,%ax

0000000000009480 <DumpHex>:
    9480:	f3 0f 1e fa          	endbr64
    9484:	41 57                	push   %r15
    9486:	41 56                	push   %r14
    9488:	49 89 d6             	mov    %rdx,%r14
    948b:	41 55                	push   %r13
    948d:	41 54                	push   %r12
    948f:	49 89 cc             	mov    %rcx,%r12
    9492:	55                   	push   %rbp
    9493:	53                   	push   %rbx
    9494:	48 81 ec d8 00 00 00 	sub    $0xd8,%rsp
    949b:	48 8b 05 36 3d 01 00 	mov    0x13d36(%rip),%rax        # 1d1d8 <ST>
    94a2:	48 89 7c 24 38       	mov    %rdi,0x38(%rsp)
    94a7:	4c 8d 4c 24 68       	lea    0x68(%rsp),%r9
    94ac:	4c 8d 44 24 60       	lea    0x60(%rsp),%r8
    94b1:	48 8b 40 40          	mov    0x40(%rax),%rax
    94b5:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    94ba:	48 8b 50 48          	mov    0x48(%rax),%rdx
    94be:	48 89 c1             	mov    %rax,%rcx
    94c1:	48 63 52 04          	movslq 0x4(%rdx),%rdx
    94c5:	ff 50 18             	call   *0x18(%rax)
    94c8:	48 83 6c 24 68 02    	subq   $0x2,0x68(%rsp)
    94ce:	4d 85 f6             	test   %r14,%r14
    94d1:	0f 84 51 01 00 00    	je     9628 <DumpHex+0x1a8>
    94d7:	45 31 db             	xor    %r11d,%r11d
    94da:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    94df:	4d 89 f2             	mov    %r14,%r10
    94e2:	4c 8d 7c 24 70       	lea    0x70(%rsp),%r15
    94e7:	48 8d 1d e2 d1 00 00 	lea    0xd1e2(%rip),%rbx        # 166d0 <Hex>
    94ee:	48 8d 84 24 92 00 00 	lea    0x92(%rsp),%rax
    94f5:	00 
    94f6:	41 bd 20 00 00 00    	mov    $0x20,%r13d
    94fc:	4d 89 de             	mov    %r11,%r14
    94ff:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
    9504:	48 8d 84 24 90 00 00 	lea    0x90(%rsp),%rax
    950b:	00 
    950c:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
    9511:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9518:	49 83 fa 0f          	cmp    $0xf,%r10
    951c:	0f 86 1e 01 00 00    	jbe    9640 <DumpHex+0x1c0>
    9522:	49 83 ea 10          	sub    $0x10,%r10
    9526:	bd 10 00 00 00       	mov    $0x10,%ebp
    952b:	41 0f b6 04 24       	movzbl (%r12),%eax
    9530:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
    9535:	bf 20 00 00 00       	mov    $0x20,%edi
    953a:	41 b8 2e 00 00 00    	mov    $0x2e,%r8d
    9540:	41 b9 2d 00 00 00    	mov    $0x2d,%r9d
    9546:	89 c2                	mov    %eax,%edx
    9548:	c0 ea 04             	shr    $0x4,%dl
    954b:	83 e2 0f             	and    $0xf,%edx
    954e:	0f b6 14 13          	movzbl (%rbx,%rdx,1),%edx
    9552:	88 94 24 90 00 00 00 	mov    %dl,0x90(%rsp)
    9559:	48 89 c2             	mov    %rax,%rdx
    955c:	83 e2 0f             	and    $0xf,%edx
    955f:	0f b6 14 13          	movzbl (%rbx,%rdx,1),%edx
    9563:	88 94 24 91 00 00 00 	mov    %dl,0x91(%rsp)
    956a:	31 d2                	xor    %edx,%edx
    956c:	eb 35                	jmp    95a3 <DumpHex+0x123>
    956e:	66 90                	xchg   %ax,%ax
    9570:	41 0f b6 04 14       	movzbl (%r12,%rdx,1),%eax
    9575:	89 c7                	mov    %eax,%edi
    9577:	40 c0 ef 04          	shr    $0x4,%dil
    957b:	83 e7 0f             	and    $0xf,%edi
    957e:	0f b6 3c 3b          	movzbl (%rbx,%rdi,1),%edi
    9582:	40 88 7e 01          	mov    %dil,0x1(%rsi)
    9586:	48 89 c7             	mov    %rax,%rdi
    9589:	83 e7 0f             	and    $0xf,%edi
    958c:	48 83 fa 07          	cmp    $0x7,%rdx
    9590:	0f b6 3c 3b          	movzbl (%rbx,%rdi,1),%edi
    9594:	40 88 7e 02          	mov    %dil,0x2(%rsi)
    9598:	44 89 ef             	mov    %r13d,%edi
    959b:	41 0f 44 f9          	cmove  %r9d,%edi
    959f:	48 83 c6 03          	add    $0x3,%rsi
    95a3:	40 88 3e             	mov    %dil,(%rsi)
    95a6:	8d 78 e0             	lea    -0x20(%rax),%edi
    95a9:	40 80 ff 5b          	cmp    $0x5b,%dil
    95ad:	41 0f 43 c0          	cmovae %r8d,%eax
    95b1:	41 88 04 17          	mov    %al,(%r15,%rdx,1)
    95b5:	48 83 c2 01          	add    $0x1,%rdx
    95b9:	48 39 d5             	cmp    %rdx,%rbp
    95bc:	75 b2                	jne    9570 <DumpHex+0xf0>
    95be:	48 8d 44 6d 00       	lea    0x0(%rbp,%rbp,2),%rax
    95c3:	4c 8b 44 24 40       	mov    0x40(%rsp),%r8
    95c8:	4d 89 f9             	mov    %r15,%r9
    95cb:	49 01 ec             	add    %rbp,%r12
    95ce:	48 8b 74 24 38       	mov    0x38(%rsp),%rsi
    95d3:	4c 89 54 24 30       	mov    %r10,0x30(%rsp)
    95d8:	49 83 c6 01          	add    $0x1,%r14
    95dc:	48 8d 15 33 bd 00 00 	lea    0xbd33(%rip),%rdx        # 15316 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x516>
    95e3:	c6 84 04 90 00 00 00 	movb   $0x0,0x90(%rsp,%rax,1)
    95ea:	00 
    95eb:	48 8d 3d 26 bd 00 00 	lea    0xbd26(%rip),%rdi        # 15318 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x518>
    95f2:	31 c0                	xor    %eax,%eax
    95f4:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
    95f9:	c6 44 2c 70 00       	movb   $0x0,0x70(%rsp,%rbp,1)
    95fe:	e8 dd fa ff ff       	call   90e0 <Print>
    9603:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    9608:	48 8b 44 24 68       	mov    0x68(%rsp),%rax
    960d:	4c 8b 54 24 30       	mov    0x30(%rsp),%r10
    9612:	48 01 e9             	add    %rbp,%rcx
    9615:	4c 39 f0             	cmp    %r14,%rax
    9618:	77 05                	ja     961f <DumpHex+0x19f>
    961a:	48 85 c0             	test   %rax,%rax
    961d:	75 31                	jne    9650 <DumpHex+0x1d0>
    961f:	4d 85 d2             	test   %r10,%r10
    9622:	0f 85 f0 fe ff ff    	jne    9518 <DumpHex+0x98>
    9628:	48 81 c4 d8 00 00 00 	add    $0xd8,%rsp
    962f:	5b                   	pop    %rbx
    9630:	5d                   	pop    %rbp
    9631:	41 5c                	pop    %r12
    9633:	41 5d                	pop    %r13
    9635:	41 5e                	pop    %r14
    9637:	41 5f                	pop    %r15
    9639:	c3                   	ret
    963a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    9640:	4c 89 d5             	mov    %r10,%rbp
    9643:	45 31 d2             	xor    %r10d,%r10d
    9646:	e9 e0 fe ff ff       	jmp    952b <DumpHex+0xab>
    964b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9650:	48 8d 3d e9 bc 00 00 	lea    0xbce9(%rip),%rdi        # 15340 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x540>
    9657:	31 c0                	xor    %eax,%eax
    9659:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
    965e:	45 31 f6             	xor    %r14d,%r14d
    9661:	e8 7a fa ff ff       	call   90e0 <Print>
    9666:	48 8d 74 24 5e       	lea    0x5e(%rsp),%rsi
    966b:	ba 01 00 00 00       	mov    $0x1,%edx
    9670:	48 8d 3d fd bc 00 00 	lea    0xbcfd(%rip),%rdi        # 15374 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x574>
    9677:	e8 34 0c 00 00       	call   a2b0 <Input>
    967c:	48 8d 3d f3 bc 00 00 	lea    0xbcf3(%rip),%rdi        # 15376 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x576>
    9683:	31 c0                	xor    %eax,%eax
    9685:	e8 56 fa ff ff       	call   90e0 <Print>
    968a:	4c 8b 54 24 30       	mov    0x30(%rsp),%r10
    968f:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    9694:	eb 89                	jmp    961f <DumpHex+0x19f>
    9696:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    969d:	00 00 00 

00000000000096a0 <StrCmp>:
    96a0:	f3 0f 1e fa          	endbr64
    96a4:	e9 27 07 00 00       	jmp    9dd0 <RtStrCmp>
    96a9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000096b0 <StrnCmp>:
    96b0:	f3 0f 1e fa          	endbr64
    96b4:	0f b7 07             	movzwl (%rdi),%eax
    96b7:	66 85 c0             	test   %ax,%ax
    96ba:	75 21                	jne    96dd <StrnCmp+0x2d>
    96bc:	eb 2a                	jmp    96e8 <StrnCmp+0x38>
    96be:	66 90                	xchg   %ax,%ax
    96c0:	0f b7 0e             	movzwl (%rsi),%ecx
    96c3:	66 39 c1             	cmp    %ax,%cx
    96c6:	75 2a                	jne    96f2 <StrnCmp+0x42>
    96c8:	0f b7 47 02          	movzwl 0x2(%rdi),%eax
    96cc:	48 83 c7 02          	add    $0x2,%rdi
    96d0:	48 83 c6 02          	add    $0x2,%rsi
    96d4:	48 83 ea 01          	sub    $0x1,%rdx
    96d8:	66 85 c0             	test   %ax,%ax
    96db:	74 0b                	je     96e8 <StrnCmp+0x38>
    96dd:	48 85 d2             	test   %rdx,%rdx
    96e0:	75 de                	jne    96c0 <StrnCmp+0x10>
    96e2:	31 c0                	xor    %eax,%eax
    96e4:	c3                   	ret
    96e5:	0f 1f 00             	nopl   (%rax)
    96e8:	31 c0                	xor    %eax,%eax
    96ea:	48 85 d2             	test   %rdx,%rdx
    96ed:	74 f5                	je     96e4 <StrnCmp+0x34>
    96ef:	0f b7 0e             	movzwl (%rsi),%ecx
    96f2:	29 c8                	sub    %ecx,%eax
    96f4:	48 98                	cltq
    96f6:	c3                   	ret
    96f7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    96fe:	00 00 

0000000000009700 <LibStubStriCmp>:
    9700:	f3 0f 1e fa          	endbr64
    9704:	57                   	push   %rdi
    9705:	48 89 d7             	mov    %rdx,%rdi
    9708:	56                   	push   %rsi
    9709:	4c 89 c6             	mov    %r8,%rsi
    970c:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
    9713:	0f 29 34 24          	movaps %xmm6,(%rsp)
    9717:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
    971c:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
    9722:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
    9728:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
    972e:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
    9734:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
    973a:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
    9740:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
    9747:	00 00 
    9749:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
    9750:	00 00 
    9752:	e8 79 06 00 00       	call   9dd0 <RtStrCmp>
    9757:	0f 28 34 24          	movaps (%rsp),%xmm6
    975b:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
    9760:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
    9766:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
    976c:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
    9772:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
    9778:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
    977e:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
    9784:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
    978b:	00 00 
    978d:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
    9794:	00 00 
    9796:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    979d:	5e                   	pop    %rsi
    979e:	5f                   	pop    %rdi
    979f:	c3                   	ret

00000000000097a0 <LibStubStrLwrUpr>:
    97a0:	f3 0f 1e fa          	endbr64
    97a4:	c3                   	ret
    97a5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    97ac:	00 00 00 00 

00000000000097b0 <StriCmp>:
    97b0:	f3 0f 1e fa          	endbr64
    97b4:	48 83 ec 28          	sub    $0x28,%rsp
    97b8:	48 8b 05 a1 cb 00 00 	mov    0xcba1(%rip),%rax        # 16360 <UnicodeInterface>
    97bf:	48 89 fa             	mov    %rdi,%rdx
    97c2:	49 89 f0             	mov    %rsi,%r8
    97c5:	48 89 c1             	mov    %rax,%rcx
    97c8:	ff 10                	call   *(%rax)
    97ca:	48 83 c4 28          	add    $0x28,%rsp
    97ce:	c3                   	ret
    97cf:	90                   	nop

00000000000097d0 <StrLwr>:
    97d0:	f3 0f 1e fa          	endbr64
    97d4:	48 83 ec 28          	sub    $0x28,%rsp
    97d8:	48 8b 05 81 cb 00 00 	mov    0xcb81(%rip),%rax        # 16360 <UnicodeInterface>
    97df:	48 89 fa             	mov    %rdi,%rdx
    97e2:	48 89 c1             	mov    %rax,%rcx
    97e5:	ff 50 10             	call   *0x10(%rax)
    97e8:	48 83 c4 28          	add    $0x28,%rsp
    97ec:	c3                   	ret
    97ed:	0f 1f 00             	nopl   (%rax)

00000000000097f0 <StrUpr>:
    97f0:	f3 0f 1e fa          	endbr64
    97f4:	48 83 ec 28          	sub    $0x28,%rsp
    97f8:	48 8b 05 61 cb 00 00 	mov    0xcb61(%rip),%rax        # 16360 <UnicodeInterface>
    97ff:	48 89 fa             	mov    %rdi,%rdx
    9802:	48 89 c1             	mov    %rax,%rcx
    9805:	ff 50 18             	call   *0x18(%rax)
    9808:	48 83 c4 28          	add    $0x28,%rsp
    980c:	c3                   	ret
    980d:	0f 1f 00             	nopl   (%rax)

0000000000009810 <StrCpy>:
    9810:	f3 0f 1e fa          	endbr64
    9814:	e9 07 06 00 00       	jmp    9e20 <RtStrCpy>
    9819:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009820 <StrnCpy>:
    9820:	f3 0f 1e fa          	endbr64
    9824:	e9 27 06 00 00       	jmp    9e50 <RtStrnCpy>
    9829:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009830 <StpCpy>:
    9830:	f3 0f 1e fa          	endbr64
    9834:	e9 87 06 00 00       	jmp    9ec0 <RtStpCpy>
    9839:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009840 <StpnCpy>:
    9840:	f3 0f 1e fa          	endbr64
    9844:	e9 a7 06 00 00       	jmp    9ef0 <RtStpnCpy>
    9849:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009850 <StrCat>:
    9850:	f3 0f 1e fa          	endbr64
    9854:	e9 27 07 00 00       	jmp    9f80 <RtStrCat>
    9859:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009860 <StrnCat>:
    9860:	f3 0f 1e fa          	endbr64
    9864:	e9 67 07 00 00       	jmp    9fd0 <RtStrnCat>
    9869:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009870 <StrnLen>:
    9870:	f3 0f 1e fa          	endbr64
    9874:	e9 17 08 00 00       	jmp    a090 <RtStrnLen>
    9879:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009880 <StrLen>:
    9880:	f3 0f 1e fa          	endbr64
    9884:	e9 d7 07 00 00       	jmp    a060 <RtStrLen>
    9889:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009890 <StrSize>:
    9890:	f3 0f 1e fa          	endbr64
    9894:	e9 37 08 00 00       	jmp    a0d0 <RtStrSize>
    9899:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000098a0 <StrDuplicate>:
    98a0:	f3 0f 1e fa          	endbr64
    98a4:	41 55                	push   %r13
    98a6:	41 54                	push   %r12
    98a8:	55                   	push   %rbp
    98a9:	48 89 fd             	mov    %rdi,%rbp
    98ac:	e8 1f 08 00 00       	call   a0d0 <RtStrSize>
    98b1:	48 89 c7             	mov    %rax,%rdi
    98b4:	49 89 c5             	mov    %rax,%r13
    98b7:	e8 64 d3 ff ff       	call   6c20 <AllocatePool>
    98bc:	49 89 c4             	mov    %rax,%r12
    98bf:	48 85 c0             	test   %rax,%rax
    98c2:	74 0e                	je     98d2 <StrDuplicate+0x32>
    98c4:	4c 89 ea             	mov    %r13,%rdx
    98c7:	48 89 ee             	mov    %rbp,%rsi
    98ca:	48 89 c7             	mov    %rax,%rdi
    98cd:	e8 ae d4 ff ff       	call   6d80 <CopyMem>
    98d2:	4c 89 e0             	mov    %r12,%rax
    98d5:	5d                   	pop    %rbp
    98d6:	41 5c                	pop    %r12
    98d8:	41 5d                	pop    %r13
    98da:	c3                   	ret
    98db:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000098e0 <strlena>:
    98e0:	f3 0f 1e fa          	endbr64
    98e4:	31 c0                	xor    %eax,%eax
    98e6:	80 3f 00             	cmpb   $0x0,(%rdi)
    98e9:	74 15                	je     9900 <strlena+0x20>
    98eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    98f0:	48 83 c0 01          	add    $0x1,%rax
    98f4:	80 3c 07 00          	cmpb   $0x0,(%rdi,%rax,1)
    98f8:	75 f6                	jne    98f0 <strlena+0x10>
    98fa:	c3                   	ret
    98fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9900:	c3                   	ret
    9901:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9908:	00 00 00 00 
    990c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000009910 <strcmpa>:
    9910:	f3 0f 1e fa          	endbr64
    9914:	0f b6 07             	movzbl (%rdi),%eax
    9917:	84 c0                	test   %al,%al
    9919:	75 18                	jne    9933 <strcmpa+0x23>
    991b:	eb 2e                	jmp    994b <strcmpa+0x3b>
    991d:	0f 1f 00             	nopl   (%rax)
    9920:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
    9924:	48 83 c7 01          	add    $0x1,%rdi
    9928:	48 8d 56 01          	lea    0x1(%rsi),%rdx
    992c:	84 c0                	test   %al,%al
    992e:	74 10                	je     9940 <strcmpa+0x30>
    9930:	48 89 d6             	mov    %rdx,%rsi
    9933:	0f b6 16             	movzbl (%rsi),%edx
    9936:	38 c2                	cmp    %al,%dl
    9938:	74 e6                	je     9920 <strcmpa+0x10>
    993a:	29 d0                	sub    %edx,%eax
    993c:	48 98                	cltq
    993e:	c3                   	ret
    993f:	90                   	nop
    9940:	0f b6 56 01          	movzbl 0x1(%rsi),%edx
    9944:	31 c0                	xor    %eax,%eax
    9946:	29 d0                	sub    %edx,%eax
    9948:	48 98                	cltq
    994a:	c3                   	ret
    994b:	0f b6 16             	movzbl (%rsi),%edx
    994e:	31 c0                	xor    %eax,%eax
    9950:	eb e8                	jmp    993a <strcmpa+0x2a>
    9952:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9959:	00 00 00 00 
    995d:	0f 1f 00             	nopl   (%rax)

0000000000009960 <strncmpa>:
    9960:	f3 0f 1e fa          	endbr64
    9964:	0f b6 07             	movzbl (%rdi),%eax
    9967:	84 c0                	test   %al,%al
    9969:	75 20                	jne    998b <strncmpa+0x2b>
    996b:	eb 2b                	jmp    9998 <strncmpa+0x38>
    996d:	0f 1f 00             	nopl   (%rax)
    9970:	0f b6 0e             	movzbl (%rsi),%ecx
    9973:	38 c1                	cmp    %al,%cl
    9975:	75 2b                	jne    99a2 <strncmpa+0x42>
    9977:	0f b6 47 01          	movzbl 0x1(%rdi),%eax
    997b:	48 83 c7 01          	add    $0x1,%rdi
    997f:	48 83 c6 01          	add    $0x1,%rsi
    9983:	48 83 ea 01          	sub    $0x1,%rdx
    9987:	84 c0                	test   %al,%al
    9989:	74 0d                	je     9998 <strncmpa+0x38>
    998b:	48 85 d2             	test   %rdx,%rdx
    998e:	75 e0                	jne    9970 <strncmpa+0x10>
    9990:	31 c0                	xor    %eax,%eax
    9992:	c3                   	ret
    9993:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9998:	31 c0                	xor    %eax,%eax
    999a:	48 85 d2             	test   %rdx,%rdx
    999d:	74 f3                	je     9992 <strncmpa+0x32>
    999f:	0f b6 0e             	movzbl (%rsi),%ecx
    99a2:	29 c8                	sub    %ecx,%eax
    99a4:	48 98                	cltq
    99a6:	c3                   	ret
    99a7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    99ae:	00 00 

00000000000099b0 <xtoi>:
    99b0:	f3 0f 1e fa          	endbr64
    99b4:	0f 1f 40 00          	nopl   0x0(%rax)
    99b8:	0f b7 17             	movzwl (%rdi),%edx
    99bb:	48 83 c7 02          	add    $0x2,%rdi
    99bf:	66 83 fa 20          	cmp    $0x20,%dx
    99c3:	74 f3                	je     99b8 <xtoi+0x8>
    99c5:	31 c0                	xor    %eax,%eax
    99c7:	66 85 d2             	test   %dx,%dx
    99ca:	75 26                	jne    99f2 <xtoi+0x42>
    99cc:	eb 5a                	jmp    9a28 <xtoi+0x78>
    99ce:	66 90                	xchg   %ax,%ax
    99d0:	83 ea 20             	sub    $0x20,%edx
    99d3:	48 c1 e0 04          	shl    $0x4,%rax
    99d7:	0f b7 ca             	movzwl %dx,%ecx
    99da:	ba 37 00 00 00       	mov    $0x37,%edx
    99df:	48 83 c7 02          	add    $0x2,%rdi
    99e3:	48 29 d1             	sub    %rdx,%rcx
    99e6:	0f b7 57 fe          	movzwl -0x2(%rdi),%edx
    99ea:	48 09 c8             	or     %rcx,%rax
    99ed:	66 85 d2             	test   %dx,%dx
    99f0:	74 3e                	je     9a30 <xtoi+0x80>
    99f2:	8d 4a 9f             	lea    -0x61(%rdx),%ecx
    99f5:	66 83 f9 05          	cmp    $0x5,%cx
    99f9:	76 d5                	jbe    99d0 <xtoi+0x20>
    99fb:	8d 4a d0             	lea    -0x30(%rdx),%ecx
    99fe:	66 83 f9 09          	cmp    $0x9,%cx
    9a02:	76 09                	jbe    9a0d <xtoi+0x5d>
    9a04:	8d 4a bf             	lea    -0x41(%rdx),%ecx
    9a07:	66 83 f9 05          	cmp    $0x5,%cx
    9a0b:	77 1b                	ja     9a28 <xtoi+0x78>
    9a0d:	48 c1 e0 04          	shl    $0x4,%rax
    9a11:	66 83 fa 41          	cmp    $0x41,%dx
    9a15:	0f b7 ca             	movzwl %dx,%ecx
    9a18:	48 19 d2             	sbb    %rdx,%rdx
    9a1b:	48 83 e2 f9          	and    $0xfffffffffffffff9,%rdx
    9a1f:	48 83 c2 37          	add    $0x37,%rdx
    9a23:	eb ba                	jmp    99df <xtoi+0x2f>
    9a25:	0f 1f 00             	nopl   (%rax)
    9a28:	c3                   	ret
    9a29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9a30:	c3                   	ret
    9a31:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9a38:	00 00 00 00 
    9a3c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000009a40 <Atoi>:
    9a40:	f3 0f 1e fa          	endbr64
    9a44:	0f 1f 40 00          	nopl   0x0(%rax)
    9a48:	0f b7 07             	movzwl (%rdi),%eax
    9a4b:	48 83 c7 02          	add    $0x2,%rdi
    9a4f:	66 83 f8 20          	cmp    $0x20,%ax
    9a53:	74 f3                	je     9a48 <Atoi+0x8>
    9a55:	45 31 c0             	xor    %r8d,%r8d
    9a58:	66 85 c0             	test   %ax,%ax
    9a5b:	75 19                	jne    9a76 <Atoi+0x36>
    9a5d:	eb 20                	jmp    9a7f <Atoi+0x3f>
    9a5f:	90                   	nop
    9a60:	4b 8d 14 80          	lea    (%r8,%r8,4),%rdx
    9a64:	48 83 c7 02          	add    $0x2,%rdi
    9a68:	4c 8d 44 50 d0       	lea    -0x30(%rax,%rdx,2),%r8
    9a6d:	0f b7 47 fe          	movzwl -0x2(%rdi),%eax
    9a71:	66 85 c0             	test   %ax,%ax
    9a74:	74 09                	je     9a7f <Atoi+0x3f>
    9a76:	8d 50 d0             	lea    -0x30(%rax),%edx
    9a79:	66 83 fa 09          	cmp    $0x9,%dx
    9a7d:	76 e1                	jbe    9a60 <Atoi+0x20>
    9a7f:	4c 89 c0             	mov    %r8,%rax
    9a82:	c3                   	ret
    9a83:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9a8a:	00 00 00 00 
    9a8e:	66 90                	xchg   %ax,%ax

0000000000009a90 <MetaMatch>:
    9a90:	f3 0f 1e fa          	endbr64
    9a94:	55                   	push   %rbp
    9a95:	48 89 fd             	mov    %rdi,%rbp
    9a98:	53                   	push   %rbx
    9a99:	48 89 f3             	mov    %rsi,%rbx
    9a9c:	48 83 ec 08          	sub    $0x8,%rsp
    9aa0:	48 8d 75 02          	lea    0x2(%rbp),%rsi
    9aa4:	0f b7 03             	movzwl (%rbx),%eax
    9aa7:	0f b7 4e fe          	movzwl -0x2(%rsi),%ecx
    9aab:	48 8d 6e fe          	lea    -0x2(%rsi),%rbp
    9aaf:	48 83 c3 02          	add    $0x2,%rbx
    9ab3:	66 83 f8 3f          	cmp    $0x3f,%ax
    9ab7:	0f 84 eb 00 00 00    	je     9ba8 <MetaMatch+0x118>
    9abd:	77 51                	ja     9b10 <MetaMatch+0x80>
    9abf:	66 85 c0             	test   %ax,%ax
    9ac2:	0f 84 08 01 00 00    	je     9bd0 <MetaMatch+0x140>
    9ac8:	66 83 f8 2a          	cmp    $0x2a,%ax
    9acc:	0f 85 ee 00 00 00    	jne    9bc0 <MetaMatch+0x130>
    9ad2:	66 85 c9             	test   %cx,%cx
    9ad5:	74 c9                	je     9aa0 <MetaMatch+0x10>
    9ad7:	48 89 de             	mov    %rbx,%rsi
    9ada:	48 89 ef             	mov    %rbp,%rdi
    9add:	e8 ae ff ff ff       	call   9a90 <MetaMatch>
    9ae2:	84 c0                	test   %al,%al
    9ae4:	75 1a                	jne    9b00 <MetaMatch+0x70>
    9ae6:	48 83 c5 02          	add    $0x2,%rbp
    9aea:	66 83 7d 00 00       	cmpw   $0x0,0x0(%rbp)
    9aef:	74 af                	je     9aa0 <MetaMatch+0x10>
    9af1:	48 89 de             	mov    %rbx,%rsi
    9af4:	48 89 ef             	mov    %rbp,%rdi
    9af7:	e8 94 ff ff ff       	call   9a90 <MetaMatch>
    9afc:	84 c0                	test   %al,%al
    9afe:	74 e6                	je     9ae6 <MetaMatch+0x56>
    9b00:	b8 01 00 00 00       	mov    $0x1,%eax
    9b05:	e9 cc 00 00 00       	jmp    9bd6 <MetaMatch+0x146>
    9b0a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    9b10:	66 83 f8 5b          	cmp    $0x5b,%ax
    9b14:	0f 85 a6 00 00 00    	jne    9bc0 <MetaMatch+0x130>
    9b1a:	66 85 c9             	test   %cx,%cx
    9b1d:	0f 84 8a 00 00 00    	je     9bad <MetaMatch+0x11d>
    9b23:	31 d2                	xor    %edx,%edx
    9b25:	eb 10                	jmp    9b37 <MetaMatch+0xa7>
    9b27:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    9b2e:	00 00 
    9b30:	89 c2                	mov    %eax,%edx
    9b32:	66 39 c8             	cmp    %cx,%ax
    9b35:	74 39                	je     9b70 <MetaMatch+0xe0>
    9b37:	0f b7 03             	movzwl (%rbx),%eax
    9b3a:	48 83 c3 02          	add    $0x2,%rbx
    9b3e:	66 85 c0             	test   %ax,%ax
    9b41:	74 3d                	je     9b80 <MetaMatch+0xf0>
    9b43:	66 83 f8 5d          	cmp    $0x5d,%ax
    9b47:	74 64                	je     9bad <MetaMatch+0x11d>
    9b49:	66 83 f8 2d          	cmp    $0x2d,%ax
    9b4d:	75 e1                	jne    9b30 <MetaMatch+0xa0>
    9b4f:	0f b7 03             	movzwl (%rbx),%eax
    9b52:	66 85 c0             	test   %ax,%ax
    9b55:	74 56                	je     9bad <MetaMatch+0x11d>
    9b57:	66 83 f8 5d          	cmp    $0x5d,%ax
    9b5b:	74 50                	je     9bad <MetaMatch+0x11d>
    9b5d:	66 39 ca             	cmp    %cx,%dx
    9b60:	77 ce                	ja     9b30 <MetaMatch+0xa0>
    9b62:	66 39 c8             	cmp    %cx,%ax
    9b65:	73 2f                	jae    9b96 <MetaMatch+0x106>
    9b67:	89 c2                	mov    %eax,%edx
    9b69:	66 39 c8             	cmp    %cx,%ax
    9b6c:	75 c9                	jne    9b37 <MetaMatch+0xa7>
    9b6e:	66 90                	xchg   %ax,%ax
    9b70:	66 83 f8 5d          	cmp    $0x5d,%ax
    9b74:	75 20                	jne    9b96 <MetaMatch+0x106>
    9b76:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    9b7d:	00 00 00 
    9b80:	48 83 c6 02          	add    $0x2,%rsi
    9b84:	e9 1b ff ff ff       	jmp    9aa4 <MetaMatch+0x14>
    9b89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9b90:	66 83 f8 5d          	cmp    $0x5d,%ax
    9b94:	74 ea                	je     9b80 <MetaMatch+0xf0>
    9b96:	0f b7 03             	movzwl (%rbx),%eax
    9b99:	48 83 c3 02          	add    $0x2,%rbx
    9b9d:	66 85 c0             	test   %ax,%ax
    9ba0:	75 ee                	jne    9b90 <MetaMatch+0x100>
    9ba2:	eb dc                	jmp    9b80 <MetaMatch+0xf0>
    9ba4:	0f 1f 40 00          	nopl   0x0(%rax)
    9ba8:	66 85 c9             	test   %cx,%cx
    9bab:	75 d3                	jne    9b80 <MetaMatch+0xf0>
    9bad:	48 83 c4 08          	add    $0x8,%rsp
    9bb1:	31 c0                	xor    %eax,%eax
    9bb3:	5b                   	pop    %rbx
    9bb4:	5d                   	pop    %rbp
    9bb5:	c3                   	ret
    9bb6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    9bbd:	00 00 00 
    9bc0:	66 39 c8             	cmp    %cx,%ax
    9bc3:	75 e8                	jne    9bad <MetaMatch+0x11d>
    9bc5:	48 83 c6 02          	add    $0x2,%rsi
    9bc9:	e9 d6 fe ff ff       	jmp    9aa4 <MetaMatch+0x14>
    9bce:	66 90                	xchg   %ax,%ax
    9bd0:	66 85 c9             	test   %cx,%cx
    9bd3:	0f 94 c0             	sete   %al
    9bd6:	48 83 c4 08          	add    $0x8,%rsp
    9bda:	5b                   	pop    %rbx
    9bdb:	5d                   	pop    %rbp
    9bdc:	c3                   	ret
    9bdd:	0f 1f 00             	nopl   (%rax)

0000000000009be0 <LibStubMetaiMatch>:
    9be0:	f3 0f 1e fa          	endbr64
    9be4:	57                   	push   %rdi
    9be5:	48 89 d7             	mov    %rdx,%rdi
    9be8:	56                   	push   %rsi
    9be9:	4c 89 c6             	mov    %r8,%rsi
    9bec:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
    9bf3:	0f 29 34 24          	movaps %xmm6,(%rsp)
    9bf7:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
    9bfc:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
    9c02:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
    9c08:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
    9c0e:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
    9c14:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
    9c1a:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
    9c20:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
    9c27:	00 00 
    9c29:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
    9c30:	00 00 
    9c32:	e8 59 fe ff ff       	call   9a90 <MetaMatch>
    9c37:	0f 28 34 24          	movaps (%rsp),%xmm6
    9c3b:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
    9c40:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
    9c46:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
    9c4c:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
    9c52:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
    9c58:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
    9c5e:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
    9c64:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
    9c6b:	00 00 
    9c6d:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
    9c74:	00 00 
    9c76:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    9c7d:	5e                   	pop    %rsi
    9c7e:	5f                   	pop    %rdi
    9c7f:	c3                   	ret

0000000000009c80 <MetaiMatch>:
    9c80:	f3 0f 1e fa          	endbr64
    9c84:	48 83 ec 28          	sub    $0x28,%rsp
    9c88:	48 8b 05 d1 c6 00 00 	mov    0xc6d1(%rip),%rax        # 16360 <UnicodeInterface>
    9c8f:	48 89 fa             	mov    %rdi,%rdx
    9c92:	49 89 f0             	mov    %rsi,%r8
    9c95:	48 89 c1             	mov    %rax,%rcx
    9c98:	ff 50 08             	call   *0x8(%rax)
    9c9b:	48 83 c4 28          	add    $0x28,%rsp
    9c9f:	c3                   	ret

0000000000009ca0 <RtZeroMem>:
    9ca0:	f3 0f 1e fa          	endbr64
    9ca4:	48 85 f6             	test   %rsi,%rsi
    9ca7:	74 14                	je     9cbd <RtZeroMem+0x1d>
    9ca9:	48 01 fe             	add    %rdi,%rsi
    9cac:	0f 1f 40 00          	nopl   0x0(%rax)
    9cb0:	48 83 c7 01          	add    $0x1,%rdi
    9cb4:	c6 47 ff 00          	movb   $0x0,-0x1(%rdi)
    9cb8:	48 39 f7             	cmp    %rsi,%rdi
    9cbb:	75 f3                	jne    9cb0 <RtZeroMem+0x10>
    9cbd:	c3                   	ret
    9cbe:	66 90                	xchg   %ax,%ax

0000000000009cc0 <RtSetMem>:
    9cc0:	f3 0f 1e fa          	endbr64
    9cc4:	48 8d 04 37          	lea    (%rdi,%rsi,1),%rax
    9cc8:	48 85 f6             	test   %rsi,%rsi
    9ccb:	74 0f                	je     9cdc <RtSetMem+0x1c>
    9ccd:	0f 1f 00             	nopl   (%rax)
    9cd0:	48 83 c7 01          	add    $0x1,%rdi
    9cd4:	88 57 ff             	mov    %dl,-0x1(%rdi)
    9cd7:	48 39 c7             	cmp    %rax,%rdi
    9cda:	75 f4                	jne    9cd0 <RtSetMem+0x10>
    9cdc:	c3                   	ret
    9cdd:	0f 1f 00             	nopl   (%rax)

0000000000009ce0 <RtCopyMem>:
    9ce0:	f3 0f 1e fa          	endbr64
    9ce4:	48 85 ff             	test   %rdi,%rdi
    9ce7:	0f 94 c0             	sete   %al
    9cea:	48 39 f7             	cmp    %rsi,%rdi
    9ced:	0f 94 c1             	sete   %cl
    9cf0:	08 c8                	or     %cl,%al
    9cf2:	75 2c                	jne    9d20 <RtCopyMem+0x40>
    9cf4:	48 85 f6             	test   %rsi,%rsi
    9cf7:	74 27                	je     9d20 <RtCopyMem+0x40>
    9cf9:	48 8d 42 ff          	lea    -0x1(%rdx),%rax
    9cfd:	48 39 f7             	cmp    %rsi,%rdi
    9d00:	77 26                	ja     9d28 <RtCopyMem+0x48>
    9d02:	31 c0                	xor    %eax,%eax
    9d04:	48 85 d2             	test   %rdx,%rdx
    9d07:	74 47                	je     9d50 <RtCopyMem+0x70>
    9d09:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9d10:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
    9d14:	88 0c 07             	mov    %cl,(%rdi,%rax,1)
    9d17:	48 83 c0 01          	add    $0x1,%rax
    9d1b:	48 39 c2             	cmp    %rax,%rdx
    9d1e:	75 f0                	jne    9d10 <RtCopyMem+0x30>
    9d20:	c3                   	ret
    9d21:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9d28:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
    9d2c:	48 39 cf             	cmp    %rcx,%rdi
    9d2f:	73 d1                	jae    9d02 <RtCopyMem+0x22>
    9d31:	48 85 d2             	test   %rdx,%rdx
    9d34:	74 ea                	je     9d20 <RtCopyMem+0x40>
    9d36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    9d3d:	00 00 00 
    9d40:	0f b6 14 06          	movzbl (%rsi,%rax,1),%edx
    9d44:	88 14 07             	mov    %dl,(%rdi,%rax,1)
    9d47:	48 83 e8 01          	sub    $0x1,%rax
    9d4b:	73 f3                	jae    9d40 <RtCopyMem+0x60>
    9d4d:	c3                   	ret
    9d4e:	66 90                	xchg   %ax,%ax
    9d50:	c3                   	ret
    9d51:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9d58:	00 00 00 00 
    9d5c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000009d60 <RtCompareMem>:
    9d60:	f3 0f 1e fa          	endbr64
    9d64:	31 c0                	xor    %eax,%eax
    9d66:	48 85 d2             	test   %rdx,%rdx
    9d69:	75 0e                	jne    9d79 <RtCompareMem+0x19>
    9d6b:	eb 26                	jmp    9d93 <RtCompareMem+0x33>
    9d6d:	0f 1f 00             	nopl   (%rax)
    9d70:	48 83 c0 01          	add    $0x1,%rax
    9d74:	48 39 c2             	cmp    %rax,%rdx
    9d77:	74 17                	je     9d90 <RtCompareMem+0x30>
    9d79:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
    9d7d:	44 0f b6 04 06       	movzbl (%rsi,%rax,1),%r8d
    9d82:	44 38 c1             	cmp    %r8b,%cl
    9d85:	74 e9                	je     9d70 <RtCompareMem+0x10>
    9d87:	0f b6 c1             	movzbl %cl,%eax
    9d8a:	44 29 c0             	sub    %r8d,%eax
    9d8d:	48 98                	cltq
    9d8f:	c3                   	ret
    9d90:	31 c0                	xor    %eax,%eax
    9d92:	c3                   	ret
    9d93:	c3                   	ret
    9d94:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9d9b:	00 00 00 00 
    9d9f:	90                   	nop

0000000000009da0 <RtCompareGuid>:
    9da0:	f3 0f 1e fa          	endbr64
    9da4:	8b 17                	mov    (%rdi),%edx
    9da6:	8b 47 04             	mov    0x4(%rdi),%eax
    9da9:	2b 16                	sub    (%rsi),%edx
    9dab:	2b 46 04             	sub    0x4(%rsi),%eax
    9dae:	09 d0                	or     %edx,%eax
    9db0:	8b 57 08             	mov    0x8(%rdi),%edx
    9db3:	2b 56 08             	sub    0x8(%rsi),%edx
    9db6:	09 c2                	or     %eax,%edx
    9db8:	8b 47 0c             	mov    0xc(%rdi),%eax
    9dbb:	2b 46 0c             	sub    0xc(%rsi),%eax
    9dbe:	09 d0                	or     %edx,%eax
    9dc0:	48 98                	cltq
    9dc2:	c3                   	ret
    9dc3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    9dca:	00 00 00 
    9dcd:	0f 1f 00             	nopl   (%rax)

0000000000009dd0 <RtStrCmp>:
    9dd0:	f3 0f 1e fa          	endbr64
    9dd4:	0f b7 07             	movzwl (%rdi),%eax
    9dd7:	66 85 c0             	test   %ax,%ax
    9dda:	75 18                	jne    9df4 <RtStrCmp+0x24>
    9ddc:	eb 35                	jmp    9e13 <RtStrCmp+0x43>
    9dde:	66 90                	xchg   %ax,%ax
    9de0:	0f b7 47 02          	movzwl 0x2(%rdi),%eax
    9de4:	48 83 c7 02          	add    $0x2,%rdi
    9de8:	48 8d 56 02          	lea    0x2(%rsi),%rdx
    9dec:	66 85 c0             	test   %ax,%ax
    9def:	74 17                	je     9e08 <RtStrCmp+0x38>
    9df1:	48 89 d6             	mov    %rdx,%rsi
    9df4:	0f b7 16             	movzwl (%rsi),%edx
    9df7:	66 39 c2             	cmp    %ax,%dx
    9dfa:	74 e4                	je     9de0 <RtStrCmp+0x10>
    9dfc:	29 d0                	sub    %edx,%eax
    9dfe:	48 98                	cltq
    9e00:	c3                   	ret
    9e01:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9e08:	0f b7 56 02          	movzwl 0x2(%rsi),%edx
    9e0c:	31 c0                	xor    %eax,%eax
    9e0e:	29 d0                	sub    %edx,%eax
    9e10:	48 98                	cltq
    9e12:	c3                   	ret
    9e13:	0f b7 16             	movzwl (%rsi),%edx
    9e16:	31 c0                	xor    %eax,%eax
    9e18:	eb e2                	jmp    9dfc <RtStrCmp+0x2c>
    9e1a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000009e20 <RtStrCpy>:
    9e20:	f3 0f 1e fa          	endbr64
    9e24:	eb 15                	jmp    9e3b <RtStrCpy+0x1b>
    9e26:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    9e2d:	00 00 00 
    9e30:	66 89 07             	mov    %ax,(%rdi)
    9e33:	48 83 c7 02          	add    $0x2,%rdi
    9e37:	48 83 c6 02          	add    $0x2,%rsi
    9e3b:	0f b7 06             	movzwl (%rsi),%eax
    9e3e:	66 85 c0             	test   %ax,%ax
    9e41:	75 ed                	jne    9e30 <RtStrCpy+0x10>
    9e43:	31 c0                	xor    %eax,%eax
    9e45:	66 89 07             	mov    %ax,(%rdi)
    9e48:	c3                   	ret
    9e49:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009e50 <RtStrnCpy>:
    9e50:	f3 0f 1e fa          	endbr64
    9e54:	41 55                	push   %r13
    9e56:	41 54                	push   %r12
    9e58:	49 89 fc             	mov    %rdi,%r12
    9e5b:	55                   	push   %rbp
    9e5c:	66 83 3e 00          	cmpw   $0x0,(%rsi)
    9e60:	48 89 f5             	mov    %rsi,%rbp
    9e63:	74 4b                	je     9eb0 <RtStrnCpy+0x60>
    9e65:	48 85 d2             	test   %rdx,%rdx
    9e68:	74 46                	je     9eb0 <RtStrnCpy+0x60>
    9e6a:	31 c0                	xor    %eax,%eax
    9e6c:	eb 07                	jmp    9e75 <RtStrnCpy+0x25>
    9e6e:	66 90                	xchg   %ax,%ax
    9e70:	48 39 c2             	cmp    %rax,%rdx
    9e73:	76 0c                	jbe    9e81 <RtStrnCpy+0x31>
    9e75:	48 83 c0 01          	add    $0x1,%rax
    9e79:	66 83 7c 45 00 00    	cmpw   $0x0,0x0(%rbp,%rax,2)
    9e7f:	75 ef                	jne    9e70 <RtStrnCpy+0x20>
    9e81:	4c 8d 2c 00          	lea    (%rax,%rax,1),%r13
    9e85:	48 39 c2             	cmp    %rax,%rdx
    9e88:	74 12                	je     9e9c <RtStrnCpy+0x4c>
    9e8a:	48 29 c2             	sub    %rax,%rdx
    9e8d:	4b 8d 3c 2c          	lea    (%r12,%r13,1),%rdi
    9e91:	48 8d 34 12          	lea    (%rdx,%rdx,1),%rsi
    9e95:	31 d2                	xor    %edx,%edx
    9e97:	e8 24 fe ff ff       	call   9cc0 <RtSetMem>
    9e9c:	4c 89 ea             	mov    %r13,%rdx
    9e9f:	48 89 ee             	mov    %rbp,%rsi
    9ea2:	4c 89 e7             	mov    %r12,%rdi
    9ea5:	5d                   	pop    %rbp
    9ea6:	41 5c                	pop    %r12
    9ea8:	41 5d                	pop    %r13
    9eaa:	e9 31 fe ff ff       	jmp    9ce0 <RtCopyMem>
    9eaf:	90                   	nop
    9eb0:	45 31 ed             	xor    %r13d,%r13d
    9eb3:	31 c0                	xor    %eax,%eax
    9eb5:	eb ce                	jmp    9e85 <RtStrnCpy+0x35>
    9eb7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    9ebe:	00 00 

0000000000009ec0 <RtStpCpy>:
    9ec0:	f3 0f 1e fa          	endbr64
    9ec4:	0f b7 16             	movzwl (%rsi),%edx
    9ec7:	48 89 f8             	mov    %rdi,%rax
    9eca:	66 85 d2             	test   %dx,%dx
    9ecd:	74 14                	je     9ee3 <RtStpCpy+0x23>
    9ecf:	90                   	nop
    9ed0:	48 83 c6 02          	add    $0x2,%rsi
    9ed4:	66 89 10             	mov    %dx,(%rax)
    9ed7:	48 83 c0 02          	add    $0x2,%rax
    9edb:	0f b7 16             	movzwl (%rsi),%edx
    9ede:	66 85 d2             	test   %dx,%dx
    9ee1:	75 ed                	jne    9ed0 <RtStpCpy+0x10>
    9ee3:	31 d2                	xor    %edx,%edx
    9ee5:	66 89 10             	mov    %dx,(%rax)
    9ee8:	c3                   	ret
    9ee9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009ef0 <RtStpnCpy>:
    9ef0:	f3 0f 1e fa          	endbr64
    9ef4:	41 56                	push   %r14
    9ef6:	41 55                	push   %r13
    9ef8:	41 54                	push   %r12
    9efa:	49 89 fc             	mov    %rdi,%r12
    9efd:	55                   	push   %rbp
    9efe:	48 89 f5             	mov    %rsi,%rbp
    9f01:	48 83 ec 08          	sub    $0x8,%rsp
    9f05:	66 83 3e 00          	cmpw   $0x0,(%rsi)
    9f09:	74 5d                	je     9f68 <RtStpnCpy+0x78>
    9f0b:	48 85 d2             	test   %rdx,%rdx
    9f0e:	74 58                	je     9f68 <RtStpnCpy+0x78>
    9f10:	31 c0                	xor    %eax,%eax
    9f12:	eb 09                	jmp    9f1d <RtStpnCpy+0x2d>
    9f14:	0f 1f 40 00          	nopl   0x0(%rax)
    9f18:	48 39 c2             	cmp    %rax,%rdx
    9f1b:	76 0c                	jbe    9f29 <RtStpnCpy+0x39>
    9f1d:	48 83 c0 01          	add    $0x1,%rax
    9f21:	66 83 7c 45 00 00    	cmpw   $0x0,0x0(%rbp,%rax,2)
    9f27:	75 ef                	jne    9f18 <RtStpnCpy+0x28>
    9f29:	4c 8d 2c 00          	lea    (%rax,%rax,1),%r13
    9f2d:	4f 8d 34 2c          	lea    (%r12,%r13,1),%r14
    9f31:	48 39 c2             	cmp    %rax,%rdx
    9f34:	74 11                	je     9f47 <RtStpnCpy+0x57>
    9f36:	48 29 c2             	sub    %rax,%rdx
    9f39:	4c 89 f7             	mov    %r14,%rdi
    9f3c:	48 8d 34 12          	lea    (%rdx,%rdx,1),%rsi
    9f40:	31 d2                	xor    %edx,%edx
    9f42:	e8 79 fd ff ff       	call   9cc0 <RtSetMem>
    9f47:	4c 89 ea             	mov    %r13,%rdx
    9f4a:	48 89 ee             	mov    %rbp,%rsi
    9f4d:	4c 89 e7             	mov    %r12,%rdi
    9f50:	e8 8b fd ff ff       	call   9ce0 <RtCopyMem>
    9f55:	48 83 c4 08          	add    $0x8,%rsp
    9f59:	4c 89 f0             	mov    %r14,%rax
    9f5c:	5d                   	pop    %rbp
    9f5d:	41 5c                	pop    %r12
    9f5f:	41 5d                	pop    %r13
    9f61:	41 5e                	pop    %r14
    9f63:	c3                   	ret
    9f64:	0f 1f 40 00          	nopl   0x0(%rax)
    9f68:	4d 89 e6             	mov    %r12,%r14
    9f6b:	45 31 ed             	xor    %r13d,%r13d
    9f6e:	31 c0                	xor    %eax,%eax
    9f70:	eb bf                	jmp    9f31 <RtStpnCpy+0x41>
    9f72:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9f79:	00 00 00 00 
    9f7d:	0f 1f 00             	nopl   (%rax)

0000000000009f80 <RtStrCat>:
    9f80:	f3 0f 1e fa          	endbr64
    9f84:	66 83 3f 00          	cmpw   $0x0,(%rdi)
    9f88:	74 31                	je     9fbb <RtStrCat+0x3b>
    9f8a:	31 c0                	xor    %eax,%eax
    9f8c:	0f 1f 40 00          	nopl   0x0(%rax)
    9f90:	48 83 c0 01          	add    $0x1,%rax
    9f94:	66 83 3c 47 00       	cmpw   $0x0,(%rdi,%rax,2)
    9f99:	75 f5                	jne    9f90 <RtStrCat+0x10>
    9f9b:	48 8d 3c 47          	lea    (%rdi,%rax,2),%rdi
    9f9f:	0f b7 06             	movzwl (%rsi),%eax
    9fa2:	66 85 c0             	test   %ax,%ax
    9fa5:	74 1c                	je     9fc3 <RtStrCat+0x43>
    9fa7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    9fae:	00 00 
    9fb0:	66 89 07             	mov    %ax,(%rdi)
    9fb3:	48 83 c7 02          	add    $0x2,%rdi
    9fb7:	48 83 c6 02          	add    $0x2,%rsi
    9fbb:	0f b7 06             	movzwl (%rsi),%eax
    9fbe:	66 85 c0             	test   %ax,%ax
    9fc1:	75 ed                	jne    9fb0 <RtStrCat+0x30>
    9fc3:	31 c0                	xor    %eax,%eax
    9fc5:	66 89 07             	mov    %ax,(%rdi)
    9fc8:	c3                   	ret
    9fc9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000009fd0 <RtStrnCat>:
    9fd0:	f3 0f 1e fa          	endbr64
    9fd4:	53                   	push   %rbx
    9fd5:	66 83 3f 00          	cmpw   $0x0,(%rdi)
    9fd9:	74 55                	je     a030 <RtStrnCat+0x60>
    9fdb:	31 c9                	xor    %ecx,%ecx
    9fdd:	0f 1f 00             	nopl   (%rax)
    9fe0:	48 83 c1 01          	add    $0x1,%rcx
    9fe4:	66 83 3c 4f 00       	cmpw   $0x0,(%rdi,%rcx,2)
    9fe9:	75 f5                	jne    9fe0 <RtStrnCat+0x10>
    9feb:	4c 8d 04 4f          	lea    (%rdi,%rcx,2),%r8
    9fef:	66 83 3e 00          	cmpw   $0x0,(%rsi)
    9ff3:	74 4b                	je     a040 <RtStrnCat+0x70>
    9ff5:	48 85 d2             	test   %rdx,%rdx
    9ff8:	74 46                	je     a040 <RtStrnCat+0x70>
    9ffa:	31 c0                	xor    %eax,%eax
    9ffc:	eb 07                	jmp    a005 <RtStrnCat+0x35>
    9ffe:	66 90                	xchg   %ax,%ax
    a000:	48 39 c2             	cmp    %rax,%rdx
    a003:	76 0b                	jbe    a010 <RtStrnCat+0x40>
    a005:	48 83 c0 01          	add    $0x1,%rax
    a009:	66 83 3c 46 00       	cmpw   $0x0,(%rsi,%rax,2)
    a00e:	75 f0                	jne    a000 <RtStrnCat+0x30>
    a010:	48 8d 14 00          	lea    (%rax,%rax,1),%rdx
    a014:	48 01 c8             	add    %rcx,%rax
    a017:	48 8d 1c 47          	lea    (%rdi,%rax,2),%rbx
    a01b:	4c 89 c7             	mov    %r8,%rdi
    a01e:	e8 bd fc ff ff       	call   9ce0 <RtCopyMem>
    a023:	31 c0                	xor    %eax,%eax
    a025:	66 89 03             	mov    %ax,(%rbx)
    a028:	5b                   	pop    %rbx
    a029:	c3                   	ret
    a02a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a030:	49 89 f8             	mov    %rdi,%r8
    a033:	31 c9                	xor    %ecx,%ecx
    a035:	eb b8                	jmp    9fef <RtStrnCat+0x1f>
    a037:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    a03e:	00 00 
    a040:	31 d2                	xor    %edx,%edx
    a042:	4c 89 c7             	mov    %r8,%rdi
    a045:	4c 89 c3             	mov    %r8,%rbx
    a048:	e8 93 fc ff ff       	call   9ce0 <RtCopyMem>
    a04d:	31 c0                	xor    %eax,%eax
    a04f:	66 89 03             	mov    %ax,(%rbx)
    a052:	5b                   	pop    %rbx
    a053:	c3                   	ret
    a054:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a05b:	00 00 00 00 
    a05f:	90                   	nop

000000000000a060 <RtStrLen>:
    a060:	f3 0f 1e fa          	endbr64
    a064:	31 c0                	xor    %eax,%eax
    a066:	66 83 3f 00          	cmpw   $0x0,(%rdi)
    a06a:	74 14                	je     a080 <RtStrLen+0x20>
    a06c:	0f 1f 40 00          	nopl   0x0(%rax)
    a070:	48 83 c0 01          	add    $0x1,%rax
    a074:	66 83 3c 47 00       	cmpw   $0x0,(%rdi,%rax,2)
    a079:	75 f5                	jne    a070 <RtStrLen+0x10>
    a07b:	c3                   	ret
    a07c:	0f 1f 40 00          	nopl   0x0(%rax)
    a080:	c3                   	ret
    a081:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a088:	00 00 00 00 
    a08c:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000a090 <RtStrnLen>:
    a090:	f3 0f 1e fa          	endbr64
    a094:	31 c0                	xor    %eax,%eax
    a096:	66 83 3f 00          	cmpw   $0x0,(%rdi)
    a09a:	74 1c                	je     a0b8 <RtStrnLen+0x28>
    a09c:	48 85 f6             	test   %rsi,%rsi
    a09f:	75 0c                	jne    a0ad <RtStrnLen+0x1d>
    a0a1:	eb 15                	jmp    a0b8 <RtStrnLen+0x28>
    a0a3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a0a8:	48 39 c6             	cmp    %rax,%rsi
    a0ab:	76 13                	jbe    a0c0 <RtStrnLen+0x30>
    a0ad:	48 83 c0 01          	add    $0x1,%rax
    a0b1:	66 83 3c 47 00       	cmpw   $0x0,(%rdi,%rax,2)
    a0b6:	75 f0                	jne    a0a8 <RtStrnLen+0x18>
    a0b8:	c3                   	ret
    a0b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a0c0:	c3                   	ret
    a0c1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a0c8:	00 00 00 00 
    a0cc:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000a0d0 <RtStrSize>:
    a0d0:	f3 0f 1e fa          	endbr64
    a0d4:	66 83 3f 00          	cmpw   $0x0,(%rdi)
    a0d8:	74 1e                	je     a0f8 <RtStrSize+0x28>
    a0da:	31 c0                	xor    %eax,%eax
    a0dc:	0f 1f 40 00          	nopl   0x0(%rax)
    a0e0:	48 89 c2             	mov    %rax,%rdx
    a0e3:	48 83 c0 01          	add    $0x1,%rax
    a0e7:	66 83 3c 47 00       	cmpw   $0x0,(%rdi,%rax,2)
    a0ec:	75 f2                	jne    a0e0 <RtStrSize+0x10>
    a0ee:	48 8d 44 12 04       	lea    0x4(%rdx,%rdx,1),%rax
    a0f3:	c3                   	ret
    a0f4:	0f 1f 40 00          	nopl   0x0(%rax)
    a0f8:	b8 02 00 00 00       	mov    $0x2,%eax
    a0fd:	c3                   	ret
    a0fe:	66 90                	xchg   %ax,%ax

000000000000a100 <RtBCDtoDecimal>:
    a100:	f3 0f 1e fa          	endbr64
    a104:	89 f8                	mov    %edi,%eax
    a106:	83 e7 0f             	and    $0xf,%edi
    a109:	c0 e8 04             	shr    $0x4,%al
    a10c:	8d 04 80             	lea    (%rax,%rax,4),%eax
    a10f:	8d 04 47             	lea    (%rdi,%rax,2),%eax
    a112:	c3                   	ret
    a113:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a11a:	00 00 00 00 
    a11e:	66 90                	xchg   %ax,%ax

000000000000a120 <RtDecimaltoBCD>:
    a120:	f3 0f 1e fa          	endbr64
    a124:	b8 cd ff ff ff       	mov    $0xffffffcd,%eax
    a129:	40 f6 e7             	mul    %dil
    a12c:	40 0f b6 ff          	movzbl %dil,%edi
    a130:	66 c1 e8 0b          	shr    $0xb,%ax
    a134:	0f b6 d0             	movzbl %al,%edx
    a137:	c1 e0 04             	shl    $0x4,%eax
    a13a:	48 8d 14 92          	lea    (%rdx,%rdx,4),%rdx
    a13e:	48 01 d2             	add    %rdx,%rdx
    a141:	48 29 d7             	sub    %rdx,%rdi
    a144:	01 f8                	add    %edi,%eax
    a146:	c3                   	ret
    a147:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    a14e:	00 00 

000000000000a150 <InitializeLibPlatform>:
    a150:	f3 0f 1e fa          	endbr64
    a154:	c3                   	ret
    a155:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a15c:	00 00 00 
    a15f:	90                   	nop

000000000000a160 <LShiftU64>:
    a160:	f3 0f 1e fa          	endbr64
    a164:	48 89 f8             	mov    %rdi,%rax
    a167:	89 f1                	mov    %esi,%ecx
    a169:	48 d3 e0             	shl    %cl,%rax
    a16c:	c3                   	ret
    a16d:	0f 1f 00             	nopl   (%rax)

000000000000a170 <RShiftU64>:
    a170:	f3 0f 1e fa          	endbr64
    a174:	48 89 f8             	mov    %rdi,%rax
    a177:	89 f1                	mov    %esi,%ecx
    a179:	48 d3 e8             	shr    %cl,%rax
    a17c:	c3                   	ret
    a17d:	0f 1f 00             	nopl   (%rax)

000000000000a180 <MultU64x32>:
    a180:	f3 0f 1e fa          	endbr64
    a184:	48 89 f8             	mov    %rdi,%rax
    a187:	48 0f af c6          	imul   %rsi,%rax
    a18b:	c3                   	ret
    a18c:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000a190 <DivU64x32>:
    a190:	f3 0f 1e fa          	endbr64
    a194:	48 89 d1             	mov    %rdx,%rcx
    a197:	48 85 d2             	test   %rdx,%rdx
    a19a:	74 0b                	je     a1a7 <DivU64x32+0x17>
    a19c:	48 89 f8             	mov    %rdi,%rax
    a19f:	31 d2                	xor    %edx,%edx
    a1a1:	48 f7 f6             	div    %rsi
    a1a4:	48 89 11             	mov    %rdx,(%rcx)
    a1a7:	48 89 f8             	mov    %rdi,%rax
    a1aa:	31 d2                	xor    %edx,%edx
    a1ac:	48 f7 f6             	div    %rsi
    a1af:	c3                   	ret

000000000000a1b0 <Output>:
    a1b0:	f3 0f 1e fa          	endbr64
    a1b4:	48 83 ec 28          	sub    $0x28,%rsp
    a1b8:	48 8b 05 19 30 01 00 	mov    0x13019(%rip),%rax        # 1d1d8 <ST>
    a1bf:	48 89 fa             	mov    %rdi,%rdx
    a1c2:	48 8b 40 40          	mov    0x40(%rax),%rax
    a1c6:	48 89 c1             	mov    %rax,%rcx
    a1c9:	ff 50 08             	call   *0x8(%rax)
    a1cc:	48 83 c4 28          	add    $0x28,%rsp
    a1d0:	c3                   	ret
    a1d1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a1d8:	00 00 00 00 
    a1dc:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000a1e0 <IInput>:
    a1e0:	f3 0f 1e fa          	endbr64
    a1e4:	41 57                	push   %r15
    a1e6:	49 89 f7             	mov    %rsi,%r15
    a1e9:	41 56                	push   %r14
    a1eb:	4d 89 c6             	mov    %r8,%r14
    a1ee:	41 55                	push   %r13
    a1f0:	49 89 cd             	mov    %rcx,%r13
    a1f3:	41 54                	push   %r12
    a1f5:	49 89 fc             	mov    %rdi,%r12
    a1f8:	55                   	push   %rbp
    a1f9:	53                   	push   %rbx
    a1fa:	48 83 ec 38          	sub    $0x38,%rsp
    a1fe:	48 85 d2             	test   %rdx,%rdx
    a201:	74 06                	je     a209 <IInput+0x29>
    a203:	48 89 f9             	mov    %rdi,%rcx
    a206:	ff 57 08             	call   *0x8(%rdi)
    a209:	31 db                	xor    %ebx,%ebx
    a20b:	48 8d 6c 24 2c       	lea    0x2c(%rsp),%rbp
    a210:	49 8b 7f 10          	mov    0x10(%r15),%rdi
    a214:	31 f6                	xor    %esi,%esi
    a216:	e8 e5 18 00 00       	call   bb00 <WaitForSingleEvent>
    a21b:	48 89 ea             	mov    %rbp,%rdx
    a21e:	4c 89 f9             	mov    %r15,%rcx
    a221:	41 ff 57 08          	call   *0x8(%r15)
    a225:	48 85 c0             	test   %rax,%rax
    a228:	78 6e                	js     a298 <IInput+0xb8>
    a22a:	0f b7 44 24 2e       	movzwl 0x2e(%rsp),%eax
    a22f:	66 83 f8 0a          	cmp    $0xa,%ax
    a233:	74 63                	je     a298 <IInput+0xb8>
    a235:	66 83 f8 0d          	cmp    $0xd,%ax
    a239:	74 5d                	je     a298 <IInput+0xb8>
    a23b:	66 83 f8 08          	cmp    $0x8,%ax
    a23f:	74 37                	je     a278 <IInput+0x98>
    a241:	66 83 f8 1f          	cmp    $0x1f,%ax
    a245:	76 c9                	jbe    a210 <IInput+0x30>
    a247:	49 8d 56 ff          	lea    -0x1(%r14),%rdx
    a24b:	48 39 da             	cmp    %rbx,%rdx
    a24e:	76 c0                	jbe    a210 <IInput+0x30>
    a250:	48 8d 0c 1b          	lea    (%rbx,%rbx,1),%rcx
    a254:	31 f6                	xor    %esi,%esi
    a256:	48 83 c3 01          	add    $0x1,%rbx
    a25a:	49 8d 54 0d 00       	lea    0x0(%r13,%rcx,1),%rdx
    a25f:	66 89 02             	mov    %ax,(%rdx)
    a262:	66 41 89 74 0d 02    	mov    %si,0x2(%r13,%rcx,1)
    a268:	4c 89 e1             	mov    %r12,%rcx
    a26b:	41 ff 54 24 08       	call   *0x8(%r12)
    a270:	eb 9e                	jmp    a210 <IInput+0x30>
    a272:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    a278:	48 85 db             	test   %rbx,%rbx
    a27b:	74 93                	je     a210 <IInput+0x30>
    a27d:	48 8d 15 10 b1 00 00 	lea    0xb110(%rip),%rdx        # 15394 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x594>
    a284:	4c 89 e1             	mov    %r12,%rcx
    a287:	48 83 eb 01          	sub    $0x1,%rbx
    a28b:	41 ff 54 24 08       	call   *0x8(%r12)
    a290:	e9 7b ff ff ff       	jmp    a210 <IInput+0x30>
    a295:	0f 1f 00             	nopl   (%rax)
    a298:	31 c0                	xor    %eax,%eax
    a29a:	66 41 89 44 5d 00    	mov    %ax,0x0(%r13,%rbx,2)
    a2a0:	48 83 c4 38          	add    $0x38,%rsp
    a2a4:	5b                   	pop    %rbx
    a2a5:	5d                   	pop    %rbp
    a2a6:	41 5c                	pop    %r12
    a2a8:	41 5d                	pop    %r13
    a2aa:	41 5e                	pop    %r14
    a2ac:	41 5f                	pop    %r15
    a2ae:	c3                   	ret
    a2af:	90                   	nop

000000000000a2b0 <Input>:
    a2b0:	f3 0f 1e fa          	endbr64
    a2b4:	48 8b 05 1d 2f 01 00 	mov    0x12f1d(%rip),%rax        # 1d1d8 <ST>
    a2bb:	49 89 f9             	mov    %rdi,%r9
    a2be:	48 89 f1             	mov    %rsi,%rcx
    a2c1:	49 89 d0             	mov    %rdx,%r8
    a2c4:	4c 89 ca             	mov    %r9,%rdx
    a2c7:	48 8b 70 30          	mov    0x30(%rax),%rsi
    a2cb:	48 8b 78 40          	mov    0x40(%rax),%rdi
    a2cf:	e9 0c ff ff ff       	jmp    a1e0 <IInput>
    a2d4:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a2db:	00 00 00 
    a2de:	66 90                	xchg   %ax,%ax

000000000000a2e0 <_DevPathEndInstance>:
    a2e0:	f3 0f 1e fa          	endbr64
    a2e4:	48 8d 35 b5 b0 00 00 	lea    0xb0b5(%rip),%rsi        # 153a0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5a0>
    a2eb:	31 c0                	xor    %eax,%eax
    a2ed:	e9 de e9 ff ff       	jmp    8cd0 <CatPrint>
    a2f2:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a2f9:	00 00 00 00 
    a2fd:	0f 1f 00             	nopl   (%rax)

000000000000a300 <_DevPathBssBss>:
    a300:	f3 0f 1e fa          	endbr64
    a304:	66 83 7e 04 06       	cmpw   $0x6,0x4(%rsi)
    a309:	77 7e                	ja     a389 <_DevPathBssBss+0x89>
    a30b:	0f b7 46 04          	movzwl 0x4(%rsi),%eax
    a30f:	48 8d 15 f6 b0 00 00 	lea    0xb0f6(%rip),%rdx        # 1540c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x60c>
    a316:	48 63 04 82          	movslq (%rdx,%rax,4),%rax
    a31a:	48 01 d0             	add    %rdx,%rax
    a31d:	3e ff e0             	notrack jmp *%rax
    a320:	48 8d 15 8b b0 00 00 	lea    0xb08b(%rip),%rdx        # 153b2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5b2>
    a327:	48 8d 4e 08          	lea    0x8(%rsi),%rcx
    a32b:	31 c0                	xor    %eax,%eax
    a32d:	48 8d 35 c0 b0 00 00 	lea    0xb0c0(%rip),%rsi        # 153f4 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5f4>
    a334:	e9 97 e9 ff ff       	jmp    8cd0 <CatPrint>
    a339:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a340:	48 8d 15 5d b0 00 00 	lea    0xb05d(%rip),%rdx        # 153a4 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5a4>
    a347:	eb de                	jmp    a327 <_DevPathBssBss+0x27>
    a349:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a350:	48 8d 15 91 b0 00 00 	lea    0xb091(%rip),%rdx        # 153e8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5e8>
    a357:	eb ce                	jmp    a327 <_DevPathBssBss+0x27>
    a359:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a360:	48 8d 15 5f b0 00 00 	lea    0xb05f(%rip),%rdx        # 153c6 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5c6>
    a367:	eb be                	jmp    a327 <_DevPathBssBss+0x27>
    a369:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a370:	48 8d 15 5b b0 00 00 	lea    0xb05b(%rip),%rdx        # 153d2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5d2>
    a377:	eb ae                	jmp    a327 <_DevPathBssBss+0x27>
    a379:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a380:	48 8d 15 59 b0 00 00 	lea    0xb059(%rip),%rdx        # 153e0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5e0>
    a387:	eb 9e                	jmp    a327 <_DevPathBssBss+0x27>
    a389:	48 8d 15 60 b0 00 00 	lea    0xb060(%rip),%rdx        # 153f0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5f0>
    a390:	eb 95                	jmp    a327 <_DevPathBssBss+0x27>
    a392:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a399:	00 00 00 00 
    a39d:	0f 1f 00             	nopl   (%rax)

000000000000a3a0 <_DevPathMediaProtocol>:
    a3a0:	f3 0f 1e fa          	endbr64
    a3a4:	48 8d 56 04          	lea    0x4(%rsi),%rdx
    a3a8:	31 c0                	xor    %eax,%eax
    a3aa:	48 8d 35 77 b0 00 00 	lea    0xb077(%rip),%rsi        # 15428 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x628>
    a3b1:	e9 1a e9 ff ff       	jmp    8cd0 <CatPrint>
    a3b6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a3bd:	00 00 00 

000000000000a3c0 <_DevPathFilePath>:
    a3c0:	f3 0f 1e fa          	endbr64
    a3c4:	48 8d 56 04          	lea    0x4(%rsi),%rdx
    a3c8:	31 c0                	xor    %eax,%eax
    a3ca:	48 8d 35 5d b0 00 00 	lea    0xb05d(%rip),%rsi        # 1542e <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x62e>
    a3d1:	e9 fa e8 ff ff       	jmp    8cd0 <CatPrint>
    a3d6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a3dd:	00 00 00 

000000000000a3e0 <_DevPathCDROM>:
    a3e0:	f3 0f 1e fa          	endbr64
    a3e4:	8b 56 04             	mov    0x4(%rsi),%edx
    a3e7:	31 c0                	xor    %eax,%eax
    a3e9:	48 8d 35 44 b0 00 00 	lea    0xb044(%rip),%rsi        # 15434 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x634>
    a3f0:	e9 db e8 ff ff       	jmp    8cd0 <CatPrint>
    a3f5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a3fc:	00 00 00 00 

000000000000a400 <_DevPathSata>:
    a400:	f3 0f 1e fa          	endbr64
    a404:	0f b7 4e 06          	movzwl 0x6(%rsi),%ecx
    a408:	0f b7 56 04          	movzwl 0x4(%rsi),%edx
    a40c:	31 c0                	xor    %eax,%eax
    a40e:	44 0f b7 46 08       	movzwl 0x8(%rsi),%r8d
    a413:	48 8d 35 36 b0 00 00 	lea    0xb036(%rip),%rsi        # 15450 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x650>
    a41a:	e9 b1 e8 ff ff       	jmp    8cd0 <CatPrint>
    a41f:	90                   	nop

000000000000a420 <_DevPathUart>:
    a420:	f3 0f 1e fa          	endbr64
    a424:	41 54                	push   %r12
    a426:	41 bc 78 00 00 00    	mov    $0x78,%r12d
    a42c:	55                   	push   %rbp
    a42d:	48 89 fd             	mov    %rdi,%rbp
    a430:	53                   	push   %rbx
    a431:	0f b6 46 11          	movzbl 0x11(%rsi),%eax
    a435:	48 89 f3             	mov    %rsi,%rbx
    a438:	3c 05                	cmp    $0x5,%al
    a43a:	77 0c                	ja     a448 <_DevPathUart+0x28>
    a43c:	48 8d 15 b1 b5 00 00 	lea    0xb5b1(%rip),%rdx        # 159f4 <CSWTCH.43>
    a443:	44 0f b6 24 02       	movzbl (%rdx,%rax,1),%r12d
    a448:	48 8b 53 08          	mov    0x8(%rbx),%rdx
    a44c:	48 85 d2             	test   %rdx,%rdx
    a44f:	0f 85 9b 00 00 00    	jne    a4f0 <_DevPathUart+0xd0>
    a455:	48 8d 35 1e b0 00 00 	lea    0xb01e(%rip),%rsi        # 1547a <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x67a>
    a45c:	48 89 ef             	mov    %rbp,%rdi
    a45f:	31 c0                	xor    %eax,%eax
    a461:	e8 6a e8 ff ff       	call   8cd0 <CatPrint>
    a466:	0f b6 53 10          	movzbl 0x10(%rbx),%edx
    a46a:	84 d2                	test   %dl,%dl
    a46c:	0f 85 9b 00 00 00    	jne    a50d <_DevPathUart+0xed>
    a472:	48 8d 35 31 b0 00 00 	lea    0xb031(%rip),%rsi        # 154aa <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6aa>
    a479:	48 89 ef             	mov    %rbp,%rdi
    a47c:	31 c0                	xor    %eax,%eax
    a47e:	e8 4d e8 ff ff       	call   8cd0 <CatPrint>
    a483:	48 8d 35 3a b0 00 00 	lea    0xb03a(%rip),%rsi        # 154c4 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6c4>
    a48a:	44 89 e2             	mov    %r12d,%edx
    a48d:	48 89 ef             	mov    %rbp,%rdi
    a490:	31 c0                	xor    %eax,%eax
    a492:	e8 39 e8 ff ff       	call   8cd0 <CatPrint>
    a497:	0f b6 43 12          	movzbl 0x12(%rbx),%eax
    a49b:	48 8d 35 36 b0 00 00 	lea    0xb036(%rip),%rsi        # 154d8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6d8>
    a4a2:	3c 02                	cmp    $0x2,%al
    a4a4:	74 0d                	je     a4b3 <_DevPathUart+0x93>
    a4a6:	77 20                	ja     a4c8 <_DevPathUart+0xa8>
    a4a8:	48 8d 35 23 b0 00 00 	lea    0xb023(%rip),%rsi        # 154d2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6d2>
    a4af:	84 c0                	test   %al,%al
    a4b1:	74 75                	je     a528 <_DevPathUart+0x108>
    a4b3:	5b                   	pop    %rbx
    a4b4:	48 89 ef             	mov    %rbp,%rdi
    a4b7:	31 c0                	xor    %eax,%eax
    a4b9:	5d                   	pop    %rbp
    a4ba:	41 5c                	pop    %r12
    a4bc:	e9 0f e8 ff ff       	jmp    8cd0 <CatPrint>
    a4c1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a4c8:	48 8d 35 13 b0 00 00 	lea    0xb013(%rip),%rsi        # 154e2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6e2>
    a4cf:	3c 03                	cmp    $0x3,%al
    a4d1:	74 e0                	je     a4b3 <_DevPathUart+0x93>
    a4d3:	5b                   	pop    %rbx
    a4d4:	48 89 ef             	mov    %rbp,%rdi
    a4d7:	48 8d 35 0a b0 00 00 	lea    0xb00a(%rip),%rsi        # 154e8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6e8>
    a4de:	5d                   	pop    %rbp
    a4df:	31 c0                	xor    %eax,%eax
    a4e1:	41 5c                	pop    %r12
    a4e3:	e9 e8 e7 ff ff       	jmp    8cd0 <CatPrint>
    a4e8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    a4ef:	00 
    a4f0:	48 8d 35 9f af 00 00 	lea    0xaf9f(%rip),%rsi        # 15496 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x696>
    a4f7:	48 89 ef             	mov    %rbp,%rdi
    a4fa:	31 c0                	xor    %eax,%eax
    a4fc:	e8 cf e7 ff ff       	call   8cd0 <CatPrint>
    a501:	0f b6 53 10          	movzbl 0x10(%rbx),%edx
    a505:	84 d2                	test   %dl,%dl
    a507:	0f 84 65 ff ff ff    	je     a472 <_DevPathUart+0x52>
    a50d:	48 8d 35 a8 af 00 00 	lea    0xafa8(%rip),%rsi        # 154bc <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6bc>
    a514:	48 89 ef             	mov    %rbp,%rdi
    a517:	31 c0                	xor    %eax,%eax
    a519:	e8 b2 e7 ff ff       	call   8cd0 <CatPrint>
    a51e:	e9 60 ff ff ff       	jmp    a483 <_DevPathUart+0x63>
    a523:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a528:	5b                   	pop    %rbx
    a529:	48 89 ef             	mov    %rbp,%rdi
    a52c:	48 8d 35 99 af 00 00 	lea    0xaf99(%rip),%rsi        # 154cc <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6cc>
    a533:	5d                   	pop    %rbp
    a534:	31 c0                	xor    %eax,%eax
    a536:	41 5c                	pop    %r12
    a538:	e9 93 e7 ff ff       	jmp    8cd0 <CatPrint>
    a53d:	0f 1f 00             	nopl   (%rax)

000000000000a540 <_DevPathInfiniBand>:
    a540:	f3 0f 1e fa          	endbr64
    a544:	48 83 ec 18          	sub    $0x18,%rsp
    a548:	48 8b 46 28          	mov    0x28(%rsi),%rax
    a54c:	8b 56 04             	mov    0x4(%rsi),%edx
    a54f:	48 8d 4e 08          	lea    0x8(%rsi),%rcx
    a553:	48 89 04 24          	mov    %rax,(%rsp)
    a557:	4c 8b 4e 20          	mov    0x20(%rsi),%r9
    a55b:	31 c0                	xor    %eax,%eax
    a55d:	4c 8b 46 18          	mov    0x18(%rsi),%r8
    a561:	48 8d 35 88 af 00 00 	lea    0xaf88(%rip),%rsi        # 154f0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x6f0>
    a568:	e8 63 e7 ff ff       	call   8cd0 <CatPrint>
    a56d:	48 83 c4 18          	add    $0x18,%rsp
    a571:	c3                   	ret
    a572:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a579:	00 00 00 00 
    a57d:	0f 1f 00             	nopl   (%rax)

000000000000a580 <_DevPathUri>:
    a580:	f3 0f 1e fa          	endbr64
    a584:	48 8d 56 04          	lea    0x4(%rsi),%rdx
    a588:	31 c0                	xor    %eax,%eax
    a58a:	48 8d 35 ab af 00 00 	lea    0xafab(%rip),%rsi        # 1553c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x73c>
    a591:	e9 3a e7 ff ff       	jmp    8cd0 <CatPrint>
    a596:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a59d:	00 00 00 

000000000000a5a0 <_DevPathMacAddr>:
    a5a0:	f3 0f 1e fa          	endbr64
    a5a4:	41 56                	push   %r14
    a5a6:	41 55                	push   %r13
    a5a8:	41 54                	push   %r12
    a5aa:	49 89 fc             	mov    %rdi,%r12
    a5ad:	55                   	push   %rbp
    a5ae:	48 89 f5             	mov    %rsi,%rbp
    a5b1:	53                   	push   %rbx
    a5b2:	80 7e 24 01          	cmpb   $0x1,0x24(%rsi)
    a5b6:	0f b7 46 02          	movzwl 0x2(%rsi),%eax
    a5ba:	76 64                	jbe    a620 <_DevPathMacAddr+0x80>
    a5bc:	4c 8d 70 fb          	lea    -0x5(%rax),%r14
    a5c0:	48 8d 35 85 af 00 00 	lea    0xaf85(%rip),%rsi        # 1554c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x74c>
    a5c7:	31 c0                	xor    %eax,%eax
    a5c9:	e8 02 e7 ff ff       	call   8cd0 <CatPrint>
    a5ce:	4d 85 f6             	test   %r14,%r14
    a5d1:	74 28                	je     a5fb <_DevPathMacAddr+0x5b>
    a5d3:	31 db                	xor    %ebx,%ebx
    a5d5:	4c 8d 2d 7a af 00 00 	lea    0xaf7a(%rip),%r13        # 15556 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x756>
    a5dc:	0f 1f 40 00          	nopl   0x0(%rax)
    a5e0:	0f b6 54 1d 04       	movzbl 0x4(%rbp,%rbx,1),%edx
    a5e5:	4c 89 ee             	mov    %r13,%rsi
    a5e8:	4c 89 e7             	mov    %r12,%rdi
    a5eb:	31 c0                	xor    %eax,%eax
    a5ed:	48 83 c3 01          	add    $0x1,%rbx
    a5f1:	e8 da e6 ff ff       	call   8cd0 <CatPrint>
    a5f6:	4c 39 f3             	cmp    %r14,%rbx
    a5f9:	72 e5                	jb     a5e0 <_DevPathMacAddr+0x40>
    a5fb:	0f b6 55 24          	movzbl 0x24(%rbp),%edx
    a5ff:	84 d2                	test   %dl,%dl
    a601:	75 3d                	jne    a640 <_DevPathMacAddr+0xa0>
    a603:	5b                   	pop    %rbx
    a604:	4c 89 e7             	mov    %r12,%rdi
    a607:	5d                   	pop    %rbp
    a608:	31 c0                	xor    %eax,%eax
    a60a:	41 5c                	pop    %r12
    a60c:	48 8d 35 55 af 00 00 	lea    0xaf55(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    a613:	41 5d                	pop    %r13
    a615:	41 5e                	pop    %r14
    a617:	e9 b4 e6 ff ff       	jmp    8cd0 <CatPrint>
    a61c:	0f 1f 40 00          	nopl   0x0(%rax)
    a620:	48 8d 35 25 af 00 00 	lea    0xaf25(%rip),%rsi        # 1554c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x74c>
    a627:	31 c0                	xor    %eax,%eax
    a629:	41 be 06 00 00 00    	mov    $0x6,%r14d
    a62f:	e8 9c e6 ff ff       	call   8cd0 <CatPrint>
    a634:	eb 9d                	jmp    a5d3 <_DevPathMacAddr+0x33>
    a636:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a63d:	00 00 00 
    a640:	48 8d 35 19 af 00 00 	lea    0xaf19(%rip),%rsi        # 15560 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x760>
    a647:	4c 89 e7             	mov    %r12,%rdi
    a64a:	31 c0                	xor    %eax,%eax
    a64c:	e8 7f e6 ff ff       	call   8cd0 <CatPrint>
    a651:	eb b0                	jmp    a603 <_DevPathMacAddr+0x63>
    a653:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a65a:	00 00 00 00 
    a65e:	66 90                	xchg   %ax,%ax

000000000000a660 <_DevPathI2O>:
    a660:	f3 0f 1e fa          	endbr64
    a664:	8b 56 04             	mov    0x4(%rsi),%edx
    a667:	31 c0                	xor    %eax,%eax
    a669:	48 8d 35 fc ae 00 00 	lea    0xaefc(%rip),%rsi        # 1556c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x76c>
    a670:	e9 5b e6 ff ff       	jmp    8cd0 <CatPrint>
    a675:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a67c:	00 00 00 00 

000000000000a680 <_DevPathUsb>:
    a680:	f3 0f 1e fa          	endbr64
    a684:	0f b6 4e 05          	movzbl 0x5(%rsi),%ecx
    a688:	0f b6 56 04          	movzbl 0x4(%rsi),%edx
    a68c:	31 c0                	xor    %eax,%eax
    a68e:	48 8d 35 eb ae 00 00 	lea    0xaeeb(%rip),%rsi        # 15580 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x780>
    a695:	e9 36 e6 ff ff       	jmp    8cd0 <CatPrint>
    a69a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

000000000000a6a0 <_DevPath1394>:
    a6a0:	f3 0f 1e fa          	endbr64
    a6a4:	48 8b 56 08          	mov    0x8(%rsi),%rdx
    a6a8:	31 c0                	xor    %eax,%eax
    a6aa:	48 8d 35 ed ae 00 00 	lea    0xaeed(%rip),%rsi        # 1559e <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x79e>
    a6b1:	e9 1a e6 ff ff       	jmp    8cd0 <CatPrint>
    a6b6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a6bd:	00 00 00 

000000000000a6c0 <_DevPathFibre>:
    a6c0:	f3 0f 1e fa          	endbr64
    a6c4:	0f b6 06             	movzbl (%rsi),%eax
    a6c7:	48 8d 15 ec ae 00 00 	lea    0xaeec(%rip),%rdx        # 155ba <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x7ba>
    a6ce:	48 8b 4e 08          	mov    0x8(%rsi),%rcx
    a6d2:	4c 8b 46 10          	mov    0x10(%rsi),%r8
    a6d6:	48 8d 35 eb ae 00 00 	lea    0xaeeb(%rip),%rsi        # 155c8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x7c8>
    a6dd:	83 e0 7f             	and    $0x7f,%eax
    a6e0:	3c 03                	cmp    $0x3,%al
    a6e2:	48 8d 05 d3 ae 00 00 	lea    0xaed3(%rip),%rax        # 155bc <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x7bc>
    a6e9:	48 0f 45 d0          	cmovne %rax,%rdx
    a6ed:	31 c0                	xor    %eax,%eax
    a6ef:	e9 dc e5 ff ff       	jmp    8cd0 <CatPrint>
    a6f4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a6fb:	00 00 00 00 
    a6ff:	90                   	nop

000000000000a700 <_DevPathScsi>:
    a700:	f3 0f 1e fa          	endbr64
    a704:	0f b7 4e 06          	movzwl 0x6(%rsi),%ecx
    a708:	0f b7 56 04          	movzwl 0x4(%rsi),%edx
    a70c:	31 c0                	xor    %eax,%eax
    a70e:	48 8d 35 e9 ae 00 00 	lea    0xaee9(%rip),%rsi        # 155fe <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x7fe>
    a715:	e9 b6 e5 ff ff       	jmp    8cd0 <CatPrint>
    a71a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

000000000000a720 <_DevPathAtapi>:
    a720:	f3 0f 1e fa          	endbr64
    a724:	80 7e 05 00          	cmpb   $0x0,0x5(%rsi)
    a728:	48 8d 05 f3 ae 00 00 	lea    0xaef3(%rip),%rax        # 15622 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x822>
    a72f:	48 8d 0d e0 ae 00 00 	lea    0xaee0(%rip),%rcx        # 15616 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x816>
    a736:	48 0f 44 c8          	cmove  %rax,%rcx
    a73a:	48 8d 15 ef ae 00 00 	lea    0xaeef(%rip),%rdx        # 15630 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x830>
    a741:	80 7e 04 00          	cmpb   $0x0,0x4(%rsi)
    a745:	48 8d 05 f8 ae 00 00 	lea    0xaef8(%rip),%rax        # 15644 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x844>
    a74c:	48 8d 35 01 af 00 00 	lea    0xaf01(%rip),%rsi        # 15654 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x854>
    a753:	48 0f 44 d0          	cmove  %rax,%rdx
    a757:	31 c0                	xor    %eax,%eax
    a759:	e9 72 e5 ff ff       	jmp    8cd0 <CatPrint>
    a75e:	66 90                	xchg   %ax,%ax

000000000000a760 <_DevPathAcpi>:
    a760:	f3 0f 1e fa          	endbr64
    a764:	55                   	push   %rbp
    a765:	48 89 fd             	mov    %rdi,%rbp
    a768:	53                   	push   %rbx
    a769:	48 89 f3             	mov    %rsi,%rbx
    a76c:	48 83 ec 08          	sub    $0x8,%rsp
    a770:	8b 56 04             	mov    0x4(%rsi),%edx
    a773:	66 81 fa d0 41       	cmp    $0x41d0,%dx
    a778:	75 7e                	jne    a7f8 <_DevPathAcpi+0x98>
    a77a:	c1 ea 10             	shr    $0x10,%edx
    a77d:	81 fa 04 06 00 00    	cmp    $0x604,%edx
    a783:	0f 84 f7 00 00 00    	je     a880 <_DevPathAcpi+0x120>
    a789:	77 35                	ja     a7c0 <_DevPathAcpi+0x60>
    a78b:	81 fa 01 04 00 00    	cmp    $0x401,%edx
    a791:	0f 84 d9 00 00 00    	je     a870 <_DevPathAcpi+0x110>
    a797:	81 fa 01 05 00 00    	cmp    $0x501,%edx
    a79d:	75 41                	jne    a7e0 <_DevPathAcpi+0x80>
    a79f:	8b 56 08             	mov    0x8(%rsi),%edx
    a7a2:	48 8d 35 01 af 00 00 	lea    0xaf01(%rip),%rsi        # 156aa <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x8aa>
    a7a9:	48 83 c4 08          	add    $0x8,%rsp
    a7ad:	48 89 ef             	mov    %rbp,%rdi
    a7b0:	31 c0                	xor    %eax,%eax
    a7b2:	5b                   	pop    %rbx
    a7b3:	5d                   	pop    %rbp
    a7b4:	e9 17 e5 ff ff       	jmp    8cd0 <CatPrint>
    a7b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a7c0:	81 fa 03 0a 00 00    	cmp    $0xa03,%edx
    a7c6:	74 68                	je     a830 <_DevPathAcpi+0xd0>
    a7c8:	81 fa 08 0a 00 00    	cmp    $0xa08,%edx
    a7ce:	75 70                	jne    a840 <_DevPathAcpi+0xe0>
    a7d0:	8b 56 08             	mov    0x8(%rsi),%edx
    a7d3:	48 8d 35 14 af 00 00 	lea    0xaf14(%rip),%rsi        # 156ee <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x8ee>
    a7da:	eb cd                	jmp    a7a9 <_DevPathAcpi+0x49>
    a7dc:	0f 1f 40 00          	nopl   0x0(%rax)
    a7e0:	81 fa 01 03 00 00    	cmp    $0x301,%edx
    a7e6:	75 58                	jne    a840 <_DevPathAcpi+0xe0>
    a7e8:	8b 56 08             	mov    0x8(%rsi),%edx
    a7eb:	48 8d 35 78 ae 00 00 	lea    0xae78(%rip),%rsi        # 1566a <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x86a>
    a7f2:	eb b5                	jmp    a7a9 <_DevPathAcpi+0x49>
    a7f4:	0f 1f 40 00          	nopl   0x0(%rax)
    a7f8:	48 8d 35 23 af 00 00 	lea    0xaf23(%rip),%rsi        # 15722 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x922>
    a7ff:	31 c0                	xor    %eax,%eax
    a801:	e8 ca e4 ff ff       	call   8cd0 <CatPrint>
    a806:	8b 4b 08             	mov    0x8(%rbx),%ecx
    a809:	85 c9                	test   %ecx,%ecx
    a80b:	0f 85 7f 00 00 00    	jne    a890 <_DevPathAcpi+0x130>
    a811:	8b 53 04             	mov    0x4(%rbx),%edx
    a814:	48 83 c4 08          	add    $0x8,%rsp
    a818:	48 89 ef             	mov    %rbp,%rdi
    a81b:	31 c0                	xor    %eax,%eax
    a81d:	5b                   	pop    %rbx
    a81e:	48 8d 35 43 ad 00 00 	lea    0xad43(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    a825:	5d                   	pop    %rbp
    a826:	e9 a5 e4 ff ff       	jmp    8cd0 <CatPrint>
    a82b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a830:	8b 56 08             	mov    0x8(%rsi),%edx
    a833:	48 8d 35 9c ae 00 00 	lea    0xae9c(%rip),%rsi        # 156d6 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x8d6>
    a83a:	e9 6a ff ff ff       	jmp    a7a9 <_DevPathAcpi+0x49>
    a83f:	90                   	nop
    a840:	48 8d 35 c1 ae 00 00 	lea    0xaec1(%rip),%rsi        # 15708 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x908>
    a847:	48 89 ef             	mov    %rbp,%rdi
    a84a:	31 c0                	xor    %eax,%eax
    a84c:	e8 7f e4 ff ff       	call   8cd0 <CatPrint>
    a851:	8b 53 08             	mov    0x8(%rbx),%edx
    a854:	85 d2                	test   %edx,%edx
    a856:	75 58                	jne    a8b0 <_DevPathAcpi+0x150>
    a858:	48 83 c4 08          	add    $0x8,%rsp
    a85c:	48 89 ef             	mov    %rbp,%rdi
    a85f:	48 8d 35 02 ad 00 00 	lea    0xad02(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    a866:	31 c0                	xor    %eax,%eax
    a868:	5b                   	pop    %rbx
    a869:	5d                   	pop    %rbp
    a86a:	e9 61 e4 ff ff       	jmp    8cd0 <CatPrint>
    a86f:	90                   	nop
    a870:	8b 56 08             	mov    0x8(%rsi),%edx
    a873:	48 8d 35 0e ae 00 00 	lea    0xae0e(%rip),%rsi        # 15688 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x888>
    a87a:	e9 2a ff ff ff       	jmp    a7a9 <_DevPathAcpi+0x49>
    a87f:	90                   	nop
    a880:	8b 56 08             	mov    0x8(%rsi),%edx
    a883:	48 8d 35 36 ae 00 00 	lea    0xae36(%rip),%rsi        # 156c0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x8c0>
    a88a:	e9 1a ff ff ff       	jmp    a7a9 <_DevPathAcpi+0x49>
    a88f:	90                   	nop
    a890:	89 ca                	mov    %ecx,%edx
    a892:	48 8d 35 c7 ac 00 00 	lea    0xacc7(%rip),%rsi        # 15560 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x760>
    a899:	48 89 ef             	mov    %rbp,%rdi
    a89c:	31 c0                	xor    %eax,%eax
    a89e:	e8 2d e4 ff ff       	call   8cd0 <CatPrint>
    a8a3:	8b 4b 08             	mov    0x8(%rbx),%ecx
    a8a6:	e9 66 ff ff ff       	jmp    a811 <_DevPathAcpi+0xb1>
    a8ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    a8b0:	48 8d 35 a9 ac 00 00 	lea    0xaca9(%rip),%rsi        # 15560 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x760>
    a8b7:	48 89 ef             	mov    %rbp,%rdi
    a8ba:	31 c0                	xor    %eax,%eax
    a8bc:	e8 0f e4 ff ff       	call   8cd0 <CatPrint>
    a8c1:	eb 95                	jmp    a858 <_DevPathAcpi+0xf8>
    a8c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a8ca:	00 00 00 00 
    a8ce:	66 90                	xchg   %ax,%ax

000000000000a8d0 <_DevPathController>:
    a8d0:	f3 0f 1e fa          	endbr64
    a8d4:	8b 56 04             	mov    0x4(%rsi),%edx
    a8d7:	31 c0                	xor    %eax,%eax
    a8d9:	48 8d 35 56 ae 00 00 	lea    0xae56(%rip),%rsi        # 15736 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x936>
    a8e0:	e9 eb e3 ff ff       	jmp    8cd0 <CatPrint>
    a8e5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a8ec:	00 00 00 00 

000000000000a8f0 <_DevPathMemMap>:
    a8f0:	f3 0f 1e fa          	endbr64
    a8f4:	48 8b 4e 08          	mov    0x8(%rsi),%rcx
    a8f8:	8b 56 04             	mov    0x4(%rsi),%edx
    a8fb:	31 c0                	xor    %eax,%eax
    a8fd:	4c 8b 46 10          	mov    0x10(%rsi),%r8
    a901:	48 8d 35 40 ae 00 00 	lea    0xae40(%rip),%rsi        # 15748 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x948>
    a908:	e9 c3 e3 ff ff       	jmp    8cd0 <CatPrint>
    a90d:	0f 1f 00             	nopl   (%rax)

000000000000a910 <_DevPathPccard>:
    a910:	f3 0f 1e fa          	endbr64
    a914:	0f b6 56 04          	movzbl 0x4(%rsi),%edx
    a918:	31 c0                	xor    %eax,%eax
    a91a:	48 8d 35 51 ae 00 00 	lea    0xae51(%rip),%rsi        # 15772 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x972>
    a921:	e9 aa e3 ff ff       	jmp    8cd0 <CatPrint>
    a926:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a92d:	00 00 00 

000000000000a930 <_DevPathPci>:
    a930:	f3 0f 1e fa          	endbr64
    a934:	0f b6 4e 04          	movzbl 0x4(%rsi),%ecx
    a938:	0f b6 56 05          	movzbl 0x5(%rsi),%edx
    a93c:	31 c0                	xor    %eax,%eax
    a93e:	48 8d 35 47 ae 00 00 	lea    0xae47(%rip),%rsi        # 1578c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x98c>
    a945:	e9 86 e3 ff ff       	jmp    8cd0 <CatPrint>
    a94a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

000000000000a950 <_DevPathNodeUnknown>:
    a950:	f3 0f 1e fa          	endbr64
    a954:	41 57                	push   %r15
    a956:	49 89 ff             	mov    %rdi,%r15
    a959:	41 56                	push   %r14
    a95b:	41 55                	push   %r13
    a95d:	41 54                	push   %r12
    a95f:	55                   	push   %rbp
    a960:	48 89 f5             	mov    %rsi,%rbp
    a963:	53                   	push   %rbx
    a964:	48 83 ec 08          	sub    $0x8,%rsp
    a968:	0f b6 16             	movzbl (%rsi),%edx
    a96b:	44 0f b6 46 01       	movzbl 0x1(%rsi),%r8d
    a970:	80 fa 05             	cmp    $0x5,%dl
    a973:	0f 87 26 01 00 00    	ja     aa9f <_DevPathNodeUnknown+0x14f>
    a979:	48 8d 0d c4 ae 00 00 	lea    0xaec4(%rip),%rcx        # 15844 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa44>
    a980:	0f b6 c2             	movzbl %dl,%eax
    a983:	48 63 04 81          	movslq (%rcx,%rax,4),%rax
    a987:	48 01 c8             	add    %rcx,%rax
    a98a:	3e ff e0             	notrack jmp *%rax
    a98d:	0f 1f 00             	nopl   (%rax)
    a990:	44 89 c2             	mov    %r8d,%edx
    a993:	48 8d 35 76 ae 00 00 	lea    0xae76(%rip),%rsi        # 15810 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa10>
    a99a:	31 c0                	xor    %eax,%eax
    a99c:	e8 2f e3 ff ff       	call   8cd0 <CatPrint>
    a9a1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a9a8:	44 0f b7 65 02       	movzwl 0x2(%rbp),%r12d
    a9ad:	31 db                	xor    %ebx,%ebx
    a9af:	4c 8d 2d a0 ab 00 00 	lea    0xaba0(%rip),%r13        # 15556 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x756>
    a9b6:	4c 8d 35 7f ae 00 00 	lea    0xae7f(%rip),%r14        # 1583c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa3c>
    a9bd:	45 85 e4             	test   %r12d,%r12d
    a9c0:	75 2d                	jne    a9ef <_DevPathNodeUnknown+0x9f>
    a9c2:	e9 b9 00 00 00       	jmp    aa80 <_DevPathNodeUnknown+0x130>
    a9c7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    a9ce:	00 00 
    a9d0:	0f b6 54 1d 04       	movzbl 0x4(%rbp,%rbx,1),%edx
    a9d5:	4c 89 ee             	mov    %r13,%rsi
    a9d8:	4c 89 ff             	mov    %r15,%rdi
    a9db:	31 c0                	xor    %eax,%eax
    a9dd:	48 83 c3 01          	add    $0x1,%rbx
    a9e1:	e8 ea e2 ff ff       	call   8cd0 <CatPrint>
    a9e6:	41 39 dc             	cmp    %ebx,%r12d
    a9e9:	0f 8e 91 00 00 00    	jle    aa80 <_DevPathNodeUnknown+0x130>
    a9ef:	48 85 db             	test   %rbx,%rbx
    a9f2:	75 dc                	jne    a9d0 <_DevPathNodeUnknown+0x80>
    a9f4:	4c 89 f6             	mov    %r14,%rsi
    a9f7:	4c 89 ff             	mov    %r15,%rdi
    a9fa:	31 c0                	xor    %eax,%eax
    a9fc:	e8 cf e2 ff ff       	call   8cd0 <CatPrint>
    aa01:	eb cd                	jmp    a9d0 <_DevPathNodeUnknown+0x80>
    aa03:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    aa08:	44 89 c2             	mov    %r8d,%edx
    aa0b:	48 8d 35 9e ad 00 00 	lea    0xad9e(%rip),%rsi        # 157b0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x9b0>
    aa12:	31 c0                	xor    %eax,%eax
    aa14:	e8 b7 e2 ff ff       	call   8cd0 <CatPrint>
    aa19:	eb 8d                	jmp    a9a8 <_DevPathNodeUnknown+0x58>
    aa1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    aa20:	44 89 c2             	mov    %r8d,%edx
    aa23:	48 8d 35 a6 ad 00 00 	lea    0xada6(%rip),%rsi        # 157d0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x9d0>
    aa2a:	31 c0                	xor    %eax,%eax
    aa2c:	e8 9f e2 ff ff       	call   8cd0 <CatPrint>
    aa31:	e9 72 ff ff ff       	jmp    a9a8 <_DevPathNodeUnknown+0x58>
    aa36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    aa3d:	00 00 00 
    aa40:	44 89 c2             	mov    %r8d,%edx
    aa43:	48 8d 35 9e ad 00 00 	lea    0xad9e(%rip),%rsi        # 157e8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x9e8>
    aa4a:	31 c0                	xor    %eax,%eax
    aa4c:	e8 7f e2 ff ff       	call   8cd0 <CatPrint>
    aa51:	e9 52 ff ff ff       	jmp    a9a8 <_DevPathNodeUnknown+0x58>
    aa56:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    aa5d:	00 00 00 
    aa60:	44 89 c2             	mov    %r8d,%edx
    aa63:	48 8d 35 8c ad 00 00 	lea    0xad8c(%rip),%rsi        # 157f6 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x9f6>
    aa6a:	31 c0                	xor    %eax,%eax
    aa6c:	e8 5f e2 ff ff       	call   8cd0 <CatPrint>
    aa71:	e9 32 ff ff ff       	jmp    a9a8 <_DevPathNodeUnknown+0x58>
    aa76:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    aa7d:	00 00 00 
    aa80:	48 83 c4 08          	add    $0x8,%rsp
    aa84:	4c 89 ff             	mov    %r15,%rdi
    aa87:	48 8d 35 da aa 00 00 	lea    0xaada(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    aa8e:	31 c0                	xor    %eax,%eax
    aa90:	5b                   	pop    %rbx
    aa91:	5d                   	pop    %rbp
    aa92:	41 5c                	pop    %r12
    aa94:	41 5d                	pop    %r13
    aa96:	41 5e                	pop    %r14
    aa98:	41 5f                	pop    %r15
    aa9a:	e9 31 e2 ff ff       	jmp    8cd0 <CatPrint>
    aa9f:	44 89 c1             	mov    %r8d,%ecx
    aaa2:	48 8d 35 7d ad 00 00 	lea    0xad7d(%rip),%rsi        # 15826 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa26>
    aaa9:	4c 89 ff             	mov    %r15,%rdi
    aaac:	31 c0                	xor    %eax,%eax
    aaae:	e8 1d e2 ff ff       	call   8cd0 <CatPrint>
    aab3:	e9 f0 fe ff ff       	jmp    a9a8 <_DevPathNodeUnknown+0x58>
    aab8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    aabf:	00 

000000000000aac0 <_DevPathVendor>:
    aac0:	f3 0f 1e fa          	endbr64
    aac4:	41 54                	push   %r12
    aac6:	48 8d 15 95 ad 00 00 	lea    0xad95(%rip),%rdx        # 15862 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa62>
    aacd:	55                   	push   %rbp
    aace:	48 89 fd             	mov    %rdi,%rbp
    aad1:	53                   	push   %rbx
    aad2:	0f b6 06             	movzbl (%rsi),%eax
    aad5:	48 89 f3             	mov    %rsi,%rbx
    aad8:	83 e0 7f             	and    $0x7f,%eax
    aadb:	3c 03                	cmp    $0x3,%al
    aadd:	74 1f                	je     aafe <_DevPathVendor+0x3e>
    aadf:	48 8d 15 84 ad 00 00 	lea    0xad84(%rip),%rdx        # 1586a <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa6a>
    aae6:	3c 04                	cmp    $0x4,%al
    aae8:	74 14                	je     aafe <_DevPathVendor+0x3e>
    aaea:	3c 01                	cmp    $0x1,%al
    aaec:	48 8d 15 fd a8 00 00 	lea    0xa8fd(%rip),%rdx        # 153f0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5f0>
    aaf3:	48 8d 05 62 ad 00 00 	lea    0xad62(%rip),%rax        # 1585c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa5c>
    aafa:	48 0f 44 d0          	cmove  %rax,%rdx
    aafe:	4c 8d 63 04          	lea    0x4(%rbx),%r12
    ab02:	48 8d 35 6d ad 00 00 	lea    0xad6d(%rip),%rsi        # 15876 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa76>
    ab09:	48 89 ef             	mov    %rbp,%rdi
    ab0c:	31 c0                	xor    %eax,%eax
    ab0e:	4c 89 e1             	mov    %r12,%rcx
    ab11:	e8 ba e1 ff ff       	call   8cd0 <CatPrint>
    ab16:	48 8d 35 c3 b4 00 00 	lea    0xb4c3(%rip),%rsi        # 15fe0 <UnknownDevice>
    ab1d:	4c 89 e7             	mov    %r12,%rdi
    ab20:	e8 6b bd ff ff       	call   6890 <CompareGuid>
    ab25:	48 85 c0             	test   %rax,%rax
    ab28:	75 1e                	jne    ab48 <_DevPathVendor+0x88>
    ab2a:	0f b6 53 14          	movzbl 0x14(%rbx),%edx
    ab2e:	48 89 ef             	mov    %rbp,%rdi
    ab31:	5b                   	pop    %rbx
    ab32:	48 8d 35 4f ad 00 00 	lea    0xad4f(%rip),%rsi        # 15888 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa88>
    ab39:	5d                   	pop    %rbp
    ab3a:	41 5c                	pop    %r12
    ab3c:	e9 8f e1 ff ff       	jmp    8cd0 <CatPrint>
    ab41:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ab48:	5b                   	pop    %rbx
    ab49:	48 89 ef             	mov    %rbp,%rdi
    ab4c:	48 8d 35 15 aa 00 00 	lea    0xaa15(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    ab53:	5d                   	pop    %rbp
    ab54:	31 c0                	xor    %eax,%eax
    ab56:	41 5c                	pop    %r12
    ab58:	e9 73 e1 ff ff       	jmp    8cd0 <CatPrint>
    ab5d:	0f 1f 00             	nopl   (%rax)

000000000000ab60 <_DevPathHardDrive>:
    ab60:	f3 0f 1e fa          	endbr64
    ab64:	0f b6 4e 29          	movzbl 0x29(%rsi),%ecx
    ab68:	8b 56 04             	mov    0x4(%rsi),%edx
    ab6b:	80 f9 01             	cmp    $0x1,%cl
    ab6e:	74 18                	je     ab88 <_DevPathHardDrive+0x28>
    ab70:	80 f9 02             	cmp    $0x2,%cl
    ab73:	74 2b                	je     aba0 <_DevPathHardDrive+0x40>
    ab75:	48 8d 35 5c ad 00 00 	lea    0xad5c(%rip),%rsi        # 158d8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xad8>
    ab7c:	31 c0                	xor    %eax,%eax
    ab7e:	e9 4d e1 ff ff       	jmp    8cd0 <CatPrint>
    ab83:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ab88:	8b 4e 18             	mov    0x18(%rsi),%ecx
    ab8b:	31 c0                	xor    %eax,%eax
    ab8d:	48 8d 35 04 ad 00 00 	lea    0xad04(%rip),%rsi        # 15898 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xa98>
    ab94:	e9 37 e1 ff ff       	jmp    8cd0 <CatPrint>
    ab99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    aba0:	48 8d 4e 18          	lea    0x18(%rsi),%rcx
    aba4:	31 c0                	xor    %eax,%eax
    aba6:	48 8d 35 0f ad 00 00 	lea    0xad0f(%rip),%rsi        # 158bc <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xabc>
    abad:	e9 1e e1 ff ff       	jmp    8cd0 <CatPrint>
    abb2:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    abb9:	00 00 00 00 
    abbd:	0f 1f 00             	nopl   (%rax)

000000000000abc0 <CatPrintIPv6.isra.0>:
    abc0:	0f b6 c9             	movzbl %cl,%ecx
    abc3:	41 55                	push   %r13
    abc5:	49 89 fa             	mov    %rdi,%r10
    abc8:	45 0f b6 c0          	movzbl %r8b,%r8d
    abcc:	41 54                	push   %r12
    abce:	c1 e1 08             	shl    $0x8,%ecx
    abd1:	41 89 f4             	mov    %esi,%r12d
    abd4:	41 0f b6 f1          	movzbl %r9b,%esi
    abd8:	55                   	push   %rbp
    abd9:	44 09 c1             	or     %r8d,%ecx
    abdc:	44 0f b6 ea          	movzbl %dl,%r13d
    abe0:	c1 e6 08             	shl    $0x8,%esi
    abe3:	53                   	push   %rbx
    abe4:	0f b6 7c 24 70       	movzbl 0x70(%rsp),%edi
    abe9:	41 0f b6 d4          	movzbl %r12b,%edx
    abed:	44 0f b6 44 24 78    	movzbl 0x78(%rsp),%r8d
    abf3:	0f b6 44 24 40       	movzbl 0x40(%rsp),%eax
    abf8:	c1 e2 08             	shl    $0x8,%edx
    abfb:	c1 e7 08             	shl    $0x8,%edi
    abfe:	0f b6 6c 24 38       	movzbl 0x38(%rsp),%ebp
    ac03:	0f b6 5c 24 28       	movzbl 0x28(%rsp),%ebx
    ac08:	44 09 ea             	or     %r13d,%edx
    ac0b:	44 09 c7             	or     %r8d,%edi
    ac0e:	44 0f b6 44 24 68    	movzbl 0x68(%rsp),%r8d
    ac14:	44 0f b6 5c 24 30    	movzbl 0x30(%rsp),%r11d
    ac1a:	c1 e0 08             	shl    $0x8,%eax
    ac1d:	89 7c 24 40          	mov    %edi,0x40(%rsp)
    ac21:	0f b6 7c 24 60       	movzbl 0x60(%rsp),%edi
    ac26:	09 de                	or     %ebx,%esi
    ac28:	41 c1 e3 08          	shl    $0x8,%r11d
    ac2c:	c1 e7 08             	shl    $0x8,%edi
    ac2f:	45 89 d9             	mov    %r11d,%r9d
    ac32:	44 09 c7             	or     %r8d,%edi
    ac35:	44 0f b6 44 24 58    	movzbl 0x58(%rsp),%r8d
    ac3b:	41 09 e9             	or     %ebp,%r9d
    ac3e:	89 7c 24 38          	mov    %edi,0x38(%rsp)
    ac42:	0f b6 7c 24 50       	movzbl 0x50(%rsp),%edi
    ac47:	c1 e7 08             	shl    $0x8,%edi
    ac4a:	44 09 c7             	or     %r8d,%edi
    ac4d:	41 89 f0             	mov    %esi,%r8d
    ac50:	48 8d 35 99 ac 00 00 	lea    0xac99(%rip),%rsi        # 158f0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xaf0>
    ac57:	89 7c 24 30          	mov    %edi,0x30(%rsp)
    ac5b:	0f b6 7c 24 48       	movzbl 0x48(%rsp),%edi
    ac60:	09 f8                	or     %edi,%eax
    ac62:	4c 89 d7             	mov    %r10,%rdi
    ac65:	89 44 24 28          	mov    %eax,0x28(%rsp)
    ac69:	5b                   	pop    %rbx
    ac6a:	31 c0                	xor    %eax,%eax
    ac6c:	5d                   	pop    %rbp
    ac6d:	41 5c                	pop    %r12
    ac6f:	41 5d                	pop    %r13
    ac71:	e9 5a e0 ff ff       	jmp    8cd0 <CatPrint>
    ac76:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ac7d:	00 00 00 

000000000000ac80 <_DevPathIPv6>:
    ac80:	f3 0f 1e fa          	endbr64
    ac84:	41 54                	push   %r12
    ac86:	31 c0                	xor    %eax,%eax
    ac88:	4c 8d 25 11 a7 00 00 	lea    0xa711(%rip),%r12        # 153a0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5a0>
    ac8f:	55                   	push   %rbp
    ac90:	48 89 fd             	mov    %rdi,%rbp
    ac93:	53                   	push   %rbx
    ac94:	48 89 f3             	mov    %rsi,%rbx
    ac97:	48 8d 35 f0 ac 00 00 	lea    0xacf0(%rip),%rsi        # 1598e <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb8e>
    ac9e:	48 83 ec 60          	sub    $0x60,%rsp
    aca2:	e8 29 e0 ff ff       	call   8cd0 <CatPrint>
    aca7:	0f b6 43 23          	movzbl 0x23(%rbx),%eax
    acab:	0f b6 53 15          	movzbl 0x15(%rbx),%edx
    acaf:	48 89 ef             	mov    %rbp,%rdi
    acb2:	0f b6 4b 16          	movzbl 0x16(%rbx),%ecx
    acb6:	0f b6 73 14          	movzbl 0x14(%rbx),%esi
    acba:	44 0f b6 4b 18       	movzbl 0x18(%rbx),%r9d
    acbf:	44 0f b6 43 17       	movzbl 0x17(%rbx),%r8d
    acc4:	88 44 24 50          	mov    %al,0x50(%rsp)
    acc8:	0f b6 43 22          	movzbl 0x22(%rbx),%eax
    accc:	88 44 24 48          	mov    %al,0x48(%rsp)
    acd0:	0f b6 43 21          	movzbl 0x21(%rbx),%eax
    acd4:	88 44 24 40          	mov    %al,0x40(%rsp)
    acd8:	0f b6 43 20          	movzbl 0x20(%rbx),%eax
    acdc:	88 44 24 38          	mov    %al,0x38(%rsp)
    ace0:	0f b6 43 1f          	movzbl 0x1f(%rbx),%eax
    ace4:	88 44 24 30          	mov    %al,0x30(%rsp)
    ace8:	0f b6 43 1e          	movzbl 0x1e(%rbx),%eax
    acec:	88 44 24 28          	mov    %al,0x28(%rsp)
    acf0:	0f b6 43 1d          	movzbl 0x1d(%rbx),%eax
    acf4:	88 44 24 20          	mov    %al,0x20(%rsp)
    acf8:	0f b6 43 1c          	movzbl 0x1c(%rbx),%eax
    acfc:	88 44 24 18          	mov    %al,0x18(%rsp)
    ad00:	0f b6 43 1b          	movzbl 0x1b(%rbx),%eax
    ad04:	88 44 24 10          	mov    %al,0x10(%rsp)
    ad08:	0f b6 43 1a          	movzbl 0x1a(%rbx),%eax
    ad0c:	88 44 24 08          	mov    %al,0x8(%rsp)
    ad10:	0f b6 43 19          	movzbl 0x19(%rbx),%eax
    ad14:	88 04 24             	mov    %al,(%rsp)
    ad17:	e8 a4 fe ff ff       	call   abc0 <CatPrintIPv6.isra.0>
    ad1c:	4c 89 e6             	mov    %r12,%rsi
    ad1f:	48 89 ef             	mov    %rbp,%rdi
    ad22:	31 c0                	xor    %eax,%eax
    ad24:	e8 a7 df ff ff       	call   8cd0 <CatPrint>
    ad29:	0f b7 53 28          	movzwl 0x28(%rbx),%edx
    ad2d:	66 83 fa 06          	cmp    $0x6,%dx
    ad31:	0f 84 09 01 00 00    	je     ae40 <_DevPathIPv6+0x1c0>
    ad37:	66 83 fa 11          	cmp    $0x11,%dx
    ad3b:	0f 84 df 00 00 00    	je     ae20 <_DevPathIPv6+0x1a0>
    ad41:	48 8d 35 62 ac 00 00 	lea    0xac62(%rip),%rsi        # 159aa <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbaa>
    ad48:	48 89 ef             	mov    %rbp,%rdi
    ad4b:	31 c0                	xor    %eax,%eax
    ad4d:	e8 7e df ff ff       	call   8cd0 <CatPrint>
    ad52:	0f b6 43 2a          	movzbl 0x2a(%rbx),%eax
    ad56:	48 8d 15 ef ab 00 00 	lea    0xabef(%rip),%rdx        # 1594c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb4c>
    ad5d:	84 c0                	test   %al,%al
    ad5f:	74 14                	je     ad75 <_DevPathIPv6+0xf5>
    ad61:	3c 01                	cmp    $0x1,%al
    ad63:	48 8d 15 f6 ab 00 00 	lea    0xabf6(%rip),%rdx        # 15960 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb60>
    ad6a:	48 8d 05 af ab 00 00 	lea    0xabaf(%rip),%rax        # 15920 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb20>
    ad71:	48 0f 45 d0          	cmovne %rax,%rdx
    ad75:	48 8d 35 34 ac 00 00 	lea    0xac34(%rip),%rsi        # 159b0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbb0>
    ad7c:	48 89 ef             	mov    %rbp,%rdi
    ad7f:	31 c0                	xor    %eax,%eax
    ad81:	e8 4a df ff ff       	call   8cd0 <CatPrint>
    ad86:	0f b6 43 13          	movzbl 0x13(%rbx),%eax
    ad8a:	0f b6 4b 06          	movzbl 0x6(%rbx),%ecx
    ad8e:	48 89 ef             	mov    %rbp,%rdi
    ad91:	0f b6 53 05          	movzbl 0x5(%rbx),%edx
    ad95:	0f b6 73 04          	movzbl 0x4(%rbx),%esi
    ad99:	44 0f b6 4b 08       	movzbl 0x8(%rbx),%r9d
    ad9e:	44 0f b6 43 07       	movzbl 0x7(%rbx),%r8d
    ada3:	88 44 24 50          	mov    %al,0x50(%rsp)
    ada7:	0f b6 43 12          	movzbl 0x12(%rbx),%eax
    adab:	88 44 24 48          	mov    %al,0x48(%rsp)
    adaf:	0f b6 43 11          	movzbl 0x11(%rbx),%eax
    adb3:	88 44 24 40          	mov    %al,0x40(%rsp)
    adb7:	0f b6 43 10          	movzbl 0x10(%rbx),%eax
    adbb:	88 44 24 38          	mov    %al,0x38(%rsp)
    adbf:	0f b6 43 0f          	movzbl 0xf(%rbx),%eax
    adc3:	88 44 24 30          	mov    %al,0x30(%rsp)
    adc7:	0f b6 43 0e          	movzbl 0xe(%rbx),%eax
    adcb:	88 44 24 28          	mov    %al,0x28(%rsp)
    adcf:	0f b6 43 0d          	movzbl 0xd(%rbx),%eax
    add3:	88 44 24 20          	mov    %al,0x20(%rsp)
    add7:	0f b6 43 0c          	movzbl 0xc(%rbx),%eax
    addb:	88 44 24 18          	mov    %al,0x18(%rsp)
    addf:	0f b6 43 0b          	movzbl 0xb(%rbx),%eax
    ade3:	88 44 24 10          	mov    %al,0x10(%rsp)
    ade7:	0f b6 43 0a          	movzbl 0xa(%rbx),%eax
    adeb:	88 44 24 08          	mov    %al,0x8(%rsp)
    adef:	0f b6 43 09          	movzbl 0x9(%rbx),%eax
    adf3:	88 04 24             	mov    %al,(%rsp)
    adf6:	e8 c5 fd ff ff       	call   abc0 <CatPrintIPv6.isra.0>
    adfb:	66 83 7b 02 3c       	cmpw   $0x3c,0x2(%rbx)
    ae00:	74 5e                	je     ae60 <_DevPathIPv6+0x1e0>
    ae02:	48 83 c4 60          	add    $0x60,%rsp
    ae06:	48 89 ef             	mov    %rbp,%rdi
    ae09:	48 8d 35 58 a7 00 00 	lea    0xa758(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    ae10:	31 c0                	xor    %eax,%eax
    ae12:	5b                   	pop    %rbx
    ae13:	5d                   	pop    %rbp
    ae14:	41 5c                	pop    %r12
    ae16:	e9 b5 de ff ff       	jmp    8cd0 <CatPrint>
    ae1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ae20:	48 8d 35 7b ab 00 00 	lea    0xab7b(%rip),%rsi        # 159a2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xba2>
    ae27:	48 89 ef             	mov    %rbp,%rdi
    ae2a:	31 c0                	xor    %eax,%eax
    ae2c:	e8 9f de ff ff       	call   8cd0 <CatPrint>
    ae31:	e9 1c ff ff ff       	jmp    ad52 <_DevPathIPv6+0xd2>
    ae36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ae3d:	00 00 00 
    ae40:	48 8d 35 53 ab 00 00 	lea    0xab53(%rip),%rsi        # 1599a <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb9a>
    ae47:	48 89 ef             	mov    %rbp,%rdi
    ae4a:	31 c0                	xor    %eax,%eax
    ae4c:	e8 7f de ff ff       	call   8cd0 <CatPrint>
    ae51:	e9 fc fe ff ff       	jmp    ad52 <_DevPathIPv6+0xd2>
    ae56:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ae5d:	00 00 00 
    ae60:	4c 89 e6             	mov    %r12,%rsi
    ae63:	48 89 ef             	mov    %rbp,%rdi
    ae66:	31 c0                	xor    %eax,%eax
    ae68:	e8 63 de ff ff       	call   8cd0 <CatPrint>
    ae6d:	0f b6 43 3b          	movzbl 0x3b(%rbx),%eax
    ae71:	0f b6 53 2d          	movzbl 0x2d(%rbx),%edx
    ae75:	48 89 ef             	mov    %rbp,%rdi
    ae78:	0f b6 4b 2e          	movzbl 0x2e(%rbx),%ecx
    ae7c:	0f b6 73 2c          	movzbl 0x2c(%rbx),%esi
    ae80:	44 0f b6 4b 30       	movzbl 0x30(%rbx),%r9d
    ae85:	44 0f b6 43 2f       	movzbl 0x2f(%rbx),%r8d
    ae8a:	88 44 24 50          	mov    %al,0x50(%rsp)
    ae8e:	0f b6 43 3a          	movzbl 0x3a(%rbx),%eax
    ae92:	88 44 24 48          	mov    %al,0x48(%rsp)
    ae96:	0f b6 43 39          	movzbl 0x39(%rbx),%eax
    ae9a:	88 44 24 40          	mov    %al,0x40(%rsp)
    ae9e:	0f b6 43 38          	movzbl 0x38(%rbx),%eax
    aea2:	88 44 24 38          	mov    %al,0x38(%rsp)
    aea6:	0f b6 43 37          	movzbl 0x37(%rbx),%eax
    aeaa:	88 44 24 30          	mov    %al,0x30(%rsp)
    aeae:	0f b6 43 36          	movzbl 0x36(%rbx),%eax
    aeb2:	88 44 24 28          	mov    %al,0x28(%rsp)
    aeb6:	0f b6 43 35          	movzbl 0x35(%rbx),%eax
    aeba:	88 44 24 20          	mov    %al,0x20(%rsp)
    aebe:	0f b6 43 34          	movzbl 0x34(%rbx),%eax
    aec2:	88 44 24 18          	mov    %al,0x18(%rsp)
    aec6:	0f b6 43 33          	movzbl 0x33(%rbx),%eax
    aeca:	88 44 24 10          	mov    %al,0x10(%rsp)
    aece:	0f b6 43 32          	movzbl 0x32(%rbx),%eax
    aed2:	88 44 24 08          	mov    %al,0x8(%rsp)
    aed6:	0f b6 43 31          	movzbl 0x31(%rbx),%eax
    aeda:	88 04 24             	mov    %al,(%rsp)
    aedd:	e8 de fc ff ff       	call   abc0 <CatPrintIPv6.isra.0>
    aee2:	4c 89 e6             	mov    %r12,%rsi
    aee5:	48 89 ef             	mov    %rbp,%rdi
    aee8:	31 c0                	xor    %eax,%eax
    aeea:	e8 e1 dd ff ff       	call   8cd0 <CatPrint>
    aeef:	48 8d 53 2b          	lea    0x2b(%rbx),%rdx
    aef3:	48 89 ef             	mov    %rbp,%rdi
    aef6:	31 c0                	xor    %eax,%eax
    aef8:	48 8d 35 ab aa 00 00 	lea    0xaaab(%rip),%rsi        # 159aa <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbaa>
    aeff:	e8 cc dd ff ff       	call   8cd0 <CatPrint>
    af04:	e9 f9 fe ff ff       	jmp    ae02 <_DevPathIPv6+0x182>
    af09:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

000000000000af10 <_DevPathIPv4>:
    af10:	f3 0f 1e fa          	endbr64
    af14:	41 55                	push   %r13
    af16:	31 c0                	xor    %eax,%eax
    af18:	4c 8d 2d 81 a4 00 00 	lea    0xa481(%rip),%r13        # 153a0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x5a0>
    af1f:	41 54                	push   %r12
    af21:	4c 8d 25 a8 aa 00 00 	lea    0xaaa8(%rip),%r12        # 159d0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbd0>
    af28:	55                   	push   %rbp
    af29:	48 89 fd             	mov    %rdi,%rbp
    af2c:	53                   	push   %rbx
    af2d:	48 89 f3             	mov    %rsi,%rbx
    af30:	48 8d 35 8d aa 00 00 	lea    0xaa8d(%rip),%rsi        # 159c4 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbc4>
    af37:	48 83 ec 08          	sub    $0x8,%rsp
    af3b:	e8 90 dd ff ff       	call   8cd0 <CatPrint>
    af40:	0f b6 53 08          	movzbl 0x8(%rbx),%edx
    af44:	0f b6 4b 09          	movzbl 0x9(%rbx),%ecx
    af48:	4c 89 e6             	mov    %r12,%rsi
    af4b:	44 0f b6 4b 0b       	movzbl 0xb(%rbx),%r9d
    af50:	44 0f b6 43 0a       	movzbl 0xa(%rbx),%r8d
    af55:	48 89 ef             	mov    %rbp,%rdi
    af58:	31 c0                	xor    %eax,%eax
    af5a:	e8 71 dd ff ff       	call   8cd0 <CatPrint>
    af5f:	4c 89 ee             	mov    %r13,%rsi
    af62:	48 89 ef             	mov    %rbp,%rdi
    af65:	31 c0                	xor    %eax,%eax
    af67:	e8 64 dd ff ff       	call   8cd0 <CatPrint>
    af6c:	0f b7 53 10          	movzwl 0x10(%rbx),%edx
    af70:	66 83 fa 06          	cmp    $0x6,%dx
    af74:	0f 84 e6 00 00 00    	je     b060 <_DevPathIPv4+0x150>
    af7a:	66 83 fa 11          	cmp    $0x11,%dx
    af7e:	0f 84 c4 00 00 00    	je     b048 <_DevPathIPv4+0x138>
    af84:	48 8d 35 1f aa 00 00 	lea    0xaa1f(%rip),%rsi        # 159aa <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbaa>
    af8b:	48 89 ef             	mov    %rbp,%rdi
    af8e:	31 c0                	xor    %eax,%eax
    af90:	e8 3b dd ff ff       	call   8cd0 <CatPrint>
    af95:	80 7b 12 00          	cmpb   $0x0,0x12(%rbx)
    af99:	48 8d 05 1a aa 00 00 	lea    0xaa1a(%rip),%rax        # 159ba <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbba>
    afa0:	48 89 ef             	mov    %rbp,%rdi
    afa3:	48 8d 15 a2 a9 00 00 	lea    0xa9a2(%rip),%rdx        # 1594c <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb4c>
    afaa:	48 8d 35 37 aa 00 00 	lea    0xaa37(%rip),%rsi        # 159e8 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbe8>
    afb1:	48 0f 44 d0          	cmove  %rax,%rdx
    afb5:	31 c0                	xor    %eax,%eax
    afb7:	e8 14 dd ff ff       	call   8cd0 <CatPrint>
    afbc:	0f b6 43 05          	movzbl 0x5(%rbx),%eax
    afc0:	0a 43 04             	or     0x4(%rbx),%al
    afc3:	0a 43 06             	or     0x6(%rbx),%al
    afc6:	0a 43 07             	or     0x7(%rbx),%al
    afc9:	74 55                	je     b020 <_DevPathIPv4+0x110>
    afcb:	4c 89 ee             	mov    %r13,%rsi
    afce:	48 89 ef             	mov    %rbp,%rdi
    afd1:	31 c0                	xor    %eax,%eax
    afd3:	e8 f8 dc ff ff       	call   8cd0 <CatPrint>
    afd8:	0f b6 4b 05          	movzbl 0x5(%rbx),%ecx
    afdc:	0f b6 53 04          	movzbl 0x4(%rbx),%edx
    afe0:	31 c0                	xor    %eax,%eax
    afe2:	44 0f b6 4b 07       	movzbl 0x7(%rbx),%r9d
    afe7:	44 0f b6 43 06       	movzbl 0x6(%rbx),%r8d
    afec:	4c 89 e6             	mov    %r12,%rsi
    afef:	48 89 ef             	mov    %rbp,%rdi
    aff2:	e8 d9 dc ff ff       	call   8cd0 <CatPrint>
    aff7:	66 83 7b 02 1c       	cmpw   $0x1c,0x2(%rbx)
    affc:	0f 84 7e 00 00 00    	je     b080 <_DevPathIPv4+0x170>
    b002:	48 83 c4 08          	add    $0x8,%rsp
    b006:	48 89 ef             	mov    %rbp,%rdi
    b009:	48 8d 35 58 a5 00 00 	lea    0xa558(%rip),%rsi        # 15568 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x768>
    b010:	31 c0                	xor    %eax,%eax
    b012:	5b                   	pop    %rbx
    b013:	5d                   	pop    %rbp
    b014:	41 5c                	pop    %r12
    b016:	41 5d                	pop    %r13
    b018:	e9 b3 dc ff ff       	jmp    8cd0 <CatPrint>
    b01d:	0f 1f 00             	nopl   (%rax)
    b020:	66 83 7b 02 1c       	cmpw   $0x1c,0x2(%rbx)
    b025:	75 db                	jne    b002 <_DevPathIPv4+0xf2>
    b027:	0f b6 43 13          	movzbl 0x13(%rbx),%eax
    b02b:	0a 43 14             	or     0x14(%rbx),%al
    b02e:	0a 43 15             	or     0x15(%rbx),%al
    b031:	0a 43 16             	or     0x16(%rbx),%al
    b034:	0a 43 17             	or     0x17(%rbx),%al
    b037:	0a 43 18             	or     0x18(%rbx),%al
    b03a:	0a 43 19             	or     0x19(%rbx),%al
    b03d:	0a 43 1a             	or     0x1a(%rbx),%al
    b040:	74 c0                	je     b002 <_DevPathIPv4+0xf2>
    b042:	eb 87                	jmp    afcb <_DevPathIPv4+0xbb>
    b044:	0f 1f 40 00          	nopl   0x0(%rax)
    b048:	48 8d 35 53 a9 00 00 	lea    0xa953(%rip),%rsi        # 159a2 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xba2>
    b04f:	48 89 ef             	mov    %rbp,%rdi
    b052:	31 c0                	xor    %eax,%eax
    b054:	e8 77 dc ff ff       	call   8cd0 <CatPrint>
    b059:	e9 37 ff ff ff       	jmp    af95 <_DevPathIPv4+0x85>
    b05e:	66 90                	xchg   %ax,%ax
    b060:	48 8d 35 33 a9 00 00 	lea    0xa933(%rip),%rsi        # 1599a <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xb9a>
    b067:	48 89 ef             	mov    %rbp,%rdi
    b06a:	31 c0                	xor    %eax,%eax
    b06c:	e8 5f dc ff ff       	call   8cd0 <CatPrint>
    b071:	e9 1f ff ff ff       	jmp    af95 <_DevPathIPv4+0x85>
    b076:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    b07d:	00 00 00 
    b080:	0f b6 43 13          	movzbl 0x13(%rbx),%eax
    b084:	0a 43 14             	or     0x14(%rbx),%al
    b087:	0a 43 15             	or     0x15(%rbx),%al
    b08a:	0a 43 16             	or     0x16(%rbx),%al
    b08d:	0a 43 17             	or     0x17(%rbx),%al
    b090:	0a 43 18             	or     0x18(%rbx),%al
    b093:	0a 43 19             	or     0x19(%rbx),%al
    b096:	0a 43 1a             	or     0x1a(%rbx),%al
    b099:	0f 84 63 ff ff ff    	je     b002 <_DevPathIPv4+0xf2>
    b09f:	4c 89 ee             	mov    %r13,%rsi
    b0a2:	48 89 ef             	mov    %rbp,%rdi
    b0a5:	31 c0                	xor    %eax,%eax
    b0a7:	e8 24 dc ff ff       	call   8cd0 <CatPrint>
    b0ac:	0f b6 4b 14          	movzbl 0x14(%rbx),%ecx
    b0b0:	0f b6 53 13          	movzbl 0x13(%rbx),%edx
    b0b4:	31 c0                	xor    %eax,%eax
    b0b6:	44 0f b6 4b 16       	movzbl 0x16(%rbx),%r9d
    b0bb:	44 0f b6 43 15       	movzbl 0x15(%rbx),%r8d
    b0c0:	4c 89 e6             	mov    %r12,%rsi
    b0c3:	48 89 ef             	mov    %rbp,%rdi
    b0c6:	e8 05 dc ff ff       	call   8cd0 <CatPrint>
    b0cb:	0f b6 43 17          	movzbl 0x17(%rbx),%eax
    b0cf:	0a 43 18             	or     0x18(%rbx),%al
    b0d2:	0a 43 19             	or     0x19(%rbx),%al
    b0d5:	0a 43 1a             	or     0x1a(%rbx),%al
    b0d8:	0f 84 24 ff ff ff    	je     b002 <_DevPathIPv4+0xf2>
    b0de:	4c 89 ee             	mov    %r13,%rsi
    b0e1:	48 89 ef             	mov    %rbp,%rdi
    b0e4:	31 c0                	xor    %eax,%eax
    b0e6:	e8 e5 db ff ff       	call   8cd0 <CatPrint>
    b0eb:	0f b6 4b 18          	movzbl 0x18(%rbx),%ecx
    b0ef:	0f b6 53 17          	movzbl 0x17(%rbx),%edx
    b0f3:	4c 89 e6             	mov    %r12,%rsi
    b0f6:	44 0f b6 4b 1a       	movzbl 0x1a(%rbx),%r9d
    b0fb:	44 0f b6 43 19       	movzbl 0x19(%rbx),%r8d
    b100:	48 89 ef             	mov    %rbp,%rdi
    b103:	31 c0                	xor    %eax,%eax
    b105:	e8 c6 db ff ff       	call   8cd0 <CatPrint>
    b10a:	e9 f3 fe ff ff       	jmp    b002 <_DevPathIPv4+0xf2>
    b10f:	90                   	nop

000000000000b110 <DevicePathFromHandle>:
    b110:	f3 0f 1e fa          	endbr64
    b114:	48 83 ec 38          	sub    $0x38,%rsp
    b118:	48 8b 05 b1 20 01 00 	mov    0x120b1(%rip),%rax        # 1d1d0 <BS>
    b11f:	48 89 f9             	mov    %rdi,%rcx
    b122:	48 8d 15 f7 b1 00 00 	lea    0xb1f7(%rip),%rdx        # 16320 <gEfiDevicePathProtocolGuid>
    b129:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    b12e:	ff 90 98 00 00 00    	call   *0x98(%rax)
    b134:	48 85 c0             	test   %rax,%rax
    b137:	b8 00 00 00 00       	mov    $0x0,%eax
    b13c:	48 0f 49 44 24 28    	cmovns 0x28(%rsp),%rax
    b142:	48 83 c4 38          	add    $0x38,%rsp
    b146:	c3                   	ret
    b147:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    b14e:	00 00 

000000000000b150 <DevicePathInstance>:
    b150:	f3 0f 1e fa          	endbr64
    b154:	41 57                	push   %r15
    b156:	41 56                	push   %r14
    b158:	41 55                	push   %r13
    b15a:	41 54                	push   %r12
    b15c:	55                   	push   %rbp
    b15d:	53                   	push   %rbx
    b15e:	48 83 ec 08          	sub    $0x8,%rsp
    b162:	4c 8b 27             	mov    (%rdi),%r12
    b165:	4d 85 e4             	test   %r12,%r12
    b168:	74 58                	je     b1c2 <DevicePathInstance+0x72>
    b16a:	41 0f b6 04 24       	movzbl (%r12),%eax
    b16f:	41 0f b7 5c 24 02    	movzwl 0x2(%r12),%ebx
    b175:	49 89 fd             	mov    %rdi,%r13
    b178:	49 89 f6             	mov    %rsi,%r14
    b17b:	83 e0 7f             	and    $0x7f,%eax
    b17e:	4c 01 e3             	add    %r12,%rbx
    b181:	3c 7f                	cmp    $0x7f,%al
    b183:	74 66                	je     b1eb <DevicePathInstance+0x9b>
    b185:	ba 01 02 00 00       	mov    $0x201,%edx
    b18a:	eb 0a                	jmp    b196 <DevicePathInstance+0x46>
    b18c:	0f 1f 40 00          	nopl   0x0(%rax)
    b190:	48 83 ea 01          	sub    $0x1,%rdx
    b194:	74 3e                	je     b1d4 <DevicePathInstance+0x84>
    b196:	0f b7 43 02          	movzwl 0x2(%rbx),%eax
    b19a:	48 89 dd             	mov    %rbx,%rbp
    b19d:	48 01 c3             	add    %rax,%rbx
    b1a0:	0f b6 45 00          	movzbl 0x0(%rbp),%eax
    b1a4:	83 e0 7f             	and    $0x7f,%eax
    b1a7:	3c 7f                	cmp    $0x7f,%al
    b1a9:	75 e5                	jne    b190 <DevicePathInstance+0x40>
    b1ab:	49 89 ef             	mov    %rbp,%r15
    b1ae:	4d 29 e7             	sub    %r12,%r15
    b1b1:	31 c0                	xor    %eax,%eax
    b1b3:	80 7d 01 ff          	cmpb   $0xff,0x1(%rbp)
    b1b7:	48 0f 44 d8          	cmove  %rax,%rbx
    b1bb:	49 89 5d 00          	mov    %rbx,0x0(%r13)
    b1bf:	4d 89 3e             	mov    %r15,(%r14)
    b1c2:	48 83 c4 08          	add    $0x8,%rsp
    b1c6:	4c 89 e0             	mov    %r12,%rax
    b1c9:	5b                   	pop    %rbx
    b1ca:	5d                   	pop    %rbp
    b1cb:	41 5c                	pop    %r12
    b1cd:	41 5d                	pop    %r13
    b1cf:	41 5e                	pop    %r14
    b1d1:	41 5f                	pop    %r15
    b1d3:	c3                   	ret
    b1d4:	49 89 ef             	mov    %rbp,%r15
    b1d7:	4c 89 e1             	mov    %r12,%rcx
    b1da:	31 f6                	xor    %esi,%esi
    b1dc:	31 ff                	xor    %edi,%edi
    b1de:	4d 29 e7             	sub    %r12,%r15
    b1e1:	4c 89 fa             	mov    %r15,%rdx
    b1e4:	e8 97 e2 ff ff       	call   9480 <DumpHex>
    b1e9:	eb c6                	jmp    b1b1 <DevicePathInstance+0x61>
    b1eb:	4c 89 e5             	mov    %r12,%rbp
    b1ee:	45 31 ff             	xor    %r15d,%r15d
    b1f1:	eb be                	jmp    b1b1 <DevicePathInstance+0x61>
    b1f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    b1fa:	00 00 00 00 
    b1fe:	66 90                	xchg   %ax,%ax

000000000000b200 <DevicePathInstanceCount>:
    b200:	f3 0f 1e fa          	endbr64
    b204:	41 54                	push   %r12
    b206:	45 31 e4             	xor    %r12d,%r12d
    b209:	55                   	push   %rbp
    b20a:	53                   	push   %rbx
    b20b:	48 83 ec 20          	sub    $0x20,%rsp
    b20f:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
    b214:	48 8d 6c 24 18       	lea    0x18(%rsp),%rbp
    b219:	48 8d 5c 24 08       	lea    0x8(%rsp),%rbx
    b21e:	eb 04                	jmp    b224 <DevicePathInstanceCount+0x24>
    b220:	49 83 c4 01          	add    $0x1,%r12
    b224:	48 89 ee             	mov    %rbp,%rsi
    b227:	48 89 df             	mov    %rbx,%rdi
    b22a:	e8 21 ff ff ff       	call   b150 <DevicePathInstance>
    b22f:	48 85 c0             	test   %rax,%rax
    b232:	75 ec                	jne    b220 <DevicePathInstanceCount+0x20>
    b234:	48 83 c4 20          	add    $0x20,%rsp
    b238:	4c 89 e0             	mov    %r12,%rax
    b23b:	5b                   	pop    %rbx
    b23c:	5d                   	pop    %rbp
    b23d:	41 5c                	pop    %r12
    b23f:	c3                   	ret

000000000000b240 <DevicePathSize>:
    b240:	f3 0f 1e fa          	endbr64
    b244:	48 89 f8             	mov    %rdi,%rax
    b247:	eb 0e                	jmp    b257 <DevicePathSize+0x17>
    b249:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    b250:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b254:	48 01 d0             	add    %rdx,%rax
    b257:	0f b6 10             	movzbl (%rax),%edx
    b25a:	83 e2 7f             	and    $0x7f,%edx
    b25d:	80 fa 7f             	cmp    $0x7f,%dl
    b260:	75 ee                	jne    b250 <DevicePathSize+0x10>
    b262:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b266:	75 e8                	jne    b250 <DevicePathSize+0x10>
    b268:	48 29 f8             	sub    %rdi,%rax
    b26b:	48 83 c0 04          	add    $0x4,%rax
    b26f:	c3                   	ret

000000000000b270 <DuplicateDevicePath>:
    b270:	f3 0f 1e fa          	endbr64
    b274:	41 55                	push   %r13
    b276:	48 89 f8             	mov    %rdi,%rax
    b279:	41 54                	push   %r12
    b27b:	55                   	push   %rbp
    b27c:	48 89 fd             	mov    %rdi,%rbp
    b27f:	eb 0e                	jmp    b28f <DuplicateDevicePath+0x1f>
    b281:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    b288:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b28c:	48 01 d0             	add    %rdx,%rax
    b28f:	0f b6 10             	movzbl (%rax),%edx
    b292:	83 e2 7f             	and    $0x7f,%edx
    b295:	80 fa 7f             	cmp    $0x7f,%dl
    b298:	75 ee                	jne    b288 <DuplicateDevicePath+0x18>
    b29a:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b29e:	75 e8                	jne    b288 <DuplicateDevicePath+0x18>
    b2a0:	48 29 e8             	sub    %rbp,%rax
    b2a3:	4c 8d 68 04          	lea    0x4(%rax),%r13
    b2a7:	4c 89 ef             	mov    %r13,%rdi
    b2aa:	e8 71 b9 ff ff       	call   6c20 <AllocatePool>
    b2af:	49 89 c4             	mov    %rax,%r12
    b2b2:	48 85 c0             	test   %rax,%rax
    b2b5:	74 0e                	je     b2c5 <DuplicateDevicePath+0x55>
    b2b7:	4c 89 ea             	mov    %r13,%rdx
    b2ba:	48 89 ee             	mov    %rbp,%rsi
    b2bd:	48 89 c7             	mov    %rax,%rdi
    b2c0:	e8 bb ba ff ff       	call   6d80 <CopyMem>
    b2c5:	4c 89 e0             	mov    %r12,%rax
    b2c8:	5d                   	pop    %rbp
    b2c9:	41 5c                	pop    %r12
    b2cb:	41 5d                	pop    %r13
    b2cd:	c3                   	ret
    b2ce:	66 90                	xchg   %ax,%ax

000000000000b2d0 <AppendDevicePath>:
    b2d0:	f3 0f 1e fa          	endbr64
    b2d4:	41 57                	push   %r15
    b2d6:	41 56                	push   %r14
    b2d8:	41 55                	push   %r13
    b2da:	49 89 f5             	mov    %rsi,%r13
    b2dd:	41 54                	push   %r12
    b2df:	55                   	push   %rbp
    b2e0:	53                   	push   %rbx
    b2e1:	48 83 ec 28          	sub    $0x28,%rsp
    b2e5:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
    b2ea:	48 85 ff             	test   %rdi,%rdi
    b2ed:	0f 84 3a 01 00 00    	je     b42d <AppendDevicePath+0x15d>
    b2f3:	49 89 f8             	mov    %rdi,%r8
    b2f6:	48 89 f8             	mov    %rdi,%rax
    b2f9:	48 85 f6             	test   %rsi,%rsi
    b2fc:	75 11                	jne    b30f <AppendDevicePath+0x3f>
    b2fe:	e9 1f 01 00 00       	jmp    b422 <AppendDevicePath+0x152>
    b303:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    b308:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b30c:	48 01 d0             	add    %rdx,%rax
    b30f:	0f b6 10             	movzbl (%rax),%edx
    b312:	83 e2 7f             	and    $0x7f,%edx
    b315:	80 fa 7f             	cmp    $0x7f,%dl
    b318:	75 ee                	jne    b308 <AppendDevicePath+0x38>
    b31a:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b31e:	75 e8                	jne    b308 <AppendDevicePath+0x38>
    b320:	4c 29 c0             	sub    %r8,%rax
    b323:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
    b328:	31 db                	xor    %ebx,%ebx
    b32a:	48 8d 6c 24 18       	lea    0x18(%rsp),%rbp
    b32f:	4c 8d 70 04          	lea    0x4(%rax),%r14
    b333:	4c 8d 64 24 10       	lea    0x10(%rsp),%r12
    b338:	eb 0a                	jmp    b344 <AppendDevicePath+0x74>
    b33a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    b340:	48 83 c3 01          	add    $0x1,%rbx
    b344:	48 89 ee             	mov    %rbp,%rsi
    b347:	4c 89 e7             	mov    %r12,%rdi
    b34a:	e8 01 fe ff ff       	call   b150 <DevicePathInstance>
    b34f:	48 85 c0             	test   %rax,%rax
    b352:	75 ec                	jne    b340 <AppendDevicePath+0x70>
    b354:	4c 89 e8             	mov    %r13,%rax
    b357:	eb 0e                	jmp    b367 <AppendDevicePath+0x97>
    b359:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    b360:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b364:	48 01 d0             	add    %rdx,%rax
    b367:	0f b6 10             	movzbl (%rax),%edx
    b36a:	83 e2 7f             	and    $0x7f,%edx
    b36d:	80 fa 7f             	cmp    $0x7f,%dl
    b370:	75 ee                	jne    b360 <AppendDevicePath+0x90>
    b372:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b376:	75 e8                	jne    b360 <AppendDevicePath+0x90>
    b378:	49 0f af de          	imul   %r14,%rbx
    b37c:	4c 29 e8             	sub    %r13,%rax
    b37f:	4c 8d 74 24 08       	lea    0x8(%rsp),%r14
    b384:	4c 8d 60 04          	lea    0x4(%rax),%r12
    b388:	4c 8d 3d b1 af 00 00 	lea    0xafb1(%rip),%r15        # 16340 <EndInstanceDevicePath>
    b38f:	4a 8d 3c 23          	lea    (%rbx,%r12,1),%rdi
    b393:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
    b398:	e8 83 b8 ff ff       	call   6c20 <AllocatePool>
    b39d:	48 89 04 24          	mov    %rax,(%rsp)
    b3a1:	48 89 c3             	mov    %rax,%rbx
    b3a4:	48 85 c0             	test   %rax,%rax
    b3a7:	75 3e                	jne    b3e7 <AppendDevicePath+0x117>
    b3a9:	eb 64                	jmp    b40f <AppendDevicePath+0x13f>
    b3ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    b3b0:	48 8b 54 24 18       	mov    0x18(%rsp),%rdx
    b3b5:	48 89 df             	mov    %rbx,%rdi
    b3b8:	e8 c3 b9 ff ff       	call   6d80 <CopyMem>
    b3bd:	48 03 5c 24 18       	add    0x18(%rsp),%rbx
    b3c2:	4c 89 e2             	mov    %r12,%rdx
    b3c5:	4c 89 ee             	mov    %r13,%rsi
    b3c8:	48 89 df             	mov    %rbx,%rdi
    b3cb:	4c 01 e3             	add    %r12,%rbx
    b3ce:	e8 ad b9 ff ff       	call   6d80 <CopyMem>
    b3d3:	48 89 df             	mov    %rbx,%rdi
    b3d6:	ba 04 00 00 00       	mov    $0x4,%edx
    b3db:	4c 89 fe             	mov    %r15,%rsi
    b3de:	e8 9d b9 ff ff       	call   6d80 <CopyMem>
    b3e3:	48 83 c3 04          	add    $0x4,%rbx
    b3e7:	48 89 ee             	mov    %rbp,%rsi
    b3ea:	4c 89 f7             	mov    %r14,%rdi
    b3ed:	e8 5e fd ff ff       	call   b150 <DevicePathInstance>
    b3f2:	48 89 c6             	mov    %rax,%rsi
    b3f5:	48 85 c0             	test   %rax,%rax
    b3f8:	75 b6                	jne    b3b0 <AppendDevicePath+0xe0>
    b3fa:	48 8d 7b fc          	lea    -0x4(%rbx),%rdi
    b3fe:	ba 04 00 00 00       	mov    $0x4,%edx
    b403:	48 8d 35 3a af 00 00 	lea    0xaf3a(%rip),%rsi        # 16344 <EndDevicePath>
    b40a:	e8 71 b9 ff ff       	call   6d80 <CopyMem>
    b40f:	48 8b 04 24          	mov    (%rsp),%rax
    b413:	48 83 c4 28          	add    $0x28,%rsp
    b417:	5b                   	pop    %rbx
    b418:	5d                   	pop    %rbp
    b419:	41 5c                	pop    %r12
    b41b:	41 5d                	pop    %r13
    b41d:	41 5e                	pop    %r14
    b41f:	41 5f                	pop    %r15
    b421:	c3                   	ret
    b422:	e8 49 fe ff ff       	call   b270 <DuplicateDevicePath>
    b427:	48 89 04 24          	mov    %rax,(%rsp)
    b42b:	eb e2                	jmp    b40f <AppendDevicePath+0x13f>
    b42d:	48 89 f7             	mov    %rsi,%rdi
    b430:	e8 3b fe ff ff       	call   b270 <DuplicateDevicePath>
    b435:	48 89 04 24          	mov    %rax,(%rsp)
    b439:	eb d4                	jmp    b40f <AppendDevicePath+0x13f>
    b43b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000b440 <AppendDevicePathNode>:
    b440:	f3 0f 1e fa          	endbr64
    b444:	41 56                	push   %r14
    b446:	41 55                	push   %r13
    b448:	49 89 fd             	mov    %rdi,%r13
    b44b:	41 54                	push   %r12
    b44d:	49 89 f4             	mov    %rsi,%r12
    b450:	55                   	push   %rbp
    b451:	48 83 ec 08          	sub    $0x8,%rsp
    b455:	44 0f b7 76 02       	movzwl 0x2(%rsi),%r14d
    b45a:	49 8d 7e 04          	lea    0x4(%r14),%rdi
    b45e:	e8 bd b7 ff ff       	call   6c20 <AllocatePool>
    b463:	48 85 c0             	test   %rax,%rax
    b466:	74 48                	je     b4b0 <AppendDevicePathNode+0x70>
    b468:	48 89 c5             	mov    %rax,%rbp
    b46b:	4c 89 f2             	mov    %r14,%rdx
    b46e:	4c 89 e6             	mov    %r12,%rsi
    b471:	48 89 c7             	mov    %rax,%rdi
    b474:	e8 07 b9 ff ff       	call   6d80 <CopyMem>
    b479:	0f b7 45 02          	movzwl 0x2(%rbp),%eax
    b47d:	48 89 ee             	mov    %rbp,%rsi
    b480:	4c 89 ef             	mov    %r13,%rdi
    b483:	c7 44 05 00 7f ff 04 	movl   $0x4ff7f,0x0(%rbp,%rax,1)
    b48a:	00 
    b48b:	e8 40 fe ff ff       	call   b2d0 <AppendDevicePath>
    b490:	48 89 ef             	mov    %rbp,%rdi
    b493:	49 89 c4             	mov    %rax,%r12
    b496:	e8 a5 b8 ff ff       	call   6d40 <FreePool>
    b49b:	48 83 c4 08          	add    $0x8,%rsp
    b49f:	4c 89 e0             	mov    %r12,%rax
    b4a2:	5d                   	pop    %rbp
    b4a3:	41 5c                	pop    %r12
    b4a5:	41 5d                	pop    %r13
    b4a7:	41 5e                	pop    %r14
    b4a9:	c3                   	ret
    b4aa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    b4b0:	48 83 c4 08          	add    $0x8,%rsp
    b4b4:	45 31 e4             	xor    %r12d,%r12d
    b4b7:	5d                   	pop    %rbp
    b4b8:	4c 89 e0             	mov    %r12,%rax
    b4bb:	41 5c                	pop    %r12
    b4bd:	41 5d                	pop    %r13
    b4bf:	41 5e                	pop    %r14
    b4c1:	c3                   	ret
    b4c2:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    b4c9:	00 00 00 00 
    b4cd:	0f 1f 00             	nopl   (%rax)

000000000000b4d0 <FileDevicePath>:
    b4d0:	f3 0f 1e fa          	endbr64
    b4d4:	41 56                	push   %r14
    b4d6:	49 89 fe             	mov    %rdi,%r14
    b4d9:	48 89 f7             	mov    %rsi,%rdi
    b4dc:	41 55                	push   %r13
    b4de:	41 54                	push   %r12
    b4e0:	55                   	push   %rbp
    b4e1:	48 89 f5             	mov    %rsi,%rbp
    b4e4:	48 83 ec 38          	sub    $0x38,%rsp
    b4e8:	e8 a3 e3 ff ff       	call   9890 <StrSize>
    b4ed:	48 8d 78 08          	lea    0x8(%rax),%rdi
    b4f1:	49 89 c5             	mov    %rax,%r13
    b4f4:	e8 67 b7 ff ff       	call   6c60 <AllocateZeroPool>
    b4f9:	49 89 c4             	mov    %rax,%r12
    b4fc:	48 85 c0             	test   %rax,%rax
    b4ff:	74 7f                	je     b580 <FileDevicePath+0xb0>
    b501:	b8 04 04 00 00       	mov    $0x404,%eax
    b506:	49 8d 7c 24 04       	lea    0x4(%r12),%rdi
    b50b:	4c 89 ea             	mov    %r13,%rdx
    b50e:	48 89 ee             	mov    %rbp,%rsi
    b511:	66 41 89 04 24       	mov    %ax,(%r12)
    b516:	41 8d 45 04          	lea    0x4(%r13),%eax
    b51a:	41 88 44 24 02       	mov    %al,0x2(%r12)
    b51f:	49 8d 45 04          	lea    0x4(%r13),%rax
    b523:	0f b6 c4             	movzbl %ah,%eax
    b526:	41 88 44 24 03       	mov    %al,0x3(%r12)
    b52b:	e8 50 b8 ff ff       	call   6d80 <CopyMem>
    b530:	41 0f b7 44 24 02    	movzwl 0x2(%r12),%eax
    b536:	41 c7 04 04 7f ff 04 	movl   $0x4ff7f,(%r12,%rax,1)
    b53d:	00 
    b53e:	4d 85 f6             	test   %r14,%r14
    b541:	74 3d                	je     b580 <FileDevicePath+0xb0>
    b543:	48 8b 05 86 1c 01 00 	mov    0x11c86(%rip),%rax        # 1d1d0 <BS>
    b54a:	4c 8d 44 24 28       	lea    0x28(%rsp),%r8
    b54f:	48 8d 15 ca ad 00 00 	lea    0xadca(%rip),%rdx        # 16320 <gEfiDevicePathProtocolGuid>
    b556:	4c 89 f1             	mov    %r14,%rcx
    b559:	ff 90 98 00 00 00    	call   *0x98(%rax)
    b55f:	31 ff                	xor    %edi,%edi
    b561:	4c 89 e6             	mov    %r12,%rsi
    b564:	48 85 c0             	test   %rax,%rax
    b567:	48 0f 49 7c 24 28    	cmovns 0x28(%rsp),%rdi
    b56d:	e8 5e fd ff ff       	call   b2d0 <AppendDevicePath>
    b572:	4c 89 e7             	mov    %r12,%rdi
    b575:	48 89 c5             	mov    %rax,%rbp
    b578:	e8 c3 b7 ff ff       	call   6d40 <FreePool>
    b57d:	49 89 ec             	mov    %rbp,%r12
    b580:	48 83 c4 38          	add    $0x38,%rsp
    b584:	4c 89 e0             	mov    %r12,%rax
    b587:	5d                   	pop    %rbp
    b588:	41 5c                	pop    %r12
    b58a:	41 5d                	pop    %r13
    b58c:	41 5e                	pop    %r14
    b58e:	c3                   	ret
    b58f:	90                   	nop

000000000000b590 <UnpackDevicePath>:
    b590:	f3 0f 1e fa          	endbr64
    b594:	41 56                	push   %r14
    b596:	48 89 f8             	mov    %rdi,%rax
    b599:	41 55                	push   %r13
    b59b:	41 54                	push   %r12
    b59d:	55                   	push   %rbp
    b59e:	53                   	push   %rbx
    b59f:	48 89 fb             	mov    %rdi,%rbx
    b5a2:	31 ff                	xor    %edi,%edi
    b5a4:	eb 0d                	jmp    b5b3 <UnpackDevicePath+0x23>
    b5a6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    b5ad:	00 00 00 
    b5b0:	48 01 f0             	add    %rsi,%rax
    b5b3:	0f b7 70 02          	movzwl 0x2(%rax),%esi
    b5b7:	48 01 f7             	add    %rsi,%rdi
    b5ba:	48 89 f9             	mov    %rdi,%rcx
    b5bd:	48 8d 57 04          	lea    0x4(%rdi),%rdx
    b5c1:	83 e1 03             	and    $0x3,%ecx
    b5c4:	48 29 ca             	sub    %rcx,%rdx
    b5c7:	48 85 c9             	test   %rcx,%rcx
    b5ca:	48 0f 45 fa          	cmovne %rdx,%rdi
    b5ce:	0f b6 10             	movzbl (%rax),%edx
    b5d1:	83 e2 7f             	and    $0x7f,%edx
    b5d4:	80 fa 7f             	cmp    $0x7f,%dl
    b5d7:	75 d7                	jne    b5b0 <UnpackDevicePath+0x20>
    b5d9:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b5dd:	75 d1                	jne    b5b0 <UnpackDevicePath+0x20>
    b5df:	e8 7c b6 ff ff       	call   6c60 <AllocateZeroPool>
    b5e4:	49 89 c5             	mov    %rax,%r13
    b5e7:	48 85 c0             	test   %rax,%rax
    b5ea:	74 5b                	je     b647 <UnpackDevicePath+0xb7>
    b5ec:	48 89 c5             	mov    %rax,%rbp
    b5ef:	eb 0e                	jmp    b5ff <UnpackDevicePath+0x6f>
    b5f1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    b5f8:	0f b7 43 02          	movzwl 0x2(%rbx),%eax
    b5fc:	48 01 c3             	add    %rax,%rbx
    b5ff:	44 0f b7 63 02       	movzwl 0x2(%rbx),%r12d
    b604:	48 89 de             	mov    %rbx,%rsi
    b607:	48 89 ef             	mov    %rbp,%rdi
    b60a:	4c 89 e2             	mov    %r12,%rdx
    b60d:	4d 89 e6             	mov    %r12,%r14
    b610:	e8 6b b7 ff ff       	call   6d80 <CopyMem>
    b615:	44 89 e0             	mov    %r12d,%eax
    b618:	83 e0 03             	and    $0x3,%eax
    b61b:	41 83 e6 03          	and    $0x3,%r14d
    b61f:	74 0a                	je     b62b <UnpackDevicePath+0x9b>
    b621:	49 83 c4 04          	add    $0x4,%r12
    b625:	0f b7 c0             	movzwl %ax,%eax
    b628:	49 29 c4             	sub    %rax,%r12
    b62b:	80 4d 00 80          	orb    $0x80,0x0(%rbp)
    b62f:	66 44 89 65 02       	mov    %r12w,0x2(%rbp)
    b634:	0f b6 03             	movzbl (%rbx),%eax
    b637:	4c 01 e5             	add    %r12,%rbp
    b63a:	83 e0 7f             	and    $0x7f,%eax
    b63d:	3c 7f                	cmp    $0x7f,%al
    b63f:	75 b7                	jne    b5f8 <UnpackDevicePath+0x68>
    b641:	80 7b 01 ff          	cmpb   $0xff,0x1(%rbx)
    b645:	75 b1                	jne    b5f8 <UnpackDevicePath+0x68>
    b647:	5b                   	pop    %rbx
    b648:	4c 89 e8             	mov    %r13,%rax
    b64b:	5d                   	pop    %rbp
    b64c:	41 5c                	pop    %r12
    b64e:	41 5d                	pop    %r13
    b650:	41 5e                	pop    %r14
    b652:	c3                   	ret
    b653:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    b65a:	00 00 00 00 
    b65e:	66 90                	xchg   %ax,%ax

000000000000b660 <AppendDevicePathInstance>:
    b660:	f3 0f 1e fa          	endbr64
    b664:	41 57                	push   %r15
    b666:	48 89 f8             	mov    %rdi,%rax
    b669:	41 56                	push   %r14
    b66b:	41 55                	push   %r13
    b66d:	41 54                	push   %r12
    b66f:	49 89 fc             	mov    %rdi,%r12
    b672:	55                   	push   %rbp
    b673:	48 89 f5             	mov    %rsi,%rbp
    b676:	48 85 ff             	test   %rdi,%rdi
    b679:	75 0c                	jne    b687 <AppendDevicePathInstance+0x27>
    b67b:	e9 ab 00 00 00       	jmp    b72b <AppendDevicePathInstance+0xcb>
    b680:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b684:	48 01 d0             	add    %rdx,%rax
    b687:	0f b6 10             	movzbl (%rax),%edx
    b68a:	83 e2 7f             	and    $0x7f,%edx
    b68d:	80 fa 7f             	cmp    $0x7f,%dl
    b690:	75 ee                	jne    b680 <AppendDevicePathInstance+0x20>
    b692:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b696:	75 e8                	jne    b680 <AppendDevicePathInstance+0x20>
    b698:	4c 29 e0             	sub    %r12,%rax
    b69b:	4c 8d 78 04          	lea    0x4(%rax),%r15
    b69f:	48 89 e8             	mov    %rbp,%rax
    b6a2:	eb 0b                	jmp    b6af <AppendDevicePathInstance+0x4f>
    b6a4:	0f 1f 40 00          	nopl   0x0(%rax)
    b6a8:	0f b7 50 02          	movzwl 0x2(%rax),%edx
    b6ac:	48 01 d0             	add    %rdx,%rax
    b6af:	0f b6 10             	movzbl (%rax),%edx
    b6b2:	83 e2 7f             	and    $0x7f,%edx
    b6b5:	80 fa 7f             	cmp    $0x7f,%dl
    b6b8:	75 ee                	jne    b6a8 <AppendDevicePathInstance+0x48>
    b6ba:	80 78 01 ff          	cmpb   $0xff,0x1(%rax)
    b6be:	75 e8                	jne    b6a8 <AppendDevicePathInstance+0x48>
    b6c0:	48 29 e8             	sub    %rbp,%rax
    b6c3:	4c 8d 70 04          	lea    0x4(%rax),%r14
    b6c7:	4b 8d 3c 3e          	lea    (%r14,%r15,1),%rdi
    b6cb:	e8 50 b5 ff ff       	call   6c20 <AllocatePool>
    b6d0:	4c 89 fa             	mov    %r15,%rdx
    b6d3:	4c 89 e6             	mov    %r12,%rsi
    b6d6:	49 89 c5             	mov    %rax,%r13
    b6d9:	48 89 c7             	mov    %rax,%rdi
    b6dc:	e8 9f b6 ff ff       	call   6d80 <CopyMem>
    b6e1:	4c 89 ef             	mov    %r13,%rdi
    b6e4:	eb 11                	jmp    b6f7 <AppendDevicePathInstance+0x97>
    b6e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    b6ed:	00 00 00 
    b6f0:	0f b7 57 02          	movzwl 0x2(%rdi),%edx
    b6f4:	48 01 d7             	add    %rdx,%rdi
    b6f7:	0f b6 17             	movzbl (%rdi),%edx
    b6fa:	83 e2 7f             	and    $0x7f,%edx
    b6fd:	80 fa 7f             	cmp    $0x7f,%dl
    b700:	75 ee                	jne    b6f0 <AppendDevicePathInstance+0x90>
    b702:	80 7f 01 ff          	cmpb   $0xff,0x1(%rdi)
    b706:	75 e8                	jne    b6f0 <AppendDevicePathInstance+0x90>
    b708:	0f b7 47 02          	movzwl 0x2(%rdi),%eax
    b70c:	c6 47 01 01          	movb   $0x1,0x1(%rdi)
    b710:	4c 89 f2             	mov    %r14,%rdx
    b713:	48 89 ee             	mov    %rbp,%rsi
    b716:	48 01 c7             	add    %rax,%rdi
    b719:	e8 62 b6 ff ff       	call   6d80 <CopyMem>
    b71e:	5d                   	pop    %rbp
    b71f:	4c 89 e8             	mov    %r13,%rax
    b722:	41 5c                	pop    %r12
    b724:	41 5d                	pop    %r13
    b726:	41 5e                	pop    %r14
    b728:	41 5f                	pop    %r15
    b72a:	c3                   	ret
    b72b:	5d                   	pop    %rbp
    b72c:	48 89 f7             	mov    %rsi,%rdi
    b72f:	41 5c                	pop    %r12
    b731:	41 5d                	pop    %r13
    b733:	41 5e                	pop    %r14
    b735:	41 5f                	pop    %r15
    b737:	e9 34 fb ff ff       	jmp    b270 <DuplicateDevicePath>
    b73c:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000b740 <LibDevicePathToInterface>:
    b740:	f3 0f 1e fa          	endbr64
    b744:	41 54                	push   %r12
    b746:	48 89 f9             	mov    %rdi,%rcx
    b749:	49 89 fc             	mov    %rdi,%r12
    b74c:	53                   	push   %rbx
    b74d:	48 89 d3             	mov    %rdx,%rbx
    b750:	48 83 ec 48          	sub    $0x48,%rsp
    b754:	48 8b 05 75 1a 01 00 	mov    0x11a75(%rip),%rax        # 1d1d0 <BS>
    b75b:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    b760:	48 8d 54 24 28       	lea    0x28(%rsp),%rdx
    b765:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    b76a:	ff 90 b8 00 00 00    	call   *0xb8(%rax)
    b770:	48 85 c0             	test   %rax,%rax
    b773:	78 1a                	js     b78f <LibDevicePathToInterface+0x4f>
    b775:	48 b8 0e 00 00 00 00 	movabs $0x800000000000000e,%rax
    b77c:	00 00 80 
    b77f:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    b784:	0f b6 11             	movzbl (%rcx),%edx
    b787:	83 e2 7f             	and    $0x7f,%edx
    b78a:	80 fa 7f             	cmp    $0x7f,%dl
    b78d:	74 11                	je     b7a0 <LibDevicePathToInterface+0x60>
    b78f:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    b796:	48 83 c4 48          	add    $0x48,%rsp
    b79a:	5b                   	pop    %rbx
    b79b:	41 5c                	pop    %r12
    b79d:	c3                   	ret
    b79e:	66 90                	xchg   %ax,%ax
    b7a0:	80 79 01 ff          	cmpb   $0xff,0x1(%rcx)
    b7a4:	75 e9                	jne    b78f <LibDevicePathToInterface+0x4f>
    b7a6:	48 8b 05 23 1a 01 00 	mov    0x11a23(%rip),%rax        # 1d1d0 <BS>
    b7ad:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
    b7b2:	49 89 d8             	mov    %rbx,%r8
    b7b5:	4c 89 e2             	mov    %r12,%rdx
    b7b8:	ff 90 98 00 00 00    	call   *0x98(%rax)
    b7be:	48 85 c0             	test   %rax,%rax
    b7c1:	78 cc                	js     b78f <LibDevicePathToInterface+0x4f>
    b7c3:	48 83 c4 48          	add    $0x48,%rsp
    b7c7:	5b                   	pop    %rbx
    b7c8:	41 5c                	pop    %r12
    b7ca:	c3                   	ret
    b7cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000b7d0 <DevicePathToStr>:
    b7d0:	f3 0f 1e fa          	endbr64
    b7d4:	41 57                	push   %r15
    b7d6:	be 18 00 00 00       	mov    $0x18,%esi
    b7db:	41 56                	push   %r14
    b7dd:	41 55                	push   %r13
    b7df:	4c 8d 2d 0a a2 00 00 	lea    0xa20a(%rip),%r13        # 159f0 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0xbf0>
    b7e6:	41 54                	push   %r12
    b7e8:	4c 8d 25 61 f1 ff ff 	lea    -0xe9f(%rip),%r12        # a950 <_DevPathNodeUnknown>
    b7ef:	55                   	push   %rbp
    b7f0:	48 89 fd             	mov    %rdi,%rbp
    b7f3:	53                   	push   %rbx
    b7f4:	48 83 ec 38          	sub    $0x38,%rsp
    b7f8:	48 8d 5c 24 10       	lea    0x10(%rsp),%rbx
    b7fd:	48 89 df             	mov    %rbx,%rdi
    b800:	e8 5b b5 ff ff       	call   6d60 <ZeroMem>
    b805:	48 89 ef             	mov    %rbp,%rdi
    b808:	48 8d 2d d1 ea ff ff 	lea    -0x152f(%rip),%rbp        # a2e0 <_DevPathEndInstance>
    b80f:	e8 7c fd ff ff       	call   b590 <UnpackDevicePath>
    b814:	49 89 c6             	mov    %rax,%r14
    b817:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    b81c:	41 0f b6 16          	movzbl (%r14),%edx
    b820:	83 e2 7f             	and    $0x7f,%edx
    b823:	80 fa 7f             	cmp    $0x7f,%dl
    b826:	74 71                	je     b899 <DevicePathToStr+0xc9>
    b828:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    b82f:	00 
    b830:	4c 8b 3d d1 ae 00 00 	mov    0xaed1(%rip),%r15        # 16708 <DevPathTable+0x8>
    b837:	48 8d 05 c2 ae 00 00 	lea    0xaec2(%rip),%rax        # 16700 <DevPathTable>
    b83e:	4d 85 ff             	test   %r15,%r15
    b841:	75 1e                	jne    b861 <DevicePathToStr+0x91>
    b843:	e9 a0 00 00 00       	jmp    b8e8 <DevicePathToStr+0x118>
    b848:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    b84f:	00 
    b850:	4c 8b 78 18          	mov    0x18(%rax),%r15
    b854:	48 83 c0 10          	add    $0x10,%rax
    b858:	4d 85 ff             	test   %r15,%r15
    b85b:	0f 84 87 00 00 00    	je     b8e8 <DevicePathToStr+0x118>
    b861:	38 10                	cmp    %dl,(%rax)
    b863:	75 eb                	jne    b850 <DevicePathToStr+0x80>
    b865:	0f b6 48 01          	movzbl 0x1(%rax),%ecx
    b869:	41 38 4e 01          	cmp    %cl,0x1(%r14)
    b86d:	75 e1                	jne    b850 <DevicePathToStr+0x80>
    b86f:	48 83 7c 24 18 00    	cmpq   $0x0,0x18(%rsp)
    b875:	74 05                	je     b87c <DevicePathToStr+0xac>
    b877:	49 39 ef             	cmp    %rbp,%r15
    b87a:	75 77                	jne    b8f3 <DevicePathToStr+0x123>
    b87c:	4c 89 f6             	mov    %r14,%rsi
    b87f:	48 89 df             	mov    %rbx,%rdi
    b882:	41 ff d7             	call   *%r15
    b885:	41 0f b7 46 02       	movzwl 0x2(%r14),%eax
    b88a:	49 01 c6             	add    %rax,%r14
    b88d:	41 0f b6 16          	movzbl (%r14),%edx
    b891:	83 e2 7f             	and    $0x7f,%edx
    b894:	80 fa 7f             	cmp    $0x7f,%dl
    b897:	75 97                	jne    b830 <DevicePathToStr+0x60>
    b899:	41 80 7e 01 ff       	cmpb   $0xff,0x1(%r14)
    b89e:	75 90                	jne    b830 <DevicePathToStr+0x60>
    b8a0:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
    b8a5:	e8 96 b4 ff ff       	call   6d40 <FreePool>
    b8aa:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    b8af:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
    b8b4:	48 8d 74 00 02       	lea    0x2(%rax,%rax,1),%rsi
    b8b9:	48 89 f2             	mov    %rsi,%rdx
    b8bc:	e8 ef b3 ff ff       	call   6cb0 <ReallocatePool>
    b8c1:	48 8b 54 24 18       	mov    0x18(%rsp),%rdx
    b8c6:	31 c9                	xor    %ecx,%ecx
    b8c8:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    b8cd:	66 89 0c 50          	mov    %cx,(%rax,%rdx,2)
    b8d1:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
    b8d6:	48 83 c4 38          	add    $0x38,%rsp
    b8da:	5b                   	pop    %rbx
    b8db:	5d                   	pop    %rbp
    b8dc:	41 5c                	pop    %r12
    b8de:	41 5d                	pop    %r13
    b8e0:	41 5e                	pop    %r14
    b8e2:	41 5f                	pop    %r15
    b8e4:	c3                   	ret
    b8e5:	0f 1f 00             	nopl   (%rax)
    b8e8:	48 83 7c 24 18 00    	cmpq   $0x0,0x18(%rsp)
    b8ee:	4d 89 e7             	mov    %r12,%r15
    b8f1:	74 89                	je     b87c <DevicePathToStr+0xac>
    b8f3:	4c 89 ee             	mov    %r13,%rsi
    b8f6:	48 89 df             	mov    %rbx,%rdi
    b8f9:	31 c0                	xor    %eax,%eax
    b8fb:	e8 d0 d3 ff ff       	call   8cd0 <CatPrint>
    b900:	e9 77 ff ff ff       	jmp    b87c <DevicePathToStr+0xac>
    b905:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    b90c:	00 00 00 00 

000000000000b910 <LibMatchDevicePaths>:
    b910:	f3 0f 1e fa          	endbr64
    b914:	48 85 ff             	test   %rdi,%rdi
    b917:	74 67                	je     b980 <LibMatchDevicePaths+0x70>
    b919:	41 54                	push   %r12
    b91b:	55                   	push   %rbp
    b91c:	53                   	push   %rbx
    b91d:	48 89 f3             	mov    %rsi,%rbx
    b920:	48 83 ec 10          	sub    $0x10,%rsp
    b924:	48 85 f6             	test   %rsi,%rsi
    b927:	74 3c                	je     b965 <LibMatchDevicePaths+0x55>
    b929:	48 89 3c 24          	mov    %rdi,(%rsp)
    b92d:	4c 8d 64 24 08       	lea    0x8(%rsp),%r12
    b932:	48 89 e5             	mov    %rsp,%rbp
    b935:	eb 1b                	jmp    b952 <LibMatchDevicePaths+0x42>
    b937:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    b93e:	00 00 
    b940:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
    b945:	48 89 df             	mov    %rbx,%rdi
    b948:	e8 43 b4 ff ff       	call   6d90 <CompareMem>
    b94d:	48 85 c0             	test   %rax,%rax
    b950:	74 1e                	je     b970 <LibMatchDevicePaths+0x60>
    b952:	4c 89 e6             	mov    %r12,%rsi
    b955:	48 89 ef             	mov    %rbp,%rdi
    b958:	e8 f3 f7 ff ff       	call   b150 <DevicePathInstance>
    b95d:	48 89 c6             	mov    %rax,%rsi
    b960:	48 85 c0             	test   %rax,%rax
    b963:	75 db                	jne    b940 <LibMatchDevicePaths+0x30>
    b965:	48 83 c4 10          	add    $0x10,%rsp
    b969:	31 c0                	xor    %eax,%eax
    b96b:	5b                   	pop    %rbx
    b96c:	5d                   	pop    %rbp
    b96d:	41 5c                	pop    %r12
    b96f:	c3                   	ret
    b970:	48 83 c4 10          	add    $0x10,%rsp
    b974:	b8 01 00 00 00       	mov    $0x1,%eax
    b979:	5b                   	pop    %rbx
    b97a:	5d                   	pop    %rbp
    b97b:	41 5c                	pop    %r12
    b97d:	c3                   	ret
    b97e:	66 90                	xchg   %ax,%ax
    b980:	31 c0                	xor    %eax,%eax
    b982:	c3                   	ret
    b983:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    b98a:	00 00 00 00 
    b98e:	66 90                	xchg   %ax,%ax

000000000000b990 <LibDuplicateDevicePathInstance>:
    b990:	f3 0f 1e fa          	endbr64
    b994:	41 54                	push   %r12
    b996:	45 31 e4             	xor    %r12d,%r12d
    b999:	55                   	push   %rbp
    b99a:	48 83 ec 18          	sub    $0x18,%rsp
    b99e:	48 89 3c 24          	mov    %rdi,(%rsp)
    b9a2:	48 8d 74 24 08       	lea    0x8(%rsp),%rsi
    b9a7:	48 89 e7             	mov    %rsp,%rdi
    b9aa:	48 c7 44 24 08 00 00 	movq   $0x0,0x8(%rsp)
    b9b1:	00 00 
    b9b3:	e8 98 f7 ff ff       	call   b150 <DevicePathInstance>
    b9b8:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
    b9bd:	48 85 ff             	test   %rdi,%rdi
    b9c0:	74 4c                	je     ba0e <LibDuplicateDevicePathInstance+0x7e>
    b9c2:	48 83 c7 04          	add    $0x4,%rdi
    b9c6:	48 89 c5             	mov    %rax,%rbp
    b9c9:	e8 52 b2 ff ff       	call   6c20 <AllocatePool>
    b9ce:	49 89 c4             	mov    %rax,%r12
    b9d1:	48 85 c0             	test   %rax,%rax
    b9d4:	74 38                	je     ba0e <LibDuplicateDevicePathInstance+0x7e>
    b9d6:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
    b9db:	48 89 c7             	mov    %rax,%rdi
    b9de:	48 89 ee             	mov    %rbp,%rsi
    b9e1:	e8 9a b3 ff ff       	call   6d80 <CopyMem>
    b9e6:	41 0f b7 44 24 02    	movzwl 0x2(%r12),%eax
    b9ec:	4c 01 e0             	add    %r12,%rax
    b9ef:	48 89 04 24          	mov    %rax,(%rsp)
    b9f3:	c6 00 7f             	movb   $0x7f,(%rax)
    b9f6:	48 8b 04 24          	mov    (%rsp),%rax
    b9fa:	c6 40 01 ff          	movb   $0xff,0x1(%rax)
    b9fe:	48 8b 04 24          	mov    (%rsp),%rax
    ba02:	c6 40 02 04          	movb   $0x4,0x2(%rax)
    ba06:	48 8b 04 24          	mov    (%rsp),%rax
    ba0a:	c6 40 03 00          	movb   $0x0,0x3(%rax)
    ba0e:	48 83 c4 18          	add    $0x18,%rsp
    ba12:	4c 89 e0             	mov    %r12,%rax
    ba15:	5d                   	pop    %rbp
    ba16:	41 5c                	pop    %r12
    ba18:	c3                   	ret
    ba19:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

000000000000ba20 <StatusToString>:
    ba20:	f3 0f 1e fa          	endbr64
    ba24:	48 89 f1             	mov    %rsi,%rcx
    ba27:	48 8b 35 9a ae 00 00 	mov    0xae9a(%rip),%rsi        # 168c8 <ErrorCodeTable+0x8>
    ba2e:	48 85 f6             	test   %rsi,%rsi
    ba31:	74 2d                	je     ba60 <StatusToString+0x40>
    ba33:	48 8d 05 86 ae 00 00 	lea    0xae86(%rip),%rax        # 168c0 <ErrorCodeTable>
    ba3a:	eb 11                	jmp    ba4d <StatusToString+0x2d>
    ba3c:	0f 1f 40 00          	nopl   0x0(%rax)
    ba40:	48 8b 70 18          	mov    0x18(%rax),%rsi
    ba44:	48 83 c0 10          	add    $0x10,%rax
    ba48:	48 85 f6             	test   %rsi,%rsi
    ba4b:	74 13                	je     ba60 <StatusToString+0x40>
    ba4d:	48 39 08             	cmp    %rcx,(%rax)
    ba50:	75 ee                	jne    ba40 <StatusToString+0x20>
    ba52:	e9 b9 dd ff ff       	jmp    9810 <StrCpy>
    ba57:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    ba5e:	00 00 
    ba60:	48 8d 15 99 9f 00 00 	lea    0x9f99(%rip),%rdx        # 15a00 <CSWTCH.43+0xc>
    ba67:	31 f6                	xor    %esi,%esi
    ba69:	31 c0                	xor    %eax,%eax
    ba6b:	e9 e0 d3 ff ff       	jmp    8e50 <UnicodeSPrint>

000000000000ba70 <LibCreateProtocolNotifyEvent>:
    ba70:	f3 0f 1e fa          	endbr64
    ba74:	41 54                	push   %r12
    ba76:	49 89 c9             	mov    %rcx,%r9
    ba79:	49 89 fc             	mov    %rdi,%r12
    ba7c:	b9 00 02 00 00       	mov    $0x200,%ecx
    ba81:	53                   	push   %rbx
    ba82:	4c 89 c3             	mov    %r8,%rbx
    ba85:	49 89 d0             	mov    %rdx,%r8
    ba88:	48 89 f2             	mov    %rsi,%rdx
    ba8b:	48 83 ec 48          	sub    $0x48,%rsp
    ba8f:	48 8d 44 24 38       	lea    0x38(%rsp),%rax
    ba94:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    ba99:	48 8b 05 30 17 01 00 	mov    0x11730(%rip),%rax        # 1d1d0 <BS>
    baa0:	ff 50 50             	call   *0x50(%rax)
    baa3:	48 85 c0             	test   %rax,%rax
    baa6:	78 40                	js     bae8 <LibCreateProtocolNotifyEvent+0x78>
    baa8:	48 8b 05 21 17 01 00 	mov    0x11721(%rip),%rax        # 1d1d0 <BS>
    baaf:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    bab4:	49 89 d8             	mov    %rbx,%r8
    bab7:	4c 89 e1             	mov    %r12,%rcx
    baba:	ff 90 a8 00 00 00    	call   *0xa8(%rax)
    bac0:	48 85 c0             	test   %rax,%rax
    bac3:	78 23                	js     bae8 <LibCreateProtocolNotifyEvent+0x78>
    bac5:	48 8b 05 04 17 01 00 	mov    0x11704(%rip),%rax        # 1d1d0 <BS>
    bacc:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
    bad1:	ff 50 68             	call   *0x68(%rax)
    bad4:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    bad9:	48 83 c4 48          	add    $0x48,%rsp
    badd:	5b                   	pop    %rbx
    bade:	41 5c                	pop    %r12
    bae0:	c3                   	ret
    bae1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    bae8:	48 83 c4 48          	add    $0x48,%rsp
    baec:	31 c0                	xor    %eax,%eax
    baee:	5b                   	pop    %rbx
    baef:	41 5c                	pop    %r12
    baf1:	c3                   	ret
    baf2:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    baf9:	00 00 00 00 
    bafd:	0f 1f 00             	nopl   (%rax)

000000000000bb00 <WaitForSingleEvent>:
    bb00:	f3 0f 1e fa          	endbr64
    bb04:	41 54                	push   %r12
    bb06:	53                   	push   %rbx
    bb07:	48 83 ec 68          	sub    $0x68,%rsp
    bb0b:	48 8b 05 be 16 01 00 	mov    0x116be(%rip),%rax        # 1d1d0 <BS>
    bb12:	48 89 7c 24 38       	mov    %rdi,0x38(%rsp)
    bb17:	48 85 f6             	test   %rsi,%rsi
    bb1a:	0f 84 a0 00 00 00    	je     bbc0 <WaitForSingleEvent+0xc0>
    bb20:	48 8d 54 24 48       	lea    0x48(%rsp),%rdx
    bb25:	48 89 f3             	mov    %rsi,%rbx
    bb28:	45 31 c9             	xor    %r9d,%r9d
    bb2b:	45 31 c0             	xor    %r8d,%r8d
    bb2e:	48 89 54 24 20       	mov    %rdx,0x20(%rsp)
    bb33:	b9 00 00 00 80       	mov    $0x80000000,%ecx
    bb38:	31 d2                	xor    %edx,%edx
    bb3a:	ff 50 50             	call   *0x50(%rax)
    bb3d:	49 89 c4             	mov    %rax,%r12
    bb40:	48 85 c0             	test   %rax,%rax
    bb43:	78 6f                	js     bbb4 <WaitForSingleEvent+0xb4>
    bb45:	48 8b 05 84 16 01 00 	mov    0x11684(%rip),%rax        # 1d1d0 <BS>
    bb4c:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    bb51:	49 89 d8             	mov    %rbx,%r8
    bb54:	ba 02 00 00 00       	mov    $0x2,%edx
    bb59:	ff 50 58             	call   *0x58(%rax)
    bb5c:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    bb61:	b9 02 00 00 00       	mov    $0x2,%ecx
    bb66:	48 8d 54 24 50       	lea    0x50(%rsp),%rdx
    bb6b:	4c 8d 44 24 40       	lea    0x40(%rsp),%r8
    bb70:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
    bb75:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    bb7a:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
    bb7f:	48 8b 05 4a 16 01 00 	mov    0x1164a(%rip),%rax        # 1d1d0 <BS>
    bb86:	ff 50 60             	call   *0x60(%rax)
    bb89:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    bb8e:	49 89 c4             	mov    %rax,%r12
    bb91:	48 8b 05 38 16 01 00 	mov    0x11638(%rip),%rax        # 1d1d0 <BS>
    bb98:	ff 50 70             	call   *0x70(%rax)
    bb9b:	4d 85 e4             	test   %r12,%r12
    bb9e:	78 14                	js     bbb4 <WaitForSingleEvent+0xb4>
    bba0:	48 b8 12 00 00 00 00 	movabs $0x8000000000000012,%rax
    bba7:	00 00 80 
    bbaa:	48 83 7c 24 40 01    	cmpq   $0x1,0x40(%rsp)
    bbb0:	4c 0f 44 e0          	cmove  %rax,%r12
    bbb4:	48 83 c4 68          	add    $0x68,%rsp
    bbb8:	4c 89 e0             	mov    %r12,%rax
    bbbb:	5b                   	pop    %rbx
    bbbc:	41 5c                	pop    %r12
    bbbe:	c3                   	ret
    bbbf:	90                   	nop
    bbc0:	48 8d 54 24 38       	lea    0x38(%rsp),%rdx
    bbc5:	4c 8d 44 24 40       	lea    0x40(%rsp),%r8
    bbca:	b9 01 00 00 00       	mov    $0x1,%ecx
    bbcf:	ff 50 60             	call   *0x60(%rax)
    bbd2:	48 83 c4 68          	add    $0x68,%rsp
    bbd6:	49 89 c4             	mov    %rax,%r12
    bbd9:	5b                   	pop    %rbx
    bbda:	4c 89 e0             	mov    %r12,%rax
    bbdd:	41 5c                	pop    %r12
    bbdf:	c3                   	ret

000000000000bbe0 <WaitForEventWithTimeout>:
    bbe0:	f3 0f 1e fa          	endbr64
    bbe4:	41 57                	push   %r15
    bbe6:	41 56                	push   %r14
    bbe8:	49 89 fe             	mov    %rdi,%r14
    bbeb:	41 55                	push   %r13
    bbed:	49 89 d5             	mov    %rdx,%r13
    bbf0:	41 54                	push   %r12
    bbf2:	49 89 cc             	mov    %rcx,%r12
    bbf5:	55                   	push   %rbp
    bbf6:	4c 89 c5             	mov    %r8,%rbp
    bbf9:	53                   	push   %rbx
    bbfa:	48 89 f3             	mov    %rsi,%rbx
    bbfd:	48 83 ec 38          	sub    $0x38,%rsp
    bc01:	44 89 4c 24 2c       	mov    %r9d,0x2c(%rsp)
    bc06:	4c 8b 7c 24 70       	mov    0x70(%rsp),%r15
    bc0b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    bc10:	4c 89 ee             	mov    %r13,%rsi
    bc13:	4c 89 e7             	mov    %r12,%rdi
    bc16:	31 c0                	xor    %eax,%eax
    bc18:	48 89 d9             	mov    %rbx,%rcx
    bc1b:	48 89 ea             	mov    %rbp,%rdx
    bc1e:	e8 ad d5 ff ff       	call   91d0 <PrintAt>
    bc23:	be 80 96 98 00       	mov    $0x989680,%esi
    bc28:	4c 89 f7             	mov    %r14,%rdi
    bc2b:	e8 d0 fe ff ff       	call   bb00 <WaitForSingleEvent>
    bc30:	48 85 c0             	test   %rax,%rax
    bc33:	75 19                	jne    bc4e <WaitForEventWithTimeout+0x6e>
    bc35:	48 8b 05 9c 15 01 00 	mov    0x1159c(%rip),%rax        # 1d1d8 <ST>
    bc3c:	4c 89 fa             	mov    %r15,%rdx
    bc3f:	48 8b 40 30          	mov    0x30(%rax),%rax
    bc43:	48 89 c1             	mov    %rax,%rcx
    bc46:	ff 50 08             	call   *0x8(%rax)
    bc49:	48 85 c0             	test   %rax,%rax
    bc4c:	79 17                	jns    bc65 <WaitForEventWithTimeout+0x85>
    bc4e:	48 85 db             	test   %rbx,%rbx
    bc51:	75 bd                	jne    bc10 <WaitForEventWithTimeout+0x30>
    bc53:	48 8d 74 24 2c       	lea    0x2c(%rsp),%rsi
    bc58:	ba 04 00 00 00       	mov    $0x4,%edx
    bc5d:	4c 89 ff             	mov    %r15,%rdi
    bc60:	e8 1b b1 ff ff       	call   6d80 <CopyMem>
    bc65:	48 83 c4 38          	add    $0x38,%rsp
    bc69:	5b                   	pop    %rbx
    bc6a:	5d                   	pop    %rbp
    bc6b:	41 5c                	pop    %r12
    bc6d:	41 5d                	pop    %r13
    bc6f:	41 5e                	pop    %r14
    bc71:	41 5f                	pop    %r15
    bc73:	c3                   	ret
    bc74:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    bc7b:	00 00 00 
    bc7e:	66 90                	xchg   %ax,%ax

000000000000bc80 <LibLocateHandle>:
    bc80:	f3 0f 1e fa          	endbr64
    bc84:	41 57                	push   %r15
    bc86:	41 56                	push   %r14
    bc88:	41 55                	push   %r13
    bc8a:	41 89 fd             	mov    %edi,%r13d
    bc8d:	41 54                	push   %r12
    bc8f:	49 89 f4             	mov    %rsi,%r12
    bc92:	55                   	push   %rbp
    bc93:	48 89 d5             	mov    %rdx,%rbp
    bc96:	ba 90 01 00 00       	mov    $0x190,%edx
    bc9b:	53                   	push   %rbx
    bc9c:	4c 89 c3             	mov    %r8,%rbx
    bc9f:	48 83 ec 58          	sub    $0x58,%rsp
    bca3:	49 c7 00 00 00 00 00 	movq   $0x0,(%r8)
    bcaa:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
    bcaf:	4c 8d 74 24 40       	lea    0x40(%rsp),%r14
    bcb4:	4c 8d 7c 24 48       	lea    0x48(%rsp),%r15
    bcb9:	48 c7 44 24 40 00 00 	movq   $0x0,0x40(%rsp)
    bcc0:	00 00 
    bcc2:	48 c7 44 24 48 90 01 	movq   $0x190,0x48(%rsp)
    bcc9:	00 00 
    bccb:	eb 2e                	jmp    bcfb <LibLocateHandle+0x7b>
    bccd:	0f 1f 00             	nopl   (%rax)
    bcd0:	48 8b 03             	mov    (%rbx),%rax
    bcd3:	4c 89 e2             	mov    %r12,%rdx
    bcd6:	4d 89 f9             	mov    %r15,%r9
    bcd9:	49 89 e8             	mov    %rbp,%r8
    bcdc:	44 89 e9             	mov    %r13d,%ecx
    bcdf:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    bce4:	48 8b 05 e5 14 01 00 	mov    0x114e5(%rip),%rax        # 1d1d0 <BS>
    bceb:	ff 90 b0 00 00 00    	call   *0xb0(%rax)
    bcf1:	48 8b 54 24 48       	mov    0x48(%rsp),%rdx
    bcf6:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
    bcfb:	48 89 de             	mov    %rbx,%rsi
    bcfe:	4c 89 f7             	mov    %r14,%rdi
    bd01:	e8 9a b0 ff ff       	call   6da0 <GrowBuffer>
    bd06:	84 c0                	test   %al,%al
    bd08:	75 c6                	jne    bcd0 <LibLocateHandle+0x50>
    bd0a:	4c 8b 44 24 40       	mov    0x40(%rsp),%r8
    bd0f:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    bd14:	31 d2                	xor    %edx,%edx
    bd16:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
    bd1b:	48 c1 e8 03          	shr    $0x3,%rax
    bd1f:	4d 85 c0             	test   %r8,%r8
    bd22:	48 0f 48 c2          	cmovs  %rdx,%rax
    bd26:	48 89 01             	mov    %rax,(%rcx)
    bd29:	48 83 c4 58          	add    $0x58,%rsp
    bd2d:	4c 89 c0             	mov    %r8,%rax
    bd30:	5b                   	pop    %rbx
    bd31:	5d                   	pop    %rbp
    bd32:	41 5c                	pop    %r12
    bd34:	41 5d                	pop    %r13
    bd36:	41 5e                	pop    %r14
    bd38:	41 5f                	pop    %r15
    bd3a:	c3                   	ret
    bd3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000bd40 <LibLocateProtocol>:
    bd40:	f3 0f 1e fa          	endbr64
    bd44:	41 55                	push   %r13
    bd46:	31 d2                	xor    %edx,%edx
    bd48:	41 54                	push   %r12
    bd4a:	49 89 f4             	mov    %rsi,%r12
    bd4d:	55                   	push   %rbp
    bd4e:	48 89 fd             	mov    %rdi,%rbp
    bd51:	53                   	push   %rbx
    bd52:	48 83 ec 48          	sub    $0x48,%rsp
    bd56:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    bd5d:	48 89 fe             	mov    %rdi,%rsi
    bd60:	bf 02 00 00 00       	mov    $0x2,%edi
    bd65:	48 8d 4c 24 30       	lea    0x30(%rsp),%rcx
    bd6a:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    bd6f:	e8 0c ff ff ff       	call   bc80 <LibLocateHandle>
    bd74:	48 85 c0             	test   %rax,%rax
    bd77:	78 5a                	js     bdd3 <LibLocateProtocol+0x93>
    bd79:	4c 8b 6c 24 30       	mov    0x30(%rsp),%r13
    bd7e:	4d 85 ed             	test   %r13,%r13
    bd81:	74 37                	je     bdba <LibLocateProtocol+0x7a>
    bd83:	31 db                	xor    %ebx,%ebx
    bd85:	eb 12                	jmp    bd99 <LibLocateProtocol+0x59>
    bd87:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    bd8e:	00 00 
    bd90:	48 83 c3 01          	add    $0x1,%rbx
    bd94:	4c 39 eb             	cmp    %r13,%rbx
    bd97:	74 21                	je     bdba <LibLocateProtocol+0x7a>
    bd99:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    bd9e:	4d 89 e0             	mov    %r12,%r8
    bda1:	48 89 ea             	mov    %rbp,%rdx
    bda4:	48 8b 0c d8          	mov    (%rax,%rbx,8),%rcx
    bda8:	48 8b 05 21 14 01 00 	mov    0x11421(%rip),%rax        # 1d1d0 <BS>
    bdaf:	ff 90 98 00 00 00    	call   *0x98(%rax)
    bdb5:	48 85 c0             	test   %rax,%rax
    bdb8:	78 d6                	js     bd90 <LibLocateProtocol+0x50>
    bdba:	48 8b 7c 24 38       	mov    0x38(%rsp),%rdi
    bdbf:	48 85 ff             	test   %rdi,%rdi
    bdc2:	74 0f                	je     bdd3 <LibLocateProtocol+0x93>
    bdc4:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    bdc9:	e8 72 af ff ff       	call   6d40 <FreePool>
    bdce:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    bdd3:	48 83 c4 48          	add    $0x48,%rsp
    bdd7:	5b                   	pop    %rbx
    bdd8:	5d                   	pop    %rbp
    bdd9:	41 5c                	pop    %r12
    bddb:	41 5d                	pop    %r13
    bddd:	c3                   	ret
    bdde:	66 90                	xchg   %ax,%ax

000000000000bde0 <LibLocateHandleByDiskSignature>:
    bde0:	f3 0f 1e fa          	endbr64
    bde4:	41 57                	push   %r15
    bde6:	4c 8d 3d c3 a4 00 00 	lea    0xa4c3(%rip),%r15        # 162b0 <gEfiBlockIoProtocolGuid>
    bded:	41 56                	push   %r14
    bdef:	41 55                	push   %r13
    bdf1:	41 54                	push   %r12
    bdf3:	55                   	push   %rbp
    bdf4:	53                   	push   %rbx
    bdf5:	48 89 cb             	mov    %rcx,%rbx
    bdf8:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
    bdff:	48 89 54 24 48       	mov    %rdx,0x48(%rsp)
    be04:	4c 8d 64 24 70       	lea    0x70(%rsp),%r12
    be09:	ba 90 01 00 00       	mov    $0x190,%edx
    be0e:	48 8d 6c 24 60       	lea    0x60(%rsp),%rbp
    be13:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
    be18:	40 88 7c 24 40       	mov    %dil,0x40(%rsp)
    be1d:	40 88 74 24 5d       	mov    %sil,0x5d(%rsp)
    be22:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
    be29:	00 00 
    be2b:	48 c7 44 24 70 00 00 	movq   $0x0,0x70(%rsp)
    be32:	00 00 
    be34:	48 c7 44 24 68 90 01 	movq   $0x190,0x68(%rsp)
    be3b:	00 00 
    be3d:	eb 32                	jmp    be71 <LibLocateHandleByDiskSignature+0x91>
    be3f:	90                   	nop
    be40:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
    be45:	4c 89 fa             	mov    %r15,%rdx
    be48:	4c 8d 4c 24 68       	lea    0x68(%rsp),%r9
    be4d:	45 31 c0             	xor    %r8d,%r8d
    be50:	b9 02 00 00 00       	mov    $0x2,%ecx
    be55:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    be5a:	48 8b 05 6f 13 01 00 	mov    0x1136f(%rip),%rax        # 1d1d0 <BS>
    be61:	ff 90 b0 00 00 00    	call   *0xb0(%rax)
    be67:	48 8b 54 24 68       	mov    0x68(%rsp),%rdx
    be6c:	48 89 44 24 60       	mov    %rax,0x60(%rsp)
    be71:	4c 89 e6             	mov    %r12,%rsi
    be74:	48 89 ef             	mov    %rbp,%rdi
    be77:	e8 24 af ff ff       	call   6da0 <GrowBuffer>
    be7c:	84 c0                	test   %al,%al
    be7e:	75 c0                	jne    be40 <LibLocateHandleByDiskSignature+0x60>
    be80:	48 8b 6c 24 68       	mov    0x68(%rsp),%rbp
    be85:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    be8a:	48 c1 ed 03          	shr    $0x3,%rbp
    be8e:	48 83 7c 24 60 00    	cmpq   $0x0,0x60(%rsp)
    be94:	0f 88 f4 01 00 00    	js     c08e <LibLocateHandleByDiskSignature+0x2ae>
    be9a:	48 85 ed             	test   %rbp,%rbp
    be9d:	0f 84 eb 01 00 00    	je     c08e <LibLocateHandleByDiskSignature+0x2ae>
    bea3:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    beaa:	45 31 ed             	xor    %r13d,%r13d
    bead:	4c 8d 74 24 78       	lea    0x78(%rsp),%r14
    beb2:	4c 8d 3d 67 a4 00 00 	lea    0xa467(%rip),%r15        # 16320 <gEfiDevicePathProtocolGuid>
    beb9:	eb 24                	jmp    bedf <LibLocateHandleByDiskSignature+0xff>
    bebb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    bec0:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
    bec5:	49 83 c5 01          	add    $0x1,%r13
    bec9:	4a c7 04 20 00 00 00 	movq   $0x0,(%rax,%r12,1)
    bed0:	00 
    bed1:	4c 39 ed             	cmp    %r13,%rbp
    bed4:	0f 86 38 01 00 00    	jbe    c012 <LibLocateHandleByDiskSignature+0x232>
    beda:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    bedf:	48 8b 05 ea 12 01 00 	mov    0x112ea(%rip),%rax        # 1d1d0 <BS>
    bee6:	4c 89 fa             	mov    %r15,%rdx
    bee9:	4a 8b 0c ef          	mov    (%rdi,%r13,8),%rcx
    beed:	4d 89 f0             	mov    %r14,%r8
    bef0:	4e 8d 24 ed 00 00 00 	lea    0x0(,%r13,8),%r12
    bef7:	00 
    bef8:	ff 90 98 00 00 00    	call   *0x98(%rax)
    befe:	48 8b 54 24 78       	mov    0x78(%rsp),%rdx
    bf03:	48 89 44 24 60       	mov    %rax,0x60(%rsp)
    bf08:	48 85 d2             	test   %rdx,%rdx
    bf0b:	74 b3                	je     bec0 <LibLocateHandleByDiskSignature+0xe0>
    bf0d:	0f b6 02             	movzbl (%rdx),%eax
    bf10:	31 c9                	xor    %ecx,%ecx
    bf12:	45 31 c0             	xor    %r8d,%r8d
    bf15:	0f 1f 00             	nopl   (%rax)
    bf18:	83 e0 7f             	and    $0x7f,%eax
    bf1b:	3c 04                	cmp    $0x4,%al
    bf1d:	74 17                	je     bf36 <LibLocateHandleByDiskSignature+0x156>
    bf1f:	31 c9                	xor    %ecx,%ecx
    bf21:	3c 7f                	cmp    $0x7f,%al
    bf23:	74 2b                	je     bf50 <LibLocateHandleByDiskSignature+0x170>
    bf25:	0f b7 72 02          	movzwl 0x2(%rdx),%esi
    bf29:	48 01 f2             	add    %rsi,%rdx
    bf2c:	0f b6 02             	movzbl (%rdx),%eax
    bf2f:	83 e0 7f             	and    $0x7f,%eax
    bf32:	3c 04                	cmp    $0x4,%al
    bf34:	75 e9                	jne    bf1f <LibLocateHandleByDiskSignature+0x13f>
    bf36:	0f b7 72 02          	movzwl 0x2(%rdx),%esi
    bf3a:	80 7a 01 01          	cmpb   $0x1,0x1(%rdx)
    bf3e:	48 8d 3c 32          	lea    (%rdx,%rsi,1),%rdi
    bf42:	0f b6 07             	movzbl (%rdi),%eax
    bf45:	74 29                	je     bf70 <LibLocateHandleByDiskSignature+0x190>
    bf47:	31 c9                	xor    %ecx,%ecx
    bf49:	48 89 fa             	mov    %rdi,%rdx
    bf4c:	eb ca                	jmp    bf18 <LibLocateHandleByDiskSignature+0x138>
    bf4e:	66 90                	xchg   %ax,%ax
    bf50:	80 7a 01 ff          	cmpb   $0xff,0x1(%rdx)
    bf54:	0f 84 9e 00 00 00    	je     bff8 <LibLocateHandleByDiskSignature+0x218>
    bf5a:	0f b7 42 02          	movzwl 0x2(%rdx),%eax
    bf5e:	48 01 c2             	add    %rax,%rdx
    bf61:	0f b6 02             	movzbl (%rdx),%eax
    bf64:	eb b2                	jmp    bf18 <LibLocateHandleByDiskSignature+0x138>
    bf66:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    bf6d:	00 00 00 
    bf70:	84 c9                	test   %cl,%cl
    bf72:	75 d5                	jne    bf49 <LibLocateHandleByDiskSignature+0x169>
    bf74:	41 89 c1             	mov    %eax,%r9d
    bf77:	b9 01 00 00 00       	mov    $0x1,%ecx
    bf7c:	41 83 e1 7f          	and    $0x7f,%r9d
    bf80:	41 80 f9 7f          	cmp    $0x7f,%r9b
    bf84:	75 c3                	jne    bf49 <LibLocateHandleByDiskSignature+0x169>
    bf86:	44 0f b6 54 24 40    	movzbl 0x40(%rsp),%r10d
    bf8c:	44 38 52 28          	cmp    %r10b,0x28(%rdx)
    bf90:	75 b7                	jne    bf49 <LibLocateHandleByDiskSignature+0x169>
    bf92:	44 0f b6 5c 24 5d    	movzbl 0x5d(%rsp),%r11d
    bf98:	44 38 5a 29          	cmp    %r11b,0x29(%rdx)
    bf9c:	75 ab                	jne    bf49 <LibLocateHandleByDiskSignature+0x169>
    bf9e:	41 80 fb 01          	cmp    $0x1,%r11b
    bfa2:	0f 84 3c 01 00 00    	je     c0e4 <LibLocateHandleByDiskSignature+0x304>
    bfa8:	41 80 fb 02          	cmp    $0x2,%r11b
    bfac:	0f 85 77 ff ff ff    	jne    bf29 <LibLocateHandleByDiskSignature+0x149>
    bfb2:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
    bfb7:	48 8d 72 18          	lea    0x18(%rdx),%rsi
    bfbb:	88 4c 24 5f          	mov    %cl,0x5f(%rsp)
    bfbf:	48 89 54 24 50       	mov    %rdx,0x50(%rsp)
    bfc4:	44 88 44 24 5e       	mov    %r8b,0x5e(%rsp)
    bfc9:	e8 c2 a8 ff ff       	call   6890 <CompareGuid>
    bfce:	48 8b 54 24 50       	mov    0x50(%rsp),%rdx
    bfd3:	0f b6 4c 24 5f       	movzbl 0x5f(%rsp),%ecx
    bfd8:	48 85 c0             	test   %rax,%rax
    bfdb:	0f b6 02             	movzbl (%rdx),%eax
    bfde:	0f 85 f2 00 00 00    	jne    c0d6 <LibLocateHandleByDiskSignature+0x2f6>
    bfe4:	83 e0 7f             	and    $0x7f,%eax
    bfe7:	41 b8 01 00 00 00    	mov    $0x1,%r8d
    bfed:	e9 2f ff ff ff       	jmp    bf21 <LibLocateHandleByDiskSignature+0x141>
    bff2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    bff8:	45 84 c0             	test   %r8b,%r8b
    bffb:	0f 84 bf fe ff ff    	je     bec0 <LibLocateHandleByDiskSignature+0xe0>
    c001:	49 83 c5 01          	add    $0x1,%r13
    c005:	48 83 03 01          	addq   $0x1,(%rbx)
    c009:	4c 39 ed             	cmp    %r13,%rbp
    c00c:	0f 87 c8 fe ff ff    	ja     beda <LibLocateHandleByDiskSignature+0xfa>
    c012:	48 8b 03             	mov    (%rbx),%rax
    c015:	48 85 c0             	test   %rax,%rax
    c018:	0f 84 8f 00 00 00    	je     c0ad <LibLocateHandleByDiskSignature+0x2cd>
    c01e:	48 8d 3c c5 00 00 00 	lea    0x0(,%rax,8),%rdi
    c025:	00 
    c026:	e8 f5 ab ff ff       	call   6c20 <AllocatePool>
    c02b:	48 8b 7c 24 38       	mov    0x38(%rsp),%rdi
    c030:	48 89 07             	mov    %rax,(%rdi)
    c033:	48 85 c0             	test   %rax,%rax
    c036:	0f 84 c0 00 00 00    	je     c0fc <LibLocateHandleByDiskSignature+0x31c>
    c03c:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    c043:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    c048:	31 c0                	xor    %eax,%eax
    c04a:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
    c04f:	90                   	nop
    c050:	48 8b 14 c7          	mov    (%rdi,%rax,8),%rdx
    c054:	48 85 d2             	test   %rdx,%rdx
    c057:	74 13                	je     c06c <LibLocateHandleByDiskSignature+0x28c>
    c059:	48 8b 33             	mov    (%rbx),%rsi
    c05c:	49 8b 08             	mov    (%r8),%rcx
    c05f:	48 89 14 f1          	mov    %rdx,(%rcx,%rsi,8)
    c063:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    c068:	48 83 03 01          	addq   $0x1,(%rbx)
    c06c:	48 83 c0 01          	add    $0x1,%rax
    c070:	48 39 c5             	cmp    %rax,%rbp
    c073:	77 db                	ja     c050 <LibLocateHandleByDiskSignature+0x270>
    c075:	e8 c6 ac ff ff       	call   6d40 <FreePool>
    c07a:	31 c0                	xor    %eax,%eax
    c07c:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
    c083:	5b                   	pop    %rbx
    c084:	5d                   	pop    %rbp
    c085:	41 5c                	pop    %r12
    c087:	41 5d                	pop    %r13
    c089:	41 5e                	pop    %r14
    c08b:	41 5f                	pop    %r15
    c08d:	c3                   	ret
    c08e:	e8 ad ac ff ff       	call   6d40 <FreePool>
    c093:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    c098:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    c09f:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    c0a6:	48 8b 44 24 60       	mov    0x60(%rsp),%rax
    c0ab:	eb cf                	jmp    c07c <LibLocateHandleByDiskSignature+0x29c>
    c0ad:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    c0b2:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
    c0b7:	e8 84 ac ff ff       	call   6d40 <FreePool>
    c0bc:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    c0c1:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    c0c8:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    c0cf:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
    c0d4:	eb a6                	jmp    c07c <LibLocateHandleByDiskSignature+0x29c>
    c0d6:	44 0f b6 44 24 5e    	movzbl 0x5e(%rsp),%r8d
    c0dc:	83 e0 7f             	and    $0x7f,%eax
    c0df:	e9 3d fe ff ff       	jmp    bf21 <LibLocateHandleByDiskSignature+0x141>
    c0e4:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
    c0e9:	8b 52 18             	mov    0x18(%rdx),%edx
    c0ec:	39 16                	cmp    %edx,(%rsi)
    c0ee:	0f b6 74 24 5d       	movzbl 0x5d(%rsp),%esi
    c0f3:	44 0f 44 c6          	cmove  %esi,%r8d
    c0f7:	e9 4d fe ff ff       	jmp    bf49 <LibLocateHandleByDiskSignature+0x169>
    c0fc:	48 8b 7c 24 70       	mov    0x70(%rsp),%rdi
    c101:	e8 3a ac ff ff       	call   6d40 <FreePool>
    c106:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    c10b:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
    c112:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    c119:	48 b8 09 00 00 00 00 	movabs $0x8000000000000009,%rax
    c120:	00 00 80 
    c123:	e9 54 ff ff ff       	jmp    c07c <LibLocateHandleByDiskSignature+0x29c>
    c128:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    c12f:	00 

000000000000c130 <LibOpenRoot>:
    c130:	f3 0f 1e fa          	endbr64
    c134:	48 83 ec 38          	sub    $0x38,%rsp
    c138:	48 8b 05 91 10 01 00 	mov    0x11091(%rip),%rax        # 1d1d0 <BS>
    c13f:	48 89 f9             	mov    %rdi,%rcx
    c142:	48 8d 15 27 a1 00 00 	lea    0xa127(%rip),%rdx        # 16270 <gEfiSimpleFileSystemProtocolGuid>
    c149:	4c 8d 44 24 20       	lea    0x20(%rsp),%r8
    c14e:	ff 90 98 00 00 00    	call   *0x98(%rax)
    c154:	48 85 c0             	test   %rax,%rax
    c157:	78 27                	js     c180 <LibOpenRoot+0x50>
    c159:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
    c15e:	48 8d 54 24 28       	lea    0x28(%rsp),%rdx
    c163:	48 89 c1             	mov    %rax,%rcx
    c166:	ff 50 08             	call   *0x8(%rax)
    c169:	48 85 c0             	test   %rax,%rax
    c16c:	78 12                	js     c180 <LibOpenRoot+0x50>
    c16e:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c173:	48 83 c4 38          	add    $0x38,%rsp
    c177:	c3                   	ret
    c178:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    c17f:	00 
    c180:	31 c0                	xor    %eax,%eax
    c182:	48 83 c4 38          	add    $0x38,%rsp
    c186:	c3                   	ret
    c187:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    c18e:	00 00 

000000000000c190 <LibFileInfo>:
    c190:	f3 0f 1e fa          	endbr64
    c194:	41 55                	push   %r13
    c196:	ba 18 01 00 00       	mov    $0x118,%edx
    c19b:	4c 8d 2d 8e 9f 00 00 	lea    0x9f8e(%rip),%r13        # 16130 <gEfiFileInfoGuid>
    c1a2:	41 54                	push   %r12
    c1a4:	55                   	push   %rbp
    c1a5:	53                   	push   %rbx
    c1a6:	48 89 fb             	mov    %rdi,%rbx
    c1a9:	48 83 ec 48          	sub    $0x48,%rsp
    c1ad:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    c1b4:	00 00 
    c1b6:	4c 8d 64 24 30       	lea    0x30(%rsp),%r12
    c1bb:	48 8d 6c 24 28       	lea    0x28(%rsp),%rbp
    c1c0:	48 c7 44 24 30 00 00 	movq   $0x0,0x30(%rsp)
    c1c7:	00 00 
    c1c9:	48 c7 44 24 38 18 01 	movq   $0x118,0x38(%rsp)
    c1d0:	00 00 
    c1d2:	eb 21                	jmp    c1f5 <LibFileInfo+0x65>
    c1d4:	0f 1f 40 00          	nopl   0x0(%rax)
    c1d8:	4c 89 ea             	mov    %r13,%rdx
    c1db:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
    c1e0:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    c1e5:	48 89 d9             	mov    %rbx,%rcx
    c1e8:	ff 53 40             	call   *0x40(%rbx)
    c1eb:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    c1f0:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c1f5:	4c 89 e6             	mov    %r12,%rsi
    c1f8:	48 89 ef             	mov    %rbp,%rdi
    c1fb:	e8 a0 ab ff ff       	call   6da0 <GrowBuffer>
    c200:	84 c0                	test   %al,%al
    c202:	75 d4                	jne    c1d8 <LibFileInfo+0x48>
    c204:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    c209:	48 83 c4 48          	add    $0x48,%rsp
    c20d:	5b                   	pop    %rbx
    c20e:	5d                   	pop    %rbp
    c20f:	41 5c                	pop    %r12
    c211:	41 5d                	pop    %r13
    c213:	c3                   	ret
    c214:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c21b:	00 00 00 00 
    c21f:	90                   	nop

000000000000c220 <LibFileSystemInfo>:
    c220:	f3 0f 1e fa          	endbr64
    c224:	41 55                	push   %r13
    c226:	ba ec 00 00 00       	mov    $0xec,%edx
    c22b:	4c 8d 2d ee 9e 00 00 	lea    0x9eee(%rip),%r13        # 16120 <gEfiFileSystemInfoGuid>
    c232:	41 54                	push   %r12
    c234:	55                   	push   %rbp
    c235:	53                   	push   %rbx
    c236:	48 89 fb             	mov    %rdi,%rbx
    c239:	48 83 ec 48          	sub    $0x48,%rsp
    c23d:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    c244:	00 00 
    c246:	4c 8d 64 24 30       	lea    0x30(%rsp),%r12
    c24b:	48 8d 6c 24 28       	lea    0x28(%rsp),%rbp
    c250:	48 c7 44 24 30 00 00 	movq   $0x0,0x30(%rsp)
    c257:	00 00 
    c259:	48 c7 44 24 38 ec 00 	movq   $0xec,0x38(%rsp)
    c260:	00 00 
    c262:	eb 21                	jmp    c285 <LibFileSystemInfo+0x65>
    c264:	0f 1f 40 00          	nopl   0x0(%rax)
    c268:	4c 89 ea             	mov    %r13,%rdx
    c26b:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
    c270:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    c275:	48 89 d9             	mov    %rbx,%rcx
    c278:	ff 53 40             	call   *0x40(%rbx)
    c27b:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    c280:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c285:	4c 89 e6             	mov    %r12,%rsi
    c288:	48 89 ef             	mov    %rbp,%rdi
    c28b:	e8 10 ab ff ff       	call   6da0 <GrowBuffer>
    c290:	84 c0                	test   %al,%al
    c292:	75 d4                	jne    c268 <LibFileSystemInfo+0x48>
    c294:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    c299:	48 83 c4 48          	add    $0x48,%rsp
    c29d:	5b                   	pop    %rbx
    c29e:	5d                   	pop    %rbp
    c29f:	41 5c                	pop    %r12
    c2a1:	41 5d                	pop    %r13
    c2a3:	c3                   	ret
    c2a4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c2ab:	00 00 00 00 
    c2af:	90                   	nop

000000000000c2b0 <LibFileSystemVolumeLabelInfo>:
    c2b0:	f3 0f 1e fa          	endbr64
    c2b4:	41 55                	push   %r13
    c2b6:	ba c8 00 00 00       	mov    $0xc8,%edx
    c2bb:	4c 8d 2d 4e 9e 00 00 	lea    0x9e4e(%rip),%r13        # 16110 <gEfiFileSystemVolumeLabelInfoIdGuid>
    c2c2:	41 54                	push   %r12
    c2c4:	55                   	push   %rbp
    c2c5:	53                   	push   %rbx
    c2c6:	48 89 fb             	mov    %rdi,%rbx
    c2c9:	48 83 ec 48          	sub    $0x48,%rsp
    c2cd:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    c2d4:	00 00 
    c2d6:	4c 8d 64 24 30       	lea    0x30(%rsp),%r12
    c2db:	48 8d 6c 24 28       	lea    0x28(%rsp),%rbp
    c2e0:	48 c7 44 24 30 00 00 	movq   $0x0,0x30(%rsp)
    c2e7:	00 00 
    c2e9:	48 c7 44 24 38 c8 00 	movq   $0xc8,0x38(%rsp)
    c2f0:	00 00 
    c2f2:	eb 21                	jmp    c315 <LibFileSystemVolumeLabelInfo+0x65>
    c2f4:	0f 1f 40 00          	nopl   0x0(%rax)
    c2f8:	4c 89 ea             	mov    %r13,%rdx
    c2fb:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
    c300:	4c 8d 44 24 38       	lea    0x38(%rsp),%r8
    c305:	48 89 d9             	mov    %rbx,%rcx
    c308:	ff 53 40             	call   *0x40(%rbx)
    c30b:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    c310:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c315:	4c 89 e6             	mov    %r12,%rsi
    c318:	48 89 ef             	mov    %rbp,%rdi
    c31b:	e8 80 aa ff ff       	call   6da0 <GrowBuffer>
    c320:	84 c0                	test   %al,%al
    c322:	75 d4                	jne    c2f8 <LibFileSystemVolumeLabelInfo+0x48>
    c324:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    c329:	48 83 c4 48          	add    $0x48,%rsp
    c32d:	5b                   	pop    %rbx
    c32e:	5d                   	pop    %rbp
    c32f:	41 5c                	pop    %r12
    c331:	41 5d                	pop    %r13
    c333:	c3                   	ret
    c334:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c33b:	00 00 00 00 
    c33f:	90                   	nop

000000000000c340 <LibInstallProtocolInterfaces>:
    c340:	f3 0f 1e fa          	endbr64
    c344:	41 56                	push   %r14
    c346:	45 31 f6             	xor    %r14d,%r14d
    c349:	41 55                	push   %r13
    c34b:	41 54                	push   %r12
    c34d:	55                   	push   %rbp
    c34e:	48 89 fd             	mov    %rdi,%rbp
    c351:	53                   	push   %rbx
    c352:	31 db                	xor    %ebx,%ebx
    c354:	48 83 ec 70          	sub    $0x70,%rsp
    c358:	48 8b 05 71 0e 01 00 	mov    0x10e71(%rip),%rax        # 1d1d0 <BS>
    c35f:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
    c364:	b9 10 00 00 00       	mov    $0x10,%ecx
    c369:	48 89 74 24 48       	mov    %rsi,0x48(%rsp)
    c36e:	48 89 54 24 50       	mov    %rdx,0x50(%rsp)
    c373:	4c 89 44 24 60       	mov    %r8,0x60(%rsp)
    c378:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
    c37d:	ff 50 18             	call   *0x18(%rax)
    c380:	c7 44 24 20 08 00 00 	movl   $0x8,0x20(%rsp)
    c387:	00 
    c388:	4c 8b 6d 00          	mov    0x0(%rbp),%r13
    c38c:	49 89 c4             	mov    %rax,%r12
    c38f:	48 8d 84 24 a0 00 00 	lea    0xa0(%rsp),%rax
    c396:	00 
    c397:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c39c:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    c3a1:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    c3a6:	eb 57                	jmp    c3ff <LibInstallProtocolInterfaces+0xbf>
    c3a8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    c3af:	00 
    c3b0:	48 8b 74 24 30       	mov    0x30(%rsp),%rsi
    c3b5:	89 d1                	mov    %edx,%ecx
    c3b7:	8d 42 08             	lea    0x8(%rdx),%eax
    c3ba:	89 44 24 20          	mov    %eax,0x20(%rsp)
    c3be:	4c 8b 14 0e          	mov    (%rsi,%rcx,1),%r10
    c3c2:	4d 85 d2             	test   %r10,%r10
    c3c5:	74 6d                	je     c434 <LibInstallProtocolInterfaces+0xf4>
    c3c7:	83 f8 2f             	cmp    $0x2f,%eax
    c3ca:	0f 87 19 01 00 00    	ja     c4e9 <LibInstallProtocolInterfaces+0x1a9>
    c3d0:	83 c2 10             	add    $0x10,%edx
    c3d3:	48 01 f0             	add    %rsi,%rax
    c3d6:	89 54 24 20          	mov    %edx,0x20(%rsp)
    c3da:	4c 8b 08             	mov    (%rax),%r9
    c3dd:	48 8b 05 ec 0d 01 00 	mov    0x10dec(%rip),%rax        # 1d1d0 <BS>
    c3e4:	45 31 c0             	xor    %r8d,%r8d
    c3e7:	4c 89 d2             	mov    %r10,%rdx
    c3ea:	48 89 e9             	mov    %rbp,%rcx
    c3ed:	ff 90 80 00 00 00    	call   *0x80(%rax)
    c3f3:	49 89 c6             	mov    %rax,%r14
    c3f6:	48 85 c0             	test   %rax,%rax
    c3f9:	78 5d                	js     c458 <LibInstallProtocolInterfaces+0x118>
    c3fb:	48 83 c3 01          	add    $0x1,%rbx
    c3ff:	8b 54 24 20          	mov    0x20(%rsp),%edx
    c403:	83 fa 2f             	cmp    $0x2f,%edx
    c406:	76 a8                	jbe    c3b0 <LibInstallProtocolInterfaces+0x70>
    c408:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c40d:	48 89 c2             	mov    %rax,%rdx
    c410:	48 83 c0 08          	add    $0x8,%rax
    c414:	4c 8b 12             	mov    (%rdx),%r10
    c417:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c41c:	4d 85 d2             	test   %r10,%r10
    c41f:	74 13                	je     c434 <LibInstallProtocolInterfaces+0xf4>
    c421:	48 8d 50 08          	lea    0x8(%rax),%rdx
    c425:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
    c42a:	eb ae                	jmp    c3da <LibInstallProtocolInterfaces+0x9a>
    c42c:	0f 1f 40 00          	nopl   0x0(%rax)
    c430:	4c 89 6d 00          	mov    %r13,0x0(%rbp)
    c434:	48 8b 05 95 0d 01 00 	mov    0x10d95(%rip),%rax        # 1d1d0 <BS>
    c43b:	4c 89 e1             	mov    %r12,%rcx
    c43e:	ff 50 20             	call   *0x20(%rax)
    c441:	48 83 c4 70          	add    $0x70,%rsp
    c445:	4c 89 f0             	mov    %r14,%rax
    c448:	5b                   	pop    %rbx
    c449:	5d                   	pop    %rbp
    c44a:	41 5c                	pop    %r12
    c44c:	41 5d                	pop    %r13
    c44e:	41 5e                	pop    %r14
    c450:	c3                   	ret
    c451:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    c458:	48 8d 84 24 a0 00 00 	lea    0xa0(%rsp),%rax
    c45f:	00 
    c460:	c7 44 24 20 08 00 00 	movl   $0x8,0x20(%rsp)
    c467:	00 
    c468:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c46d:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    c472:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    c477:	48 85 db             	test   %rbx,%rbx
    c47a:	75 46                	jne    c4c2 <LibInstallProtocolInterfaces+0x182>
    c47c:	eb b2                	jmp    c430 <LibInstallProtocolInterfaces+0xf0>
    c47e:	66 90                	xchg   %ax,%ax
    c480:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    c485:	8d 48 08             	lea    0x8(%rax),%ecx
    c488:	89 c6                	mov    %eax,%esi
    c48a:	89 4c 24 20          	mov    %ecx,0x20(%rsp)
    c48e:	4c 8b 0c 32          	mov    (%rdx,%rsi,1),%r9
    c492:	83 f9 2f             	cmp    $0x2f,%ecx
    c495:	77 4b                	ja     c4e2 <LibInstallProtocolInterfaces+0x1a2>
    c497:	83 c0 10             	add    $0x10,%eax
    c49a:	48 01 ca             	add    %rcx,%rdx
    c49d:	89 44 24 20          	mov    %eax,0x20(%rsp)
    c4a1:	48 8b 05 28 0d 01 00 	mov    0x10d28(%rip),%rax        # 1d1d0 <BS>
    c4a8:	4c 8b 02             	mov    (%rdx),%r8
    c4ab:	4c 89 ca             	mov    %r9,%rdx
    c4ae:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    c4b2:	ff 90 90 00 00 00    	call   *0x90(%rax)
    c4b8:	48 83 eb 01          	sub    $0x1,%rbx
    c4bc:	0f 84 6e ff ff ff    	je     c430 <LibInstallProtocolInterfaces+0xf0>
    c4c2:	8b 44 24 20          	mov    0x20(%rsp),%eax
    c4c6:	83 f8 2f             	cmp    $0x2f,%eax
    c4c9:	76 b5                	jbe    c480 <LibInstallProtocolInterfaces+0x140>
    c4cb:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c4d0:	4c 8b 08             	mov    (%rax),%r9
    c4d3:	48 8d 50 08          	lea    0x8(%rax),%rdx
    c4d7:	48 8d 42 08          	lea    0x8(%rdx),%rax
    c4db:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c4e0:	eb bf                	jmp    c4a1 <LibInstallProtocolInterfaces+0x161>
    c4e2:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    c4e7:	eb ee                	jmp    c4d7 <LibInstallProtocolInterfaces+0x197>
    c4e9:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c4ee:	e9 2e ff ff ff       	jmp    c421 <LibInstallProtocolInterfaces+0xe1>
    c4f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c4fa:	00 00 00 00 
    c4fe:	66 90                	xchg   %ax,%ax

000000000000c500 <LibUninstallProtocolInterfaces>:
    c500:	f3 0f 1e fa          	endbr64
    c504:	53                   	push   %rbx
    c505:	48 89 fb             	mov    %rdi,%rbx
    c508:	48 83 ec 70          	sub    $0x70,%rsp
    c50c:	48 8d 84 24 80 00 00 	lea    0x80(%rsp),%rax
    c513:	00 
    c514:	48 89 74 24 48       	mov    %rsi,0x48(%rsp)
    c519:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c51e:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    c523:	48 89 54 24 50       	mov    %rdx,0x50(%rsp)
    c528:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
    c52d:	4c 89 44 24 60       	mov    %r8,0x60(%rsp)
    c532:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
    c537:	c7 44 24 20 08 00 00 	movl   $0x8,0x20(%rsp)
    c53e:	00 
    c53f:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    c544:	eb 46                	jmp    c58c <LibUninstallProtocolInterfaces+0x8c>
    c546:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    c54d:	00 00 00 
    c550:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    c555:	89 c6                	mov    %eax,%esi
    c557:	8d 48 08             	lea    0x8(%rax),%ecx
    c55a:	89 4c 24 20          	mov    %ecx,0x20(%rsp)
    c55e:	4c 8b 0c 32          	mov    (%rdx,%rsi,1),%r9
    c562:	4d 85 c9             	test   %r9,%r9
    c565:	74 59                	je     c5c0 <LibUninstallProtocolInterfaces+0xc0>
    c567:	83 f9 2f             	cmp    $0x2f,%ecx
    c56a:	77 5a                	ja     c5c6 <LibUninstallProtocolInterfaces+0xc6>
    c56c:	83 c0 10             	add    $0x10,%eax
    c56f:	48 01 ca             	add    %rcx,%rdx
    c572:	89 44 24 20          	mov    %eax,0x20(%rsp)
    c576:	48 8b 05 53 0c 01 00 	mov    0x10c53(%rip),%rax        # 1d1d0 <BS>
    c57d:	4c 8b 02             	mov    (%rdx),%r8
    c580:	48 89 d9             	mov    %rbx,%rcx
    c583:	4c 89 ca             	mov    %r9,%rdx
    c586:	ff 90 90 00 00 00    	call   *0x90(%rax)
    c58c:	8b 44 24 20          	mov    0x20(%rsp),%eax
    c590:	83 f8 2f             	cmp    $0x2f,%eax
    c593:	76 bb                	jbe    c550 <LibUninstallProtocolInterfaces+0x50>
    c595:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c59a:	4c 8b 08             	mov    (%rax),%r9
    c59d:	48 8d 50 08          	lea    0x8(%rax),%rdx
    c5a1:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
    c5a6:	4d 85 c9             	test   %r9,%r9
    c5a9:	74 15                	je     c5c0 <LibUninstallProtocolInterfaces+0xc0>
    c5ab:	48 8d 42 08          	lea    0x8(%rdx),%rax
    c5af:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c5b4:	eb c0                	jmp    c576 <LibUninstallProtocolInterfaces+0x76>
    c5b6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    c5bd:	00 00 00 
    c5c0:	48 83 c4 70          	add    $0x70,%rsp
    c5c4:	5b                   	pop    %rbx
    c5c5:	c3                   	ret
    c5c6:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    c5cb:	eb de                	jmp    c5ab <LibUninstallProtocolInterfaces+0xab>
    c5cd:	0f 1f 00             	nopl   (%rax)

000000000000c5d0 <LibReinstallProtocolInterfaces>:
    c5d0:	f3 0f 1e fa          	endbr64
    c5d4:	41 55                	push   %r13
    c5d6:	45 31 ed             	xor    %r13d,%r13d
    c5d9:	41 54                	push   %r12
    c5db:	55                   	push   %rbp
    c5dc:	48 89 fd             	mov    %rdi,%rbp
    c5df:	53                   	push   %rbx
    c5e0:	31 db                	xor    %ebx,%ebx
    c5e2:	48 83 ec 78          	sub    $0x78,%rsp
    c5e6:	48 8b 05 e3 0b 01 00 	mov    0x10be3(%rip),%rax        # 1d1d0 <BS>
    c5ed:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
    c5f2:	b9 10 00 00 00       	mov    $0x10,%ecx
    c5f7:	48 89 74 24 48       	mov    %rsi,0x48(%rsp)
    c5fc:	48 89 54 24 50       	mov    %rdx,0x50(%rsp)
    c601:	4c 89 44 24 60       	mov    %r8,0x60(%rsp)
    c606:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
    c60b:	ff 50 18             	call   *0x18(%rax)
    c60e:	c7 44 24 20 08 00 00 	movl   $0x8,0x20(%rsp)
    c615:	00 
    c616:	49 89 c4             	mov    %rax,%r12
    c619:	48 8d 84 24 a0 00 00 	lea    0xa0(%rsp),%rax
    c620:	00 
    c621:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c626:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    c62b:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    c630:	eb 6a                	jmp    c69c <LibReinstallProtocolInterfaces+0xcc>
    c632:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    c638:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    c63d:	89 c6                	mov    %eax,%esi
    c63f:	8d 48 08             	lea    0x8(%rax),%ecx
    c642:	89 4c 24 20          	mov    %ecx,0x20(%rsp)
    c646:	4c 8b 14 32          	mov    (%rdx,%rsi,1),%r10
    c64a:	4d 85 d2             	test   %r10,%r10
    c64d:	0f 84 7d 00 00 00    	je     c6d0 <LibReinstallProtocolInterfaces+0x100>
    c653:	83 f9 2f             	cmp    $0x2f,%ecx
    c656:	0f 87 54 01 00 00    	ja     c7b0 <LibReinstallProtocolInterfaces+0x1e0>
    c65c:	8d 70 10             	lea    0x10(%rax),%esi
    c65f:	4c 8b 04 0a          	mov    (%rdx,%rcx,1),%r8
    c663:	89 74 24 20          	mov    %esi,0x20(%rsp)
    c667:	83 fe 2f             	cmp    $0x2f,%esi
    c66a:	0f 87 36 01 00 00    	ja     c7a6 <LibReinstallProtocolInterfaces+0x1d6>
    c670:	83 c0 18             	add    $0x18,%eax
    c673:	48 01 f2             	add    %rsi,%rdx
    c676:	89 44 24 20          	mov    %eax,0x20(%rsp)
    c67a:	48 8b 05 4f 0b 01 00 	mov    0x10b4f(%rip),%rax        # 1d1d0 <BS>
    c681:	4c 8b 0a             	mov    (%rdx),%r9
    c684:	48 89 e9             	mov    %rbp,%rcx
    c687:	4c 89 d2             	mov    %r10,%rdx
    c68a:	ff 90 88 00 00 00    	call   *0x88(%rax)
    c690:	49 89 c5             	mov    %rax,%r13
    c693:	48 85 c0             	test   %rax,%rax
    c696:	78 58                	js     c6f0 <LibReinstallProtocolInterfaces+0x120>
    c698:	48 83 c3 01          	add    $0x1,%rbx
    c69c:	8b 44 24 20          	mov    0x20(%rsp),%eax
    c6a0:	83 f8 2f             	cmp    $0x2f,%eax
    c6a3:	76 93                	jbe    c638 <LibReinstallProtocolInterfaces+0x68>
    c6a5:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c6aa:	48 89 c2             	mov    %rax,%rdx
    c6ad:	48 83 c0 08          	add    $0x8,%rax
    c6b1:	4c 8b 12             	mov    (%rdx),%r10
    c6b4:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c6b9:	4d 85 d2             	test   %r10,%r10
    c6bc:	74 12                	je     c6d0 <LibReinstallProtocolInterfaces+0x100>
    c6be:	4c 8b 00             	mov    (%rax),%r8
    c6c1:	48 8d 50 08          	lea    0x8(%rax),%rdx
    c6c5:	48 8d 42 08          	lea    0x8(%rdx),%rax
    c6c9:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c6ce:	eb aa                	jmp    c67a <LibReinstallProtocolInterfaces+0xaa>
    c6d0:	48 8b 05 f9 0a 01 00 	mov    0x10af9(%rip),%rax        # 1d1d0 <BS>
    c6d7:	4c 89 e1             	mov    %r12,%rcx
    c6da:	ff 50 20             	call   *0x20(%rax)
    c6dd:	48 83 c4 78          	add    $0x78,%rsp
    c6e1:	4c 89 e8             	mov    %r13,%rax
    c6e4:	5b                   	pop    %rbx
    c6e5:	5d                   	pop    %rbp
    c6e6:	41 5c                	pop    %r12
    c6e8:	41 5d                	pop    %r13
    c6ea:	c3                   	ret
    c6eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    c6f0:	48 8d 84 24 a0 00 00 	lea    0xa0(%rsp),%rax
    c6f7:	00 
    c6f8:	c7 44 24 20 08 00 00 	movl   $0x8,0x20(%rsp)
    c6ff:	00 
    c700:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c705:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    c70a:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
    c70f:	48 85 db             	test   %rbx,%rbx
    c712:	75 5d                	jne    c771 <LibReinstallProtocolInterfaces+0x1a1>
    c714:	eb ba                	jmp    c6d0 <LibReinstallProtocolInterfaces+0x100>
    c716:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    c71d:	00 00 00 
    c720:	48 8b 54 24 30       	mov    0x30(%rsp),%rdx
    c725:	8d 70 08             	lea    0x8(%rax),%esi
    c728:	89 c1                	mov    %eax,%ecx
    c72a:	89 74 24 20          	mov    %esi,0x20(%rsp)
    c72e:	4c 8b 14 0a          	mov    (%rdx,%rcx,1),%r10
    c732:	83 fe 2f             	cmp    $0x2f,%esi
    c735:	77 61                	ja     c798 <LibReinstallProtocolInterfaces+0x1c8>
    c737:	8d 48 10             	lea    0x10(%rax),%ecx
    c73a:	4c 8b 0c 32          	mov    (%rdx,%rsi,1),%r9
    c73e:	89 4c 24 20          	mov    %ecx,0x20(%rsp)
    c742:	83 f9 2f             	cmp    $0x2f,%ecx
    c745:	77 58                	ja     c79f <LibReinstallProtocolInterfaces+0x1cf>
    c747:	83 c0 18             	add    $0x18,%eax
    c74a:	48 01 ca             	add    %rcx,%rdx
    c74d:	89 44 24 20          	mov    %eax,0x20(%rsp)
    c751:	48 8b 05 78 0a 01 00 	mov    0x10a78(%rip),%rax        # 1d1d0 <BS>
    c758:	4c 8b 02             	mov    (%rdx),%r8
    c75b:	48 89 e9             	mov    %rbp,%rcx
    c75e:	4c 89 d2             	mov    %r10,%rdx
    c761:	ff 90 88 00 00 00    	call   *0x88(%rax)
    c767:	48 83 eb 01          	sub    $0x1,%rbx
    c76b:	0f 84 5f ff ff ff    	je     c6d0 <LibReinstallProtocolInterfaces+0x100>
    c771:	8b 44 24 20          	mov    0x20(%rsp),%eax
    c775:	83 f8 2f             	cmp    $0x2f,%eax
    c778:	76 a6                	jbe    c720 <LibReinstallProtocolInterfaces+0x150>
    c77a:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    c77f:	4c 8b 12             	mov    (%rdx),%r10
    c782:	48 8d 42 08          	lea    0x8(%rdx),%rax
    c786:	4c 8b 08             	mov    (%rax),%r9
    c789:	48 8d 50 08          	lea    0x8(%rax),%rdx
    c78d:	48 8d 42 08          	lea    0x8(%rdx),%rax
    c791:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    c796:	eb b9                	jmp    c751 <LibReinstallProtocolInterfaces+0x181>
    c798:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c79d:	eb e7                	jmp    c786 <LibReinstallProtocolInterfaces+0x1b6>
    c79f:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    c7a4:	eb e7                	jmp    c78d <LibReinstallProtocolInterfaces+0x1bd>
    c7a6:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    c7ab:	e9 15 ff ff ff       	jmp    c6c5 <LibReinstallProtocolInterfaces+0xf5>
    c7b0:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    c7b5:	e9 04 ff ff ff       	jmp    c6be <LibReinstallProtocolInterfaces+0xee>
    c7ba:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

000000000000c7c0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm>:
    c7c0:	48 89 f8             	mov    %rdi,%rax
    c7c3:	66 31 c0             	xor    %ax,%ax
    c7c6:	48 8d b0 00 00 00 fe 	lea    -0x2000000(%rax),%rsi
    c7cd:	eb 20                	jmp    c7ef <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x2f>
    c7cf:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c7d6:	00 00 00 00 
    c7da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    c7e0:	48 2d 00 00 01 00    	sub    $0x10000,%rax
    c7e6:	48 39 f0             	cmp    %rsi,%rax
    c7e9:	0f 84 f9 00 00 00    	je     c8e8 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x128>
    c7ef:	0f b7 10             	movzwl (%rax),%edx
    c7f2:	66 81 fa 4d 5a       	cmp    $0x5a4d,%dx
    c7f7:	75 e7                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c7f9:	0f b7 10             	movzwl (%rax),%edx
    c7fc:	66 81 fa 4d 5a       	cmp    $0x5a4d,%dx
    c801:	75 dd                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c803:	8b 50 3c             	mov    0x3c(%rax),%edx
    c806:	8d 4a c0             	lea    -0x40(%rdx),%ecx
    c809:	81 f9 c0 0f 00 00    	cmp    $0xfc0,%ecx
    c80f:	77 cf                	ja     c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c811:	48 01 c2             	add    %rax,%rdx
    c814:	8b 0a                	mov    (%rdx),%ecx
    c816:	81 f9 50 45 00 00    	cmp    $0x4550,%ecx
    c81c:	75 c2                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c81e:	0f b7 4a 04          	movzwl 0x4(%rdx),%ecx
    c822:	66 81 f9 64 86       	cmp    $0x8664,%cx
    c827:	75 b7                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c829:	0f b7 4a 06          	movzwl 0x6(%rdx),%ecx
    c82d:	8d 79 ff             	lea    -0x1(%rcx),%edi
    c830:	83 ff 5f             	cmp    $0x5f,%edi
    c833:	77 ab                	ja     c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c835:	0f b7 7a 14          	movzwl 0x14(%rdx),%edi
    c839:	66 81 ff f0 00       	cmp    $0xf0,%di
    c83e:	75 a0                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c840:	0f b7 7a 18          	movzwl 0x18(%rdx),%edi
    c844:	66 81 ff 0b 02       	cmp    $0x20b,%di
    c849:	75 95                	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c84b:	44 8b 42 50          	mov    0x50(%rdx),%r8d
    c84f:	41 8d b8 00 00 fe ff 	lea    -0x20000(%r8),%edi
    c856:	81 ff 00 00 fe 03    	cmp    $0x3fe0000,%edi
    c85c:	77 82                	ja     c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c85e:	45 89 c1             	mov    %r8d,%r9d
    c861:	41 81 e1 ff 0f 00 00 	and    $0xfff,%r9d
    c868:	0f 85 72 ff ff ff    	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c86e:	8b 7a 28             	mov    0x28(%rdx),%edi
    c871:	44 39 c7             	cmp    %r8d,%edi
    c874:	0f 83 66 ff ff ff    	jae    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c87a:	8b 7a 54             	mov    0x54(%rdx),%edi
    c87d:	83 ef 01             	sub    $0x1,%edi
    c880:	44 39 c7             	cmp    %r8d,%edi
    c883:	0f 83 57 ff ff ff    	jae    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c889:	48 81 c2 10 01 00 00 	add    $0x110,%rdx
    c890:	45 31 db             	xor    %r11d,%r11d
    c893:	eb 03                	jmp    c898 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0xd8>
    c895:	41 89 fb             	mov    %edi,%r11d
    c898:	8b 3a                	mov    (%rdx),%edi
    c89a:	44 8b 52 04          	mov    0x4(%rdx),%r10d
    c89e:	41 f7 c2 ff 0f 00 00 	test   $0xfff,%r10d
    c8a5:	0f 85 35 ff ff ff    	jne    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c8ab:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
    c8b1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    c8b7:	44 01 d7             	add    %r10d,%edi
    c8ba:	45 39 c2             	cmp    %r8d,%r10d
    c8bd:	0f 83 1d ff ff ff    	jae    c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c8c3:	41 39 f8             	cmp    %edi,%r8d
    c8c6:	0f 82 14 ff ff ff    	jb     c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c8cc:	45 85 c9             	test   %r9d,%r9d
    c8cf:	74 09                	je     c8da <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x11a>
    c8d1:	45 39 da             	cmp    %r11d,%r10d
    c8d4:	0f 82 06 ff ff ff    	jb     c7e0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0x20>
    c8da:	41 83 c1 01          	add    $0x1,%r9d
    c8de:	48 83 c2 28          	add    $0x28,%rdx
    c8e2:	44 39 c9             	cmp    %r9d,%ecx
    c8e5:	75 ae                	jne    c895 <_ZN10UEFIBridge2kaL12WalkBackToPEEm+0xd5>
    c8e7:	c3                   	ret
    c8e8:	31 c0                	xor    %eax,%eax
    c8ea:	c3                   	ret
    c8eb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    c8f2:	00 00 00 
    c8f5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    c8fc:	00 00 00 
    c8ff:	90                   	nop

000000000000c900 <_ZN10UEFIBridge9DiagWriteEv>:
    c900:	53                   	push   %rbx
    c901:	41 b9 20 00 00 00    	mov    $0x20,%r9d
    c907:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    c90d:	48 8d 0d 46 7f 00 00 	lea    0x7f46(%rip),%rcx        # 1485a <_data+0x85a>
    c914:	48 83 ec 48          	sub    $0x48,%rsp
    c918:	8b 05 92 08 01 00    	mov    0x10892(%rip),%eax        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
    c91e:	8b 1d 70 08 01 00    	mov    0x10870(%rip),%ebx        # 1d194 <_ZN10UEFIBridge18g_diag_last_statusE>
    c924:	c7 05 52 08 01 00 01 	movl   $0x1,0x10852(%rip)        # 1d180 <_ZN10UEFIBridge11g_diag_busyE>
    c92b:	00 00 00 
    c92e:	66 0f 6e 05 62 08 01 	movd   0x10862(%rip),%xmm0        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
    c935:	00 
    c936:	48 8d 54 24 28       	lea    0x28(%rsp),%rdx
    c93b:	c7 44 24 28 44 46 4e 	movl   $0x494e4644,0x28(%rsp)
    c942:	49 
    c943:	89 44 24 2c          	mov    %eax,0x2c(%rsp)
    c947:	8b 05 5f 08 01 00    	mov    0x1085f(%rip),%eax        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
    c94d:	66 0f 6e cb          	movd   %ebx,%xmm1
    c951:	66 0f 62 c1          	punpckldq %xmm1,%xmm0
    c955:	89 44 24 30          	mov    %eax,0x30(%rsp)
    c959:	8b 05 49 08 01 00    	mov    0x10849(%rip),%eax        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    c95f:	66 0f d6 44 24 40    	movq   %xmm0,0x40(%rsp)
    c965:	89 44 24 34          	mov    %eax,0x34(%rsp)
    c969:	48 8b 05 30 08 01 00 	mov    0x10830(%rip),%rax        # 1d1a0 <_ZN10UEFIBridge13g_diag_os_cr3E>
    c970:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
    c975:	48 8d 05 a4 08 01 00 	lea    0x108a4(%rip),%rax        # 1d220 <RT>
    c97c:	48 8b 00             	mov    (%rax),%rax
    c97f:	52                   	push   %rdx
    c980:	48 8d 15 d9 94 00 00 	lea    0x94d9(%rip),%rdx        # 15e60 <_ZN10UEFIBridge19gInfinityMemVarGuidE>
    c987:	48 83 ec 20          	sub    $0x20,%rsp
    c98b:	ff 50 58             	call   *0x58(%rax)
    c98e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    c993:	c7 05 e3 07 01 00 00 	movl   $0x0,0x107e3(%rip)        # 1d180 <_ZN10UEFIBridge11g_diag_busyE>
    c99a:	00 00 00 
    c99d:	89 05 f1 07 01 00    	mov    %eax,0x107f1(%rip)        # 1d194 <_ZN10UEFIBridge18g_diag_last_statusE>
    c9a3:	89 c6                	mov    %eax,%esi
    c9a5:	b8 0d 00 00 00       	mov    $0xd,%eax
    c9aa:	ee                   	out    %al,(%dx)
    c9ab:	b8 0a 00 00 00       	mov    $0xa,%eax
    c9b0:	ee                   	out    %al,(%dx)
    c9b1:	b8 5b 00 00 00       	mov    $0x5b,%eax
    c9b6:	48 83 c4 30          	add    $0x30,%rsp
    c9ba:	48 8d 0d 3f 76 00 00 	lea    0x763f(%rip),%rcx        # 14000 <_data>
    c9c1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c9c8:	00 00 00 00 
    c9cc:	0f 1f 40 00          	nopl   0x0(%rax)
    c9d0:	48 83 c1 01          	add    $0x1,%rcx
    c9d4:	ee                   	out    %al,(%dx)
    c9d5:	0f b6 01             	movzbl (%rcx),%eax
    c9d8:	84 c0                	test   %al,%al
    c9da:	75 f4                	jne    c9d0 <_ZN10UEFIBridge9DiagWriteEv+0xd0>
    c9dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    c9e1:	ee                   	out    %al,(%dx)
    c9e2:	b8 44 00 00 00       	mov    $0x44,%eax
    c9e7:	48 8d 0d 6a 77 00 00 	lea    0x776a(%rip),%rcx        # 14158 <_data+0x158>
    c9ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    c9f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    c9fa:	00 00 00 00 
    c9fe:	66 90                	xchg   %ax,%ax
    ca00:	48 83 c1 01          	add    $0x1,%rcx
    ca04:	ee                   	out    %al,(%dx)
    ca05:	0f b6 01             	movzbl (%rcx),%eax
    ca08:	84 c0                	test   %al,%al
    ca0a:	75 f4                	jne    ca00 <_ZN10UEFIBridge9DiagWriteEv+0x100>
    ca0c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    ca11:	ee                   	out    %al,(%dx)
    ca12:	b8 20 00 00 00       	mov    $0x20,%eax
    ca17:	ee                   	out    %al,(%dx)
    ca18:	b8 77 00 00 00       	mov    $0x77,%eax
    ca1d:	48 8d 0d 39 77 00 00 	lea    0x7739(%rip),%rcx        # 1415d <_data+0x15d>
    ca24:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ca29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ca30:	48 83 c1 01          	add    $0x1,%rcx
    ca34:	ee                   	out    %al,(%dx)
    ca35:	0f b6 01             	movzbl (%rcx),%eax
    ca38:	84 c0                	test   %al,%al
    ca3a:	75 f4                	jne    ca30 <_ZN10UEFIBridge9DiagWriteEv+0x130>
    ca3c:	44 8b 05 6d 07 01 00 	mov    0x1076d(%rip),%r8d        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
    ca43:	c6 44 24 14 00       	movb   $0x0,0x14(%rsp)
    ca48:	b9 13 00 00 00       	mov    $0x13,%ecx
    ca4d:	48 89 e7             	mov    %rsp,%rdi
    ca50:	49 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r10
    ca57:	cc cc cc 
    ca5a:	4d 85 c0             	test   %r8,%r8
    ca5d:	0f 84 7d 01 00 00    	je     cbe0 <_ZN10UEFIBridge9DiagWriteEv+0x2e0>
    ca63:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ca6a:	00 00 00 00 
    ca6e:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ca75:	00 00 00 00 
    ca79:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ca80:	4c 89 c0             	mov    %r8,%rax
    ca83:	49 89 cb             	mov    %rcx,%r11
    ca86:	49 f7 e2             	mul    %r10
    ca89:	4c 89 c0             	mov    %r8,%rax
    ca8c:	48 c1 ea 03          	shr    $0x3,%rdx
    ca90:	4c 8d 0c 92          	lea    (%rdx,%rdx,4),%r9
    ca94:	4d 01 c9             	add    %r9,%r9
    ca97:	4c 29 c8             	sub    %r9,%rax
    ca9a:	4d 89 c1             	mov    %r8,%r9
    ca9d:	49 89 d0             	mov    %rdx,%r8
    caa0:	83 c0 30             	add    $0x30,%eax
    caa3:	49 83 f9 09          	cmp    $0x9,%r9
    caa7:	41 0f 97 c1          	seta   %r9b
    caab:	85 c9                	test   %ecx,%ecx
    caad:	88 04 0f             	mov    %al,(%rdi,%rcx,1)
    cab0:	0f 95 c2             	setne  %dl
    cab3:	48 83 e9 01          	sub    $0x1,%rcx
    cab7:	41 84 d1             	test   %dl,%r9b
    caba:	75 c4                	jne    ca80 <_ZN10UEFIBridge9DiagWriteEv+0x180>
    cabc:	4d 63 db             	movslq %r11d,%r11
    cabf:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cac4:	4a 8d 0c 1f          	lea    (%rdi,%r11,1),%rcx
    cac8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    cacf:	00 
    cad0:	48 83 c1 01          	add    $0x1,%rcx
    cad4:	ee                   	out    %al,(%dx)
    cad5:	0f b6 01             	movzbl (%rcx),%eax
    cad8:	84 c0                	test   %al,%al
    cada:	75 f4                	jne    cad0 <_ZN10UEFIBridge9DiagWriteEv+0x1d0>
    cadc:	b8 20 00 00 00       	mov    $0x20,%eax
    cae1:	48 8d 0d 82 76 00 00 	lea    0x7682(%rip),%rcx        # 1416a <_data+0x16a>
    cae8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    caed:	0f 1f 00             	nopl   (%rax)
    caf0:	48 83 c1 01          	add    $0x1,%rcx
    caf4:	ee                   	out    %al,(%dx)
    caf5:	0f b6 01             	movzbl (%rcx),%eax
    caf8:	84 c0                	test   %al,%al
    cafa:	75 f4                	jne    caf0 <_ZN10UEFIBridge9DiagWriteEv+0x1f0>
    cafc:	44 8b 05 a9 06 01 00 	mov    0x106a9(%rip),%r8d        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
    cb03:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    cb08:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cb0d:	48 8d 3d cc 82 00 00 	lea    0x82cc(%rip),%rdi        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    cb14:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    cb1b:	00 00 00 00 
    cb1f:	90                   	nop
    cb20:	44 89 c0             	mov    %r8d,%eax
    cb23:	d3 e8                	shr    %cl,%eax
    cb25:	83 e0 0f             	and    $0xf,%eax
    cb28:	0f b6 04 07          	movzbl (%rdi,%rax,1),%eax
    cb2c:	ee                   	out    %al,(%dx)
    cb2d:	83 e9 04             	sub    $0x4,%ecx
    cb30:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    cb33:	75 eb                	jne    cb20 <_ZN10UEFIBridge9DiagWriteEv+0x220>
    cb35:	b8 20 00 00 00       	mov    $0x20,%eax
    cb3a:	48 8d 0d 33 76 00 00 	lea    0x7633(%rip),%rcx        # 14174 <_data+0x174>
    cb41:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cb46:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    cb4d:	00 00 00 
    cb50:	48 83 c1 01          	add    $0x1,%rcx
    cb54:	ee                   	out    %al,(%dx)
    cb55:	0f b6 01             	movzbl (%rcx),%eax
    cb58:	84 c0                	test   %al,%al
    cb5a:	75 f4                	jne    cb50 <_ZN10UEFIBridge9DiagWriteEv+0x250>
    cb5c:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    cb61:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cb66:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    cb6d:	00 00 00 
    cb70:	89 d8                	mov    %ebx,%eax
    cb72:	d3 e8                	shr    %cl,%eax
    cb74:	83 e0 0f             	and    $0xf,%eax
    cb77:	0f b6 04 07          	movzbl (%rdi,%rax,1),%eax
    cb7b:	ee                   	out    %al,(%dx)
    cb7c:	83 e9 04             	sub    $0x4,%ecx
    cb7f:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    cb82:	75 ec                	jne    cb70 <_ZN10UEFIBridge9DiagWriteEv+0x270>
    cb84:	b8 20 00 00 00       	mov    $0x20,%eax
    cb89:	48 8d 0d c7 77 00 00 	lea    0x77c7(%rip),%rcx        # 14357 <_data+0x357>
    cb90:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cb95:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    cb9c:	00 00 00 00 
    cba0:	48 83 c1 01          	add    $0x1,%rcx
    cba4:	ee                   	out    %al,(%dx)
    cba5:	0f b6 01             	movzbl (%rcx),%eax
    cba8:	84 c0                	test   %al,%al
    cbaa:	75 f4                	jne    cba0 <_ZN10UEFIBridge9DiagWriteEv+0x2a0>
    cbac:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    cbb1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cbb6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    cbbd:	00 00 00 
    cbc0:	89 f0                	mov    %esi,%eax
    cbc2:	d3 e8                	shr    %cl,%eax
    cbc4:	83 e0 0f             	and    $0xf,%eax
    cbc7:	0f b6 04 07          	movzbl (%rdi,%rax,1),%eax
    cbcb:	ee                   	out    %al,(%dx)
    cbcc:	83 e9 04             	sub    $0x4,%ecx
    cbcf:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    cbd2:	75 ec                	jne    cbc0 <_ZN10UEFIBridge9DiagWriteEv+0x2c0>
    cbd4:	48 83 c4 40          	add    $0x40,%rsp
    cbd8:	5b                   	pop    %rbx
    cbd9:	c3                   	ret
    cbda:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    cbe0:	b8 30 00 00 00       	mov    $0x30,%eax
    cbe5:	ee                   	out    %al,(%dx)
    cbe6:	e9 f1 fe ff ff       	jmp    cadc <_ZN10UEFIBridge9DiagWriteEv+0x1dc>
    cbeb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>:
    cbf0:	41 54                	push   %r12
    cbf2:	55                   	push   %rbp
    cbf3:	53                   	push   %rbx
    cbf4:	48 89 d3             	mov    %rdx,%rbx
    cbf7:	48 85 f6             	test   %rsi,%rsi
    cbfa:	0f 84 a0 01 00 00    	je     cda0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x1b0>
    cc00:	4c 8b 26             	mov    (%rsi),%r12
    cc03:	48 89 f5             	mov    %rsi,%rbp
    cc06:	4d 85 e4             	test   %r12,%r12
    cc09:	0f 84 91 01 00 00    	je     cda0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x1b0>
    cc0f:	48 83 ec 20          	sub    $0x20,%rsp
    cc13:	48 89 f2             	mov    %rsi,%rdx
    cc16:	31 c9                	xor    %ecx,%ecx
    cc18:	ff d7                	call   *%rdi
    cc1a:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cc1f:	48 89 c7             	mov    %rax,%rdi
    cc22:	b8 0d 00 00 00       	mov    $0xd,%eax
    cc27:	ee                   	out    %al,(%dx)
    cc28:	b8 0a 00 00 00       	mov    $0xa,%eax
    cc2d:	ee                   	out    %al,(%dx)
    cc2e:	b8 5b 00 00 00       	mov    $0x5b,%eax
    cc33:	48 83 c4 20          	add    $0x20,%rsp
    cc37:	48 8d 0d c2 73 00 00 	lea    0x73c2(%rip),%rcx        # 14000 <_data>
    cc3e:	66 90                	xchg   %ax,%ax
    cc40:	48 83 c1 01          	add    $0x1,%rcx
    cc44:	ee                   	out    %al,(%dx)
    cc45:	0f b6 01             	movzbl (%rcx),%eax
    cc48:	84 c0                	test   %al,%al
    cc4a:	75 f4                	jne    cc40 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x50>
    cc4c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    cc51:	ee                   	out    %al,(%dx)
    cc52:	b8 43 00 00 00       	mov    $0x43,%eax
    cc57:	48 8d 0d 22 75 00 00 	lea    0x7522(%rip),%rcx        # 14180 <_data+0x180>
    cc5e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cc63:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    cc6a:	00 00 00 00 
    cc6e:	66 90                	xchg   %ax,%ax
    cc70:	48 83 c1 01          	add    $0x1,%rcx
    cc74:	ee                   	out    %al,(%dx)
    cc75:	0f b6 01             	movzbl (%rcx),%eax
    cc78:	84 c0                	test   %al,%al
    cc7a:	75 f4                	jne    cc70 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x80>
    cc7c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    cc81:	ee                   	out    %al,(%dx)
    cc82:	b8 20 00 00 00       	mov    $0x20,%eax
    cc87:	ee                   	out    %al,(%dx)
    cc88:	48 85 db             	test   %rbx,%rbx
    cc8b:	74 1f                	je     ccac <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0xbc>
    cc8d:	0f b6 03             	movzbl (%rbx),%eax
    cc90:	84 c0                	test   %al,%al
    cc92:	74 18                	je     ccac <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0xbc>
    cc94:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cc99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    cca0:	48 83 c3 01          	add    $0x1,%rbx
    cca4:	ee                   	out    %al,(%dx)
    cca5:	0f b6 03             	movzbl (%rbx),%eax
    cca8:	84 c0                	test   %al,%al
    ccaa:	75 f4                	jne    cca0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0xb0>
    ccac:	b8 20 00 00 00       	mov    $0x20,%eax
    ccb1:	48 8d 0d dd 74 00 00 	lea    0x74dd(%rip),%rcx        # 14195 <_data+0x195>
    ccb8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ccbd:	0f 1f 00             	nopl   (%rax)
    ccc0:	48 83 c1 01          	add    $0x1,%rcx
    ccc4:	ee                   	out    %al,(%dx)
    ccc5:	0f b6 01             	movzbl (%rcx),%eax
    ccc8:	84 c0                	test   %al,%al
    ccca:	75 f4                	jne    ccc0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0xd0>
    cccc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    ccd1:	48 8d 35 28 81 00 00 	lea    0x8128(%rip),%rsi        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    ccd8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ccdd:	0f 1f 00             	nopl   (%rax)
    cce0:	4c 89 e0             	mov    %r12,%rax
    cce3:	48 d3 e8             	shr    %cl,%rax
    cce6:	83 e0 0f             	and    $0xf,%eax
    cce9:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
    cced:	ee                   	out    %al,(%dx)
    ccee:	83 e9 04             	sub    $0x4,%ecx
    ccf1:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    ccf4:	75 ea                	jne    cce0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0xf0>
    ccf6:	b8 20 00 00 00       	mov    $0x20,%eax
    ccfb:	48 8d 0d 90 74 00 00 	lea    0x7490(%rip),%rcx        # 14192 <_data+0x192>
    cd02:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cd07:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    cd0e:	00 00 
    cd10:	48 83 c1 01          	add    $0x1,%rcx
    cd14:	ee                   	out    %al,(%dx)
    cd15:	0f b6 01             	movzbl (%rcx),%eax
    cd18:	84 c0                	test   %al,%al
    cd1a:	75 f4                	jne    cd10 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x120>
    cd1c:	4c 8b 45 00          	mov    0x0(%rbp),%r8
    cd20:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    cd25:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cd2a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    cd30:	4c 89 c0             	mov    %r8,%rax
    cd33:	48 d3 e8             	shr    %cl,%rax
    cd36:	83 e0 0f             	and    $0xf,%eax
    cd39:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
    cd3d:	ee                   	out    %al,(%dx)
    cd3e:	83 e9 04             	sub    $0x4,%ecx
    cd41:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    cd44:	75 ea                	jne    cd30 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x140>
    cd46:	b8 20 00 00 00       	mov    $0x20,%eax
    cd4b:	48 8d 0d 05 76 00 00 	lea    0x7605(%rip),%rcx        # 14357 <_data+0x357>
    cd52:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cd57:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    cd5e:	00 00 
    cd60:	48 83 c1 01          	add    $0x1,%rcx
    cd64:	ee                   	out    %al,(%dx)
    cd65:	0f b6 01             	movzbl (%rcx),%eax
    cd68:	84 c0                	test   %al,%al
    cd6a:	75 f4                	jne    cd60 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x170>
    cd6c:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    cd71:	48 8d 35 68 80 00 00 	lea    0x8068(%rip),%rsi        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    cd78:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cd7d:	0f 1f 00             	nopl   (%rax)
    cd80:	89 f8                	mov    %edi,%eax
    cd82:	d3 e8                	shr    %cl,%eax
    cd84:	83 e0 0f             	and    $0xf,%eax
    cd87:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
    cd8b:	ee                   	out    %al,(%dx)
    cd8c:	83 e9 04             	sub    $0x4,%ecx
    cd8f:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    cd92:	75 ec                	jne    cd80 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x190>
    cd94:	5b                   	pop    %rbx
    cd95:	5d                   	pop    %rbp
    cd96:	41 5c                	pop    %r12
    cd98:	c3                   	ret
    cd99:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    cda0:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cda5:	b8 0d 00 00 00       	mov    $0xd,%eax
    cdaa:	ee                   	out    %al,(%dx)
    cdab:	b8 0a 00 00 00       	mov    $0xa,%eax
    cdb0:	ee                   	out    %al,(%dx)
    cdb1:	b8 5b 00 00 00       	mov    $0x5b,%eax
    cdb6:	48 8d 0d 43 72 00 00 	lea    0x7243(%rip),%rcx        # 14000 <_data>
    cdbd:	0f 1f 00             	nopl   (%rax)
    cdc0:	48 83 c1 01          	add    $0x1,%rcx
    cdc4:	ee                   	out    %al,(%dx)
    cdc5:	0f b6 01             	movzbl (%rcx),%eax
    cdc8:	84 c0                	test   %al,%al
    cdca:	75 f4                	jne    cdc0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x1d0>
    cdcc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    cdd1:	ee                   	out    %al,(%dx)
    cdd2:	b8 43 00 00 00       	mov    $0x43,%eax
    cdd7:	48 8d 0d a2 73 00 00 	lea    0x73a2(%rip),%rcx        # 14180 <_data+0x180>
    cdde:	ba f8 03 00 00       	mov    $0x3f8,%edx
    cde3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    cdea:	00 00 00 00 
    cdee:	66 90                	xchg   %ax,%ax
    cdf0:	48 83 c1 01          	add    $0x1,%rcx
    cdf4:	ee                   	out    %al,(%dx)
    cdf5:	0f b6 01             	movzbl (%rcx),%eax
    cdf8:	84 c0                	test   %al,%al
    cdfa:	75 f4                	jne    cdf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x200>
    cdfc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    ce01:	ee                   	out    %al,(%dx)
    ce02:	b8 20 00 00 00       	mov    $0x20,%eax
    ce07:	ee                   	out    %al,(%dx)
    ce08:	48 85 db             	test   %rbx,%rbx
    ce0b:	74 1f                	je     ce2c <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x23c>
    ce0d:	0f b6 03             	movzbl (%rbx),%eax
    ce10:	84 c0                	test   %al,%al
    ce12:	74 18                	je     ce2c <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x23c>
    ce14:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ce19:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ce20:	48 83 c3 01          	add    $0x1,%rbx
    ce24:	ee                   	out    %al,(%dx)
    ce25:	0f b6 03             	movzbl (%rbx),%eax
    ce28:	84 c0                	test   %al,%al
    ce2a:	75 f4                	jne    ce20 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x230>
    ce2c:	b8 20 00 00 00       	mov    $0x20,%eax
    ce31:	48 8d 0d 4c 73 00 00 	lea    0x734c(%rip),%rcx        # 14184 <_data+0x184>
    ce38:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ce3d:	0f 1f 00             	nopl   (%rax)
    ce40:	48 83 c1 01          	add    $0x1,%rcx
    ce44:	ee                   	out    %al,(%dx)
    ce45:	0f b6 01             	movzbl (%rcx),%eax
    ce48:	84 c0                	test   %al,%al
    ce4a:	75 f4                	jne    ce40 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc+0x250>
    ce4c:	5b                   	pop    %rbx
    ce4d:	5d                   	pop    %rbp
    ce4e:	41 5c                	pop    %r12
    ce50:	c3                   	ret
    ce51:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ce58:	00 00 00 
    ce5b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000ce60 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv>:
    ce60:	41 54                	push   %r12
    ce62:	41 b8 00 04 00 00    	mov    $0x400,%r8d
    ce68:	ba 06 00 00 00       	mov    $0x6,%edx
    ce6d:	31 c9                	xor    %ecx,%ecx
    ce6f:	55                   	push   %rbp
    ce70:	48 89 fd             	mov    %rdi,%rbp
    ce73:	53                   	push   %rbx
    ce74:	48 83 ec 40          	sub    $0x40,%rsp
    ce78:	48 8d 1d 51 03 01 00 	lea    0x10351(%rip),%rbx        # 1d1d0 <BS>
    ce7f:	48 c7 44 24 28 00 00 	movq   $0x0,0x28(%rsp)
    ce86:	00 00 
    ce88:	4c 8d 4c 24 28       	lea    0x28(%rsp),%r9
    ce8d:	48 8b 03             	mov    (%rbx),%rax
    ce90:	ff 50 28             	call   *0x28(%rax)
    ce93:	48 83 c4 20          	add    $0x20,%rsp
    ce97:	49 89 c4             	mov    %rax,%r12
    ce9a:	48 85 c0             	test   %rax,%rax
    ce9d:	0f 88 fe 01 00 00    	js     d0a1 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x241>
    cea3:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
    cea8:	48 8b 03             	mov    (%rbx),%rax
    ceab:	48 83 ec 20          	sub    $0x20,%rsp
    ceaf:	45 31 c0             	xor    %r8d,%r8d
    ceb2:	48 c7 45 08 00 00 40 	movq   $0x400000,0x8(%rbp)
    ceb9:	00 
    ceba:	ba 00 00 40 00       	mov    $0x400000,%edx
    cebf:	48 89 4d 00          	mov    %rcx,0x0(%rbp)
    cec3:	ff 90 68 01 00 00    	call   *0x168(%rax)
    cec9:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
    cece:	66 0f 6f 05 5a 7f 00 	movdqa 0x7f5a(%rip),%xmm0        # 14e30 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x30>
    ced5:	00 
    ced6:	48 83 c4 20          	add    $0x20,%rsp
    ceda:	80 3d 7f fe 00 00 00 	cmpb   $0x0,0xfe7f(%rip)        # 1cd60 <_ZZN10UEFIBridge16SharedMemoryPool5CRC32EPKvmE4init>
    cee1:	48 8d 3d 98 fe 00 00 	lea    0xfe98(%rip),%rdi        # 1cd80 <_ZZN10UEFIBridge16SharedMemoryPool5CRC32EPKvmE5table>
    cee8:	48 89 4d 10          	mov    %rcx,0x10(%rbp)
    ceec:	49 89 c8             	mov    %rcx,%r8
    ceef:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%rcx)
    cef6:	c7 41 50 00 00 00 00 	movl   $0x0,0x50(%rcx)
    cefd:	c7 41 14 00 00 00 00 	movl   $0x0,0x14(%rcx)
    cf04:	0f 11 01             	movups %xmm0,(%rcx)
    cf07:	c7 41 18 00 00 00 00 	movl   $0x0,0x18(%rcx)
    cf0e:	c7 41 1c 00 00 00 00 	movl   $0x0,0x1c(%rcx)
    cf15:	48 c7 41 20 00 00 00 	movq   $0x0,0x20(%rcx)
    cf1c:	00 
    cf1d:	48 c7 41 28 00 00 00 	movq   $0x0,0x28(%rcx)
    cf24:	00 
    cf25:	48 c7 41 30 00 00 00 	movq   $0x0,0x30(%rcx)
    cf2c:	00 
    cf2d:	48 c7 41 38 00 00 00 	movq   $0x0,0x38(%rcx)
    cf34:	00 
    cf35:	c7 41 40 00 00 00 00 	movl   $0x0,0x40(%rcx)
    cf3c:	48 c7 41 48 00 00 00 	movq   $0x0,0x48(%rcx)
    cf43:	00 
    cf44:	0f 85 b6 00 00 00    	jne    d000 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x1a0>
    cf4a:	b8 04 00 00 00       	mov    $0x4,%eax
    cf4f:	66 0f 6f 1d c9 7e 00 	movdqa 0x7ec9(%rip),%xmm3        # 14e20 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x20>
    cf56:	00 
    cf57:	48 89 fa             	mov    %rdi,%rdx
    cf5a:	48 8d b7 00 04 00 00 	lea    0x400(%rdi),%rsi
    cf61:	66 0f 6e e8          	movd   %eax,%xmm5
    cf65:	b8 01 00 00 00       	mov    $0x1,%eax
    cf6a:	66 0f 6e e0          	movd   %eax,%xmm4
    cf6e:	66 0f 70 ed 00       	pshufd $0x0,%xmm5,%xmm5
    cf73:	66 0f 70 e4 00       	pshufd $0x0,%xmm4,%xmm4
    cf78:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    cf7f:	00 
    cf80:	66 0f 6f d3          	movdqa %xmm3,%xmm2
    cf84:	b8 08 00 00 00       	mov    $0x8,%eax
    cf89:	66 0f fe dd          	paddd  %xmm5,%xmm3
    cf8d:	0f 1f 00             	nopl   (%rax)
    cf90:	66 0f 6f f2          	movdqa %xmm2,%xmm6
    cf94:	66 0f 72 d2 01       	psrld  $0x1,%xmm2
    cf99:	66 0f db f4          	pand   %xmm4,%xmm6
    cf9d:	66 0f 6f c6          	movdqa %xmm6,%xmm0
    cfa1:	66 0f 72 f0 04       	pslld  $0x4,%xmm0
    cfa6:	66 0f fa c6          	psubd  %xmm6,%xmm0
    cfaa:	66 0f 72 f0 03       	pslld  $0x3,%xmm0
    cfaf:	66 0f fa c6          	psubd  %xmm6,%xmm0
    cfb3:	66 0f 72 f0 05       	pslld  $0x5,%xmm0
    cfb8:	66 0f fa c6          	psubd  %xmm6,%xmm0
    cfbc:	66 0f 72 f0 02       	pslld  $0x2,%xmm0
    cfc1:	66 0f fe c6          	paddd  %xmm6,%xmm0
    cfc5:	66 0f 6f c8          	movdqa %xmm0,%xmm1
    cfc9:	66 0f 72 f1 0a       	pslld  $0xa,%xmm1
    cfce:	66 0f fa c8          	psubd  %xmm0,%xmm1
    cfd2:	66 0f 72 f1 03       	pslld  $0x3,%xmm1
    cfd7:	66 0f 6f c1          	movdqa %xmm1,%xmm0
    cfdb:	66 0f fe c6          	paddd  %xmm6,%xmm0
    cfdf:	66 0f 72 f0 05       	pslld  $0x5,%xmm0
    cfe4:	66 0f ef d0          	pxor   %xmm0,%xmm2
    cfe8:	83 e8 01             	sub    $0x1,%eax
    cfeb:	75 a3                	jne    cf90 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x130>
    cfed:	0f 29 12             	movaps %xmm2,(%rdx)
    cff0:	48 83 c2 10          	add    $0x10,%rdx
    cff4:	48 39 f2             	cmp    %rsi,%rdx
    cff7:	75 87                	jne    cf80 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x120>
    cff9:	c6 05 60 fd 00 00 01 	movb   $0x1,0xfd60(%rip)        # 1cd60 <_ZZN10UEFIBridge16SharedMemoryPool5CRC32EPKvmE4init>
    d000:	48 8d 71 58          	lea    0x58(%rcx),%rsi
    d004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    d009:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d010:	00 00 00 00 
    d014:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d01b:	00 00 00 00 
    d01f:	90                   	nop
    d020:	0f b6 11             	movzbl (%rcx),%edx
    d023:	48 83 c1 01          	add    $0x1,%rcx
    d027:	31 c2                	xor    %eax,%edx
    d029:	c1 e8 08             	shr    $0x8,%eax
    d02c:	0f b6 d2             	movzbl %dl,%edx
    d02f:	33 04 97             	xor    (%rdi,%rdx,4),%eax
    d032:	48 39 ce             	cmp    %rcx,%rsi
    d035:	75 e9                	jne    d020 <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x1c0>
    d037:	f7 d0                	not    %eax
    d039:	48 83 ec 08          	sub    $0x8,%rsp
    d03d:	48 8b 15 fc 7d 00 00 	mov    0x7dfc(%rip),%rdx        # 14e40 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x40>
    d044:	41 b9 10 00 00 00    	mov    $0x10,%r9d
    d04a:	41 89 40 50          	mov    %eax,0x50(%r8)
    d04e:	48 8b 45 00          	mov    0x0(%rbp),%rax
    d052:	41 b8 07 00 00 00    	mov    $0x7,%r8d
    d058:	48 8d 0d 0b 78 00 00 	lea    0x780b(%rip),%rcx        # 1486a <_data+0x86a>
    d05f:	48 89 54 24 18       	mov    %rdx,0x18(%rsp)
    d064:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    d069:	48 8d 05 b0 01 01 00 	lea    0x101b0(%rip),%rax        # 1d220 <RT>
    d070:	48 8d 54 24 18       	lea    0x18(%rsp),%rdx
    d075:	48 8b 00             	mov    (%rax),%rax
    d078:	52                   	push   %rdx
    d079:	48 8d 15 e0 8d 00 00 	lea    0x8de0(%rip),%rdx        # 15e60 <_ZN10UEFIBridge19gInfinityMemVarGuidE>
    d080:	48 83 ec 20          	sub    $0x20,%rsp
    d084:	ff 50 58             	call   *0x58(%rax)
    d087:	48 83 c4 30          	add    $0x30,%rsp
    d08b:	49 89 c4             	mov    %rax,%r12
    d08e:	48 85 c0             	test   %rax,%rax
    d091:	78 1a                	js     d0ad <_ZN10UEFIBridge16SharedMemoryPool10InitializeEv+0x24d>
    d093:	48 8b 45 10          	mov    0x10(%rbp),%rax
    d097:	45 31 e4             	xor    %r12d,%r12d
    d09a:	c7 40 40 01 00 00 00 	movl   $0x1,0x40(%rax)
    d0a1:	48 83 c4 20          	add    $0x20,%rsp
    d0a5:	4c 89 e0             	mov    %r12,%rax
    d0a8:	5b                   	pop    %rbx
    d0a9:	5d                   	pop    %rbp
    d0aa:	41 5c                	pop    %r12
    d0ac:	c3                   	ret
    d0ad:	48 8b 45 08          	mov    0x8(%rbp),%rax
    d0b1:	31 d2                	xor    %edx,%edx
    d0b3:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    d0b7:	a9 ff 0f 00 00       	test   $0xfff,%eax
    d0bc:	0f 95 c2             	setne  %dl
    d0bf:	48 c1 e8 0c          	shr    $0xc,%rax
    d0c3:	48 83 ec 20          	sub    $0x20,%rsp
    d0c7:	48 01 c2             	add    %rax,%rdx
    d0ca:	48 8b 03             	mov    (%rbx),%rax
    d0cd:	ff 50 30             	call   *0x30(%rax)
    d0d0:	48 83 c4 20          	add    $0x20,%rsp
    d0d4:	48 c7 45 00 00 00 00 	movq   $0x0,0x0(%rbp)
    d0db:	00 
    d0dc:	4c 89 e0             	mov    %r12,%rax
    d0df:	48 c7 45 10 00 00 00 	movq   $0x0,0x10(%rbp)
    d0e6:	00 
    d0e7:	48 83 c4 20          	add    $0x20,%rsp
    d0eb:	5b                   	pop    %rbx
    d0ec:	5d                   	pop    %rbp
    d0ed:	41 5c                	pop    %r12
    d0ef:	c3                   	ret

000000000000d0f0 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm>:
    d0f0:	41 57                	push   %r15
    d0f2:	41 56                	push   %r14
    d0f4:	41 55                	push   %r13
    d0f6:	41 54                	push   %r12
    d0f8:	55                   	push   %rbp
    d0f9:	48 89 fd             	mov    %rdi,%rbp
    d0fc:	53                   	push   %rbx
    d0fd:	48 89 f3             	mov    %rsi,%rbx
    d100:	48 83 ec 28          	sub    $0x28,%rsp
    d104:	48 0f ba e6 2f       	bt     $0x2f,%rsi
    d109:	73 2d                	jae    d138 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x48>
    d10b:	48 b9 00 00 00 00 00 	movabs $0xffff000000000000,%rcx
    d112:	00 ff ff 
    d115:	48 89 f0             	mov    %rsi,%rax
    d118:	48 f7 d0             	not    %rax
    d11b:	48 85 c8             	test   %rcx,%rax
    d11e:	74 21                	je     d141 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x51>
    d120:	31 c0                	xor    %eax,%eax
    d122:	48 83 c4 28          	add    $0x28,%rsp
    d126:	5b                   	pop    %rbx
    d127:	5d                   	pop    %rbp
    d128:	41 5c                	pop    %r12
    d12a:	41 5d                	pop    %r13
    d12c:	41 5e                	pop    %r14
    d12e:	41 5f                	pop    %r15
    d130:	c3                   	ret
    d131:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d138:	48 89 f0             	mov    %rsi,%rax
    d13b:	48 c1 e8 30          	shr    $0x30,%rax
    d13f:	75 df                	jne    d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d141:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
    d147:	75 d7                	jne    d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d149:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    d150:	00 00 
    d152:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    d156:	74 c8                	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d158:	49 bc 00 f0 ff ff ff 	movabs $0xffffffffff000,%r12
    d15f:	ff 0f 00 
    d162:	48 89 de             	mov    %rbx,%rsi
    d165:	49 bd f7 ff ff ff 0f 	movabs $0xffffffff7,%r13
    d16c:	00 00 00 
    d16f:	48 c1 ee 24          	shr    $0x24,%rsi
    d173:	4c 21 e2             	and    %r12,%rdx
    d176:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    d17c:	48 01 d6             	add    %rdx,%rsi
    d17f:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    d183:	49 39 c5             	cmp    %rax,%r13
    d186:	72 98                	jb     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d188:	0f 20 d8             	mov    %cr3,%rax
    d18b:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    d190:	9c                   	pushf
    d191:	41 5f                	pop    %r15
    d193:	fa                   	cli
    d194:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    d198:	0f 22 da             	mov    %rdx,%cr3
    d19b:	4c 8d 74 24 18       	lea    0x18(%rsp),%r14
    d1a0:	ba 08 00 00 00       	mov    $0x8,%edx
    d1a5:	4c 89 f7             	mov    %r14,%rdi
    d1a8:	e8 d3 9b ff ff       	call   6d80 <CopyMem>
    d1ad:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    d1b2:	0f 22 d8             	mov    %rax,%cr3
    d1b5:	41 57                	push   %r15
    d1b7:	9d                   	popf
    d1b8:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    d1bd:	a8 01                	test   $0x1,%al
    d1bf:	0f 84 5b ff ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d1c5:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    d1cc:	00 00 
    d1ce:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    d1d2:	0f 84 48 ff ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d1d8:	48 89 de             	mov    %rbx,%rsi
    d1db:	4c 21 e0             	and    %r12,%rax
    d1de:	48 c1 ee 1b          	shr    $0x1b,%rsi
    d1e2:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    d1e8:	48 01 c6             	add    %rax,%rsi
    d1eb:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    d1ef:	49 39 c5             	cmp    %rax,%r13
    d1f2:	0f 82 28 ff ff ff    	jb     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d1f8:	0f 20 d8             	mov    %cr3,%rax
    d1fb:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    d200:	9c                   	pushf
    d201:	41 5f                	pop    %r15
    d203:	fa                   	cli
    d204:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    d208:	0f 22 da             	mov    %rdx,%cr3
    d20b:	ba 08 00 00 00       	mov    $0x8,%edx
    d210:	4c 89 f7             	mov    %r14,%rdi
    d213:	e8 68 9b ff ff       	call   6d80 <CopyMem>
    d218:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    d21d:	0f 22 d8             	mov    %rax,%cr3
    d220:	41 57                	push   %r15
    d222:	9d                   	popf
    d223:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    d228:	a8 01                	test   $0x1,%al
    d22a:	0f 84 f0 fe ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d230:	49 21 c4             	and    %rax,%r12
    d233:	a8 80                	test   $0x80,%al
    d235:	74 19                	je     d250 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x160>
    d237:	48 89 d8             	mov    %rbx,%rax
    d23a:	25 ff ff ff 3f       	and    $0x3fffffff,%eax
    d23f:	4c 01 e0             	add    %r12,%rax
    d242:	e9 db fe ff ff       	jmp    d122 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x32>
    d247:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    d24e:	00 00 
    d250:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    d257:	00 00 
    d259:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    d25d:	0f 84 bd fe ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d263:	48 89 de             	mov    %rbx,%rsi
    d266:	48 c1 ee 12          	shr    $0x12,%rsi
    d26a:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    d270:	4c 01 e6             	add    %r12,%rsi
    d273:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    d277:	49 39 c5             	cmp    %rax,%r13
    d27a:	0f 82 a0 fe ff ff    	jb     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d280:	41 0f 20 dd          	mov    %cr3,%r13
    d284:	9c                   	pushf
    d285:	41 5c                	pop    %r12
    d287:	fa                   	cli
    d288:	48 8b 45 00          	mov    0x0(%rbp),%rax
    d28c:	0f 22 d8             	mov    %rax,%cr3
    d28f:	ba 08 00 00 00       	mov    $0x8,%edx
    d294:	4c 89 f7             	mov    %r14,%rdi
    d297:	e8 e4 9a ff ff       	call   6d80 <CopyMem>
    d29c:	41 0f 22 dd          	mov    %r13,%cr3
    d2a0:	41 54                	push   %r12
    d2a2:	9d                   	popf
    d2a3:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    d2a8:	a8 01                	test   $0x1,%al
    d2aa:	0f 84 70 fe ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d2b0:	49 bc 00 f0 ff ff ff 	movabs $0xffffffffff000,%r12
    d2b7:	ff 0f 00 
    d2ba:	48 89 c2             	mov    %rax,%rdx
    d2bd:	4c 21 e2             	and    %r12,%rdx
    d2c0:	a8 80                	test   $0x80,%al
    d2c2:	74 14                	je     d2d8 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x1e8>
    d2c4:	48 89 d8             	mov    %rbx,%rax
    d2c7:	25 ff ff 1f 00       	and    $0x1fffff,%eax
    d2cc:	48 01 d0             	add    %rdx,%rax
    d2cf:	e9 4e fe ff ff       	jmp    d122 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x32>
    d2d4:	0f 1f 40 00          	nopl   0x0(%rax)
    d2d8:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
    d2df:	00 00 
    d2e1:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    d2e5:	0f 84 35 fe ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d2eb:	48 89 de             	mov    %rbx,%rsi
    d2ee:	48 c1 ee 09          	shr    $0x9,%rsi
    d2f2:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    d2f8:	48 01 d6             	add    %rdx,%rsi
    d2fb:	48 ba f7 ff ff ff 0f 	movabs $0xffffffff7,%rdx
    d302:	00 00 00 
    d305:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    d309:	48 39 c2             	cmp    %rax,%rdx
    d30c:	0f 82 0e fe ff ff    	jb     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d312:	41 0f 20 df          	mov    %cr3,%r15
    d316:	9c                   	pushf
    d317:	41 5d                	pop    %r13
    d319:	fa                   	cli
    d31a:	48 8b 45 00          	mov    0x0(%rbp),%rax
    d31e:	0f 22 d8             	mov    %rax,%cr3
    d321:	ba 08 00 00 00       	mov    $0x8,%edx
    d326:	4c 89 f7             	mov    %r14,%rdi
    d329:	e8 52 9a ff ff       	call   6d80 <CopyMem>
    d32e:	41 0f 22 df          	mov    %r15,%cr3
    d332:	41 55                	push   %r13
    d334:	9d                   	popf
    d335:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    d33a:	a8 01                	test   $0x1,%al
    d33c:	0f 84 de fd ff ff    	je     d120 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x30>
    d342:	4c 21 e0             	and    %r12,%rax
    d345:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    d34b:	48 09 d8             	or     %rbx,%rax
    d34e:	e9 cf fd ff ff       	jmp    d122 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm+0x32>
    d353:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d35a:	00 00 00 
    d35d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d364:	00 00 00 
    d367:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d36e:	00 00 00 
    d371:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d378:	00 00 00 
    d37b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000d380 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm>:
    d380:	41 57                	push   %r15
    d382:	49 89 d2             	mov    %rdx,%r10
    d385:	49 89 c9             	mov    %rcx,%r9
    d388:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d38d:	41 56                	push   %r14
    d38f:	b8 0d 00 00 00       	mov    $0xd,%eax
    d394:	41 55                	push   %r13
    d396:	41 54                	push   %r12
    d398:	55                   	push   %rbp
    d399:	57                   	push   %rdi
    d39a:	56                   	push   %rsi
    d39b:	53                   	push   %rbx
    d39c:	48 81 ec 08 01 00 00 	sub    $0x108,%rsp
    d3a3:	0f 29 74 24 60       	movaps %xmm6,0x60(%rsp)
    d3a8:	0f 29 7c 24 70       	movaps %xmm7,0x70(%rsp)
    d3ad:	44 0f 29 84 24 80 00 	movaps %xmm8,0x80(%rsp)
    d3b4:	00 00 
    d3b6:	44 0f 29 8c 24 90 00 	movaps %xmm9,0x90(%rsp)
    d3bd:	00 00 
    d3bf:	44 0f 29 94 24 a0 00 	movaps %xmm10,0xa0(%rsp)
    d3c6:	00 00 
    d3c8:	44 0f 29 9c 24 b0 00 	movaps %xmm11,0xb0(%rsp)
    d3cf:	00 00 
    d3d1:	44 0f 29 a4 24 c0 00 	movaps %xmm12,0xc0(%rsp)
    d3d8:	00 00 
    d3da:	44 0f 29 ac 24 d0 00 	movaps %xmm13,0xd0(%rsp)
    d3e1:	00 00 
    d3e3:	44 0f 29 b4 24 e0 00 	movaps %xmm14,0xe0(%rsp)
    d3ea:	00 00 
    d3ec:	44 0f 29 bc 24 f0 00 	movaps %xmm15,0xf0(%rsp)
    d3f3:	00 00 
    d3f5:	ee                   	out    %al,(%dx)
    d3f6:	b8 0a 00 00 00       	mov    $0xa,%eax
    d3fb:	ee                   	out    %al,(%dx)
    d3fc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d401:	48 8d 0d f8 6b 00 00 	lea    0x6bf8(%rip),%rcx        # 14000 <_data>
    d408:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    d40f:	00 
    d410:	48 83 c1 01          	add    $0x1,%rcx
    d414:	ee                   	out    %al,(%dx)
    d415:	0f b6 01             	movzbl (%rcx),%eax
    d418:	84 c0                	test   %al,%al
    d41a:	75 f4                	jne    d410 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x90>
    d41c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d421:	ee                   	out    %al,(%dx)
    d422:	b8 45 00 00 00       	mov    $0x45,%eax
    d427:	48 8d 0d 6b 6d 00 00 	lea    0x6d6b(%rip),%rcx        # 14199 <_data+0x199>
    d42e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d433:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d43a:	00 00 00 00 
    d43e:	66 90                	xchg   %ax,%ax
    d440:	48 83 c1 01          	add    $0x1,%rcx
    d444:	ee                   	out    %al,(%dx)
    d445:	0f b6 01             	movzbl (%rcx),%eax
    d448:	84 c0                	test   %al,%al
    d44a:	75 f4                	jne    d440 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xc0>
    d44c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    d451:	ee                   	out    %al,(%dx)
    d452:	b8 20 00 00 00       	mov    $0x20,%eax
    d457:	ee                   	out    %al,(%dx)
    d458:	b8 45 00 00 00       	mov    $0x45,%eax
    d45d:	48 8d 0d 39 6d 00 00 	lea    0x6d39(%rip),%rcx        # 1419d <_data+0x19d>
    d464:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d469:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d470:	48 83 c1 01          	add    $0x1,%rcx
    d474:	ee                   	out    %al,(%dx)
    d475:	0f b6 01             	movzbl (%rcx),%eax
    d478:	84 c0                	test   %al,%al
    d47a:	75 f4                	jne    d470 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xf0>
    d47c:	48 83 3d 8c f8 00 00 	cmpq   $0x0,0xf88c(%rip)        # 1cd10 <_ZN10UEFIBridge10CR3Capture9instance_E>
    d483:	00 
    d484:	0f 84 a9 08 00 00    	je     dd33 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x9b3>
    d48a:	48 8d 1d 3f fd 00 00 	lea    0xfd3f(%rip),%rbx        # 1d1d0 <BS>
    d491:	4c 8b 1d 70 f8 00 00 	mov    0xf870(%rip),%r11        # 1cd08 <_ZN10UEFIBridge10CR3Capture13orig_exit_bs_E>
    d498:	48 8b 0b             	mov    (%rbx),%rcx
    d49b:	8b 71 0c             	mov    0xc(%rcx),%esi
    d49e:	4c 89 99 e8 00 00 00 	mov    %r11,0xe8(%rcx)
    d4a5:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%rcx)
    d4ac:	48 85 f6             	test   %rsi,%rsi
    d4af:	0f 84 16 09 00 00    	je     ddcb <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa4b>
    d4b5:	49 89 c8             	mov    %rcx,%r8
    d4b8:	48 01 ce             	add    %rcx,%rsi
    d4bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    d4c0:	41 0f b6 10          	movzbl (%r8),%edx
    d4c4:	31 d0                	xor    %edx,%eax
    d4c6:	ba 08 00 00 00       	mov    $0x8,%edx
    d4cb:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d4d2:	00 00 00 00 
    d4d6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d4dd:	00 00 00 
    d4e0:	89 c7                	mov    %eax,%edi
    d4e2:	83 e0 01             	and    $0x1,%eax
    d4e5:	f7 d8                	neg    %eax
    d4e7:	d1 ef                	shr    $1,%edi
    d4e9:	25 20 83 b8 ed       	and    $0xedb88320,%eax
    d4ee:	31 f8                	xor    %edi,%eax
    d4f0:	83 ea 01             	sub    $0x1,%edx
    d4f3:	75 eb                	jne    d4e0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x160>
    d4f5:	49 83 c0 01          	add    $0x1,%r8
    d4f9:	4c 39 c6             	cmp    %r8,%rsi
    d4fc:	75 c2                	jne    d4c0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x140>
    d4fe:	f7 d0                	not    %eax
    d500:	89 41 10             	mov    %eax,0x10(%rcx)
    d503:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d508:	b8 0d 00 00 00       	mov    $0xd,%eax
    d50d:	ee                   	out    %al,(%dx)
    d50e:	b8 0a 00 00 00       	mov    $0xa,%eax
    d513:	ee                   	out    %al,(%dx)
    d514:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d519:	48 8d 0d e0 6a 00 00 	lea    0x6ae0(%rip),%rcx        # 14000 <_data>
    d520:	48 83 c1 01          	add    $0x1,%rcx
    d524:	ee                   	out    %al,(%dx)
    d525:	0f b6 01             	movzbl (%rcx),%eax
    d528:	84 c0                	test   %al,%al
    d52a:	75 f4                	jne    d520 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x1a0>
    d52c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d531:	ee                   	out    %al,(%dx)
    d532:	b8 45 00 00 00       	mov    $0x45,%eax
    d537:	48 8d 0d 5b 6c 00 00 	lea    0x6c5b(%rip),%rcx        # 14199 <_data+0x199>
    d53e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d543:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d54a:	00 00 00 00 
    d54e:	66 90                	xchg   %ax,%ax
    d550:	48 83 c1 01          	add    $0x1,%rcx
    d554:	ee                   	out    %al,(%dx)
    d555:	0f b6 01             	movzbl (%rcx),%eax
    d558:	84 c0                	test   %al,%al
    d55a:	75 f4                	jne    d550 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x1d0>
    d55c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    d561:	ee                   	out    %al,(%dx)
    d562:	b8 20 00 00 00       	mov    $0x20,%eax
    d567:	ee                   	out    %al,(%dx)
    d568:	b8 63 00 00 00       	mov    $0x63,%eax
    d56d:	48 8d 0d 7c 71 00 00 	lea    0x717c(%rip),%rcx        # 146f0 <_data+0x6f0>
    d574:	be f8 03 00 00       	mov    $0x3f8,%esi
    d579:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d580:	48 83 c1 01          	add    $0x1,%rcx
    d584:	89 f2                	mov    %esi,%edx
    d586:	ee                   	out    %al,(%dx)
    d587:	0f b6 01             	movzbl (%rcx),%eax
    d58a:	84 c0                	test   %al,%al
    d58c:	75 f2                	jne    d580 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x200>
    d58e:	4c 89 d2             	mov    %r10,%rdx
    d591:	4c 89 c9             	mov    %r9,%rcx
    d594:	41 ff d3             	call   *%r11
    d597:	89 f2                	mov    %esi,%edx
    d599:	48 89 c5             	mov    %rax,%rbp
    d59c:	b8 0d 00 00 00       	mov    $0xd,%eax
    d5a1:	ee                   	out    %al,(%dx)
    d5a2:	b8 0a 00 00 00       	mov    $0xa,%eax
    d5a7:	ee                   	out    %al,(%dx)
    d5a8:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d5ad:	48 8d 0d 4c 6a 00 00 	lea    0x6a4c(%rip),%rcx        # 14000 <_data>
    d5b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d5b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d5c0:	48 83 c1 01          	add    $0x1,%rcx
    d5c4:	ee                   	out    %al,(%dx)
    d5c5:	0f b6 01             	movzbl (%rcx),%eax
    d5c8:	84 c0                	test   %al,%al
    d5ca:	75 f4                	jne    d5c0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x240>
    d5cc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d5d1:	ee                   	out    %al,(%dx)
    d5d2:	b8 45 00 00 00       	mov    $0x45,%eax
    d5d7:	48 8d 0d bb 6b 00 00 	lea    0x6bbb(%rip),%rcx        # 14199 <_data+0x199>
    d5de:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d5e3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d5ea:	00 00 00 00 
    d5ee:	66 90                	xchg   %ax,%ax
    d5f0:	48 83 c1 01          	add    $0x1,%rcx
    d5f4:	ee                   	out    %al,(%dx)
    d5f5:	0f b6 01             	movzbl (%rcx),%eax
    d5f8:	84 c0                	test   %al,%al
    d5fa:	75 f4                	jne    d5f0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x270>
    d5fc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    d601:	ee                   	out    %al,(%dx)
    d602:	b8 20 00 00 00       	mov    $0x20,%eax
    d607:	ee                   	out    %al,(%dx)
    d608:	b8 6f 00 00 00       	mov    $0x6f,%eax
    d60d:	48 8d 0d 04 71 00 00 	lea    0x7104(%rip),%rcx        # 14718 <_data+0x718>
    d614:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d619:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d620:	48 83 c1 01          	add    $0x1,%rcx
    d624:	ee                   	out    %al,(%dx)
    d625:	0f b6 01             	movzbl (%rcx),%eax
    d628:	84 c0                	test   %al,%al
    d62a:	75 f4                	jne    d620 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x2a0>
    d62c:	b8 20 00 00 00       	mov    $0x20,%eax
    d631:	48 8d 0d 1f 6d 00 00 	lea    0x6d1f(%rip),%rcx        # 14357 <_data+0x357>
    d638:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d63d:	0f 1f 00             	nopl   (%rax)
    d640:	48 83 c1 01          	add    $0x1,%rcx
    d644:	ee                   	out    %al,(%dx)
    d645:	0f b6 01             	movzbl (%rcx),%eax
    d648:	84 c0                	test   %al,%al
    d64a:	75 f4                	jne    d640 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x2c0>
    d64c:	41 89 e9             	mov    %ebp,%r9d
    d64f:	b9 1c 00 00 00       	mov    $0x1c,%ecx
    d654:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d659:	4c 8d 05 80 77 00 00 	lea    0x7780(%rip),%r8        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    d660:	44 89 c8             	mov    %r9d,%eax
    d663:	d3 e8                	shr    %cl,%eax
    d665:	83 e0 0f             	and    $0xf,%eax
    d668:	41 0f b6 04 00       	movzbl (%r8,%rax,1),%eax
    d66d:	ee                   	out    %al,(%dx)
    d66e:	83 e9 04             	sub    $0x4,%ecx
    d671:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    d674:	75 ea                	jne    d660 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x2e0>
    d676:	48 85 ed             	test   %rbp,%rbp
    d679:	0f 88 26 05 00 00    	js     dba5 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x825>
    d67f:	4c 8b 05 8a f6 00 00 	mov    0xf68a(%rip),%r8        # 1cd10 <_ZN10UEFIBridge10CR3Capture9instance_E>
    d686:	41 0f 20 dd          	mov    %cr3,%r13
    d68a:	b8 0d 00 00 00       	mov    $0xd,%eax
    d68f:	4d 89 68 20          	mov    %r13,0x20(%r8)
    d693:	ee                   	out    %al,(%dx)
    d694:	b8 0a 00 00 00       	mov    $0xa,%eax
    d699:	ee                   	out    %al,(%dx)
    d69a:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d69f:	48 8d 0d 5a 69 00 00 	lea    0x695a(%rip),%rcx        # 14000 <_data>
    d6a6:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d6ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    d6b0:	48 83 c1 01          	add    $0x1,%rcx
    d6b4:	ee                   	out    %al,(%dx)
    d6b5:	0f b6 01             	movzbl (%rcx),%eax
    d6b8:	84 c0                	test   %al,%al
    d6ba:	75 f4                	jne    d6b0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x330>
    d6bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d6c1:	ee                   	out    %al,(%dx)
    d6c2:	b8 45 00 00 00       	mov    $0x45,%eax
    d6c7:	48 8d 0d cb 6a 00 00 	lea    0x6acb(%rip),%rcx        # 14199 <_data+0x199>
    d6ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d6d3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d6da:	00 00 00 00 
    d6de:	66 90                	xchg   %ax,%ax
    d6e0:	48 83 c1 01          	add    $0x1,%rcx
    d6e4:	ee                   	out    %al,(%dx)
    d6e5:	0f b6 01             	movzbl (%rcx),%eax
    d6e8:	84 c0                	test   %al,%al
    d6ea:	75 f4                	jne    d6e0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x360>
    d6ec:	b8 5d 00 00 00       	mov    $0x5d,%eax
    d6f1:	ee                   	out    %al,(%dx)
    d6f2:	b8 20 00 00 00       	mov    $0x20,%eax
    d6f7:	ee                   	out    %al,(%dx)
    d6f8:	b8 6f 00 00 00       	mov    $0x6f,%eax
    d6fd:	48 8d 0d b5 6a 00 00 	lea    0x6ab5(%rip),%rcx        # 141b9 <_data+0x1b9>
    d704:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d709:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d710:	48 83 c1 01          	add    $0x1,%rcx
    d714:	ee                   	out    %al,(%dx)
    d715:	0f b6 01             	movzbl (%rcx),%eax
    d718:	84 c0                	test   %al,%al
    d71a:	75 f4                	jne    d710 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x390>
    d71c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    d721:	48 8d 0d 9e 69 00 00 	lea    0x699e(%rip),%rcx        # 140c6 <_data+0xc6>
    d728:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d72d:	0f 1f 00             	nopl   (%rax)
    d730:	48 83 c1 01          	add    $0x1,%rcx
    d734:	ee                   	out    %al,(%dx)
    d735:	0f b6 01             	movzbl (%rcx),%eax
    d738:	84 c0                	test   %al,%al
    d73a:	75 f4                	jne    d730 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x3b0>
    d73c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    d741:	4c 8d 15 b8 76 00 00 	lea    0x76b8(%rip),%r10        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    d748:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d74d:	0f 1f 00             	nopl   (%rax)
    d750:	4c 89 e8             	mov    %r13,%rax
    d753:	48 d3 e8             	shr    %cl,%rax
    d756:	83 e0 0f             	and    $0xf,%eax
    d759:	41 0f b6 04 02       	movzbl (%r10,%rax,1),%eax
    d75e:	ee                   	out    %al,(%dx)
    d75f:	83 e9 04             	sub    $0x4,%ecx
    d762:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    d765:	75 e9                	jne    d750 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x3d0>
    d767:	4c 8d 3d 6a 76 00 00 	lea    0x766a(%rip),%r15        # 14dd8 <_ZN10UEFIBridgeL25KUSD_OFS_BUILD_CANDIDATESE>
    d76e:	4d 8b 30             	mov    (%r8),%r14
    d771:	48 89 6c 24 38       	mov    %rbp,0x38(%rsp)
    d776:	c7 44 24 40 00 00 00 	movl   $0x0,0x40(%rsp)
    d77d:	00 
    d77e:	4c 89 7c 24 30       	mov    %r15,0x30(%rsp)
    d783:	4c 89 6c 24 28       	mov    %r13,0x28(%rsp)
    d788:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    d78d:	45 31 ed             	xor    %r13d,%r13d
    d790:	4d 89 f4             	mov    %r14,%r12
    d793:	8b 18                	mov    (%rax),%ebx
    d795:	48 b8 00 00 00 00 80 	movabs $0xfffff78000000000,%rax
    d79c:	f7 ff ff 
    d79f:	48 01 c3             	add    %rax,%rbx
    d7a2:	48 8d 44 24 40       	lea    0x40(%rsp),%rax
    d7a7:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
    d7ac:	0f 1f 40 00          	nopl   0x0(%rax)
    d7b0:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
    d7b5:	4e 8d 34 2b          	lea    (%rbx,%r13,1),%r14
    d7b9:	4c 89 e7             	mov    %r12,%rdi
    d7bc:	4c 89 f6             	mov    %r14,%rsi
    d7bf:	e8 2c f9 ff ff       	call   d0f0 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm>
    d7c4:	48 89 c6             	mov    %rax,%rsi
    d7c7:	48 85 c0             	test   %rax,%rax
    d7ca:	74 5d                	je     d829 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x4a9>
    d7cc:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
    d7d1:	41 80 7c 24 10 00    	cmpb   $0x0,0x10(%r12)
    d7d7:	4a 8d 3c 28          	lea    (%rax,%r13,1),%rdi
    d7db:	74 4c                	je     d829 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x4a9>
    d7dd:	48 b9 ff ff ff ff 0f 	movabs $0xfffffffff,%rcx
    d7e4:	00 00 00 
    d7e7:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    d7eb:	48 39 c1             	cmp    %rax,%rcx
    d7ee:	72 39                	jb     d829 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x4a9>
    d7f0:	4c 89 f2             	mov    %r14,%rdx
    d7f3:	b8 00 10 00 00       	mov    $0x1000,%eax
    d7f8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    d7fe:	48 29 d0             	sub    %rdx,%rax
    d801:	ba 04 00 00 00       	mov    $0x4,%edx
    d806:	4c 29 ea             	sub    %r13,%rdx
    d809:	48 39 d0             	cmp    %rdx,%rax
    d80c:	48 0f 46 d0          	cmovbe %rax,%rdx
    d810:	48 b8 00 00 00 00 10 	movabs $0x1000000000,%rax
    d817:	00 00 00 
    d81a:	48 29 d0             	sub    %rdx,%rax
    d81d:	49 89 d6             	mov    %rdx,%r14
    d820:	48 39 f0             	cmp    %rsi,%rax
    d823:	0f 83 df 01 00 00    	jae    da08 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x688>
    d829:	4d 89 e6             	mov    %r12,%r14
    d82c:	48 83 44 24 30 04    	addq   $0x4,0x30(%rsp)
    d832:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
    d837:	48 8d 1d a2 75 00 00 	lea    0x75a2(%rip),%rbx        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
    d83e:	48 39 d8             	cmp    %rbx,%rax
    d841:	0f 85 41 ff ff ff    	jne    d788 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x408>
    d847:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
    d84c:	45 31 c0             	xor    %r8d,%r8d
    d84f:	45 31 d2             	xor    %r10d,%r10d
    d852:	4c 8b 0d b7 f4 00 00 	mov    0xf4b7(%rip),%r9        # 1cd10 <_ZN10UEFIBridge10CR3Capture9instance_E>
    d859:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d85e:	b8 0d 00 00 00       	mov    $0xd,%eax
    d863:	45 89 51 28          	mov    %r10d,0x28(%r9)
    d867:	ee                   	out    %al,(%dx)
    d868:	b8 0a 00 00 00       	mov    $0xa,%eax
    d86d:	ee                   	out    %al,(%dx)
    d86e:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d873:	48 8d 0d 86 67 00 00 	lea    0x6786(%rip),%rcx        # 14000 <_data>
    d87a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    d880:	48 83 c1 01          	add    $0x1,%rcx
    d884:	ee                   	out    %al,(%dx)
    d885:	0f b6 01             	movzbl (%rcx),%eax
    d888:	84 c0                	test   %al,%al
    d88a:	75 f4                	jne    d880 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x500>
    d88c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    d891:	ee                   	out    %al,(%dx)
    d892:	b8 45 00 00 00       	mov    $0x45,%eax
    d897:	48 8d 0d fb 68 00 00 	lea    0x68fb(%rip),%rcx        # 14199 <_data+0x199>
    d89e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d8a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d8aa:	00 00 00 00 
    d8ae:	66 90                	xchg   %ax,%ax
    d8b0:	48 83 c1 01          	add    $0x1,%rcx
    d8b4:	ee                   	out    %al,(%dx)
    d8b5:	0f b6 01             	movzbl (%rcx),%eax
    d8b8:	84 c0                	test   %al,%al
    d8ba:	75 f4                	jne    d8b0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x530>
    d8bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    d8c1:	ee                   	out    %al,(%dx)
    d8c2:	b8 20 00 00 00       	mov    $0x20,%eax
    d8c7:	ee                   	out    %al,(%dx)
    d8c8:	b8 77 00 00 00       	mov    $0x77,%eax
    d8cd:	48 8d 0d 94 6e 00 00 	lea    0x6e94(%rip),%rcx        # 14768 <_data+0x768>
    d8d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d8d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    d8e0:	48 83 c1 01          	add    $0x1,%rcx
    d8e4:	ee                   	out    %al,(%dx)
    d8e5:	0f b6 01             	movzbl (%rcx),%eax
    d8e8:	84 c0                	test   %al,%al
    d8ea:	75 f4                	jne    d8e0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x560>
    d8ec:	b8 3d 00 00 00       	mov    $0x3d,%eax
    d8f1:	ee                   	out    %al,(%dx)
    d8f2:	45 85 d2             	test   %r10d,%r10d
    d8f5:	0f 84 69 01 00 00    	je     da64 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x6e4>
    d8fb:	c6 44 24 54 00       	movb   $0x0,0x54(%rsp)
    d900:	b9 13 00 00 00       	mov    $0x13,%ecx
    d905:	4c 8d 5c 24 40       	lea    0x40(%rsp),%r11
    d90a:	48 be cd cc cc cc cc 	movabs $0xcccccccccccccccd,%rsi
    d911:	cc cc cc 
    d914:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d91b:	00 00 00 00 
    d91f:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d926:	00 00 00 00 
    d92a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d931:	00 00 00 00 
    d935:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    d93c:	00 00 00 00 
    d940:	4c 89 c0             	mov    %r8,%rax
    d943:	48 89 cf             	mov    %rcx,%rdi
    d946:	48 f7 e6             	mul    %rsi
    d949:	4c 89 c0             	mov    %r8,%rax
    d94c:	48 c1 ea 03          	shr    $0x3,%rdx
    d950:	48 8d 1c 92          	lea    (%rdx,%rdx,4),%rbx
    d954:	48 01 db             	add    %rbx,%rbx
    d957:	48 29 d8             	sub    %rbx,%rax
    d95a:	4c 89 c3             	mov    %r8,%rbx
    d95d:	49 89 d0             	mov    %rdx,%r8
    d960:	83 c0 30             	add    $0x30,%eax
    d963:	48 83 fb 09          	cmp    $0x9,%rbx
    d967:	0f 97 c3             	seta   %bl
    d96a:	85 c9                	test   %ecx,%ecx
    d96c:	41 88 04 0b          	mov    %al,(%r11,%rcx,1)
    d970:	0f 95 c2             	setne  %dl
    d973:	48 83 e9 01          	sub    $0x1,%rcx
    d977:	84 d3                	test   %dl,%bl
    d979:	75 c5                	jne    d940 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x5c0>
    d97b:	48 63 ff             	movslq %edi,%rdi
    d97e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    d983:	49 01 fb             	add    %rdi,%r11
    d986:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    d98d:	00 00 00 
    d990:	49 83 c3 01          	add    $0x1,%r11
    d994:	ee                   	out    %al,(%dx)
    d995:	41 0f b6 03          	movzbl (%r11),%eax
    d999:	84 c0                	test   %al,%al
    d99b:	75 f3                	jne    d990 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x610>
    d99d:	49 8b 41 08          	mov    0x8(%r9),%rax
    d9a1:	49 8b 51 20          	mov    0x20(%r9),%rdx
    d9a5:	44 89 50 10          	mov    %r10d,0x10(%rax)
    d9a9:	48 89 50 08          	mov    %rdx,0x8(%rax)
    d9ad:	41 81 fa f0 55 00 00 	cmp    $0x55f0,%r10d
    d9b4:	0f 84 fe 02 00 00    	je     dcb8 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x938>
    d9ba:	0f 87 39 03 00 00    	ja     dcf9 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x979>
    d9c0:	41 81 fa 64 4a 00 00 	cmp    $0x4a64,%r10d
    d9c7:	0f 87 21 04 00 00    	ja     ddee <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa6e>
    d9cd:	41 81 fa 60 4a 00 00 	cmp    $0x4a60,%r10d
    d9d4:	0f 87 f8 03 00 00    	ja     ddd2 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa52>
    d9da:	41 81 fa 63 45 00 00 	cmp    $0x4563,%r10d
    d9e1:	0f 85 96 00 00 00    	jne    da7d <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x6fd>
    d9e7:	41 bb e8 02 00 00    	mov    $0x2e8,%r11d
    d9ed:	41 b9 f0 02 00 00    	mov    $0x2f0,%r9d
    d9f3:	41 b8 a8 05 00 00    	mov    $0x5a8,%r8d
    d9f9:	b9 d8 07 00 00       	mov    $0x7d8,%ecx
    d9fe:	e9 cc 02 00 00       	jmp    dccf <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x94f>
    da03:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    da08:	41 0f 20 df          	mov    %cr3,%r15
    da0c:	9c                   	pushf
    da0d:	5d                   	pop    %rbp
    da0e:	fa                   	cli
    da0f:	49 8b 14 24          	mov    (%r12),%rdx
    da13:	0f 22 da             	mov    %rdx,%cr3
    da16:	4c 89 f2             	mov    %r14,%rdx
    da19:	e8 62 93 ff ff       	call   6d80 <CopyMem>
    da1e:	41 0f 22 df          	mov    %r15,%cr3
    da22:	55                   	push   %rbp
    da23:	9d                   	popf
    da24:	4d 01 f5             	add    %r14,%r13
    da27:	49 83 fd 03          	cmp    $0x3,%r13
    da2b:	0f 86 7f fd ff ff    	jbe    d7b0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x430>
    da31:	44 8b 54 24 40       	mov    0x40(%rsp),%r10d
    da36:	4d 89 e6             	mov    %r12,%r14
    da39:	41 81 e2 ff ff ff 7f 	and    $0x7fffffff,%r10d
    da40:	41 8d 82 68 c5 ff ff 	lea    -0x3a98(%r10),%eax
    da47:	44 89 54 24 40       	mov    %r10d,0x40(%rsp)
    da4c:	3d 06 4c 01 00       	cmp    $0x14c06,%eax
    da51:	0f 87 d5 fd ff ff    	ja     d82c <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x4ac>
    da57:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
    da5c:	45 89 d0             	mov    %r10d,%r8d
    da5f:	e9 ee fd ff ff       	jmp    d852 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x4d2>
    da64:	b8 30 00 00 00       	mov    $0x30,%eax
    da69:	ee                   	out    %al,(%dx)
    da6a:	49 8b 41 08          	mov    0x8(%r9),%rax
    da6e:	49 8b 51 20          	mov    0x20(%r9),%rdx
    da72:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%rax)
    da79:	48 89 50 08          	mov    %rdx,0x8(%rax)
    da7d:	c6 40 14 00          	movb   $0x0,0x14(%rax)
    da81:	66 0f ef c0          	pxor   %xmm0,%xmm0
    da85:	0f 11 40 18          	movups %xmm0,0x18(%rax)
    da89:	0f 11 40 24          	movups %xmm0,0x24(%rax)
    da8d:	83 0d 18 f7 00 00 02 	orl    $0x2,0xf718(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
    da94:	48 89 15 05 f7 00 00 	mov    %rdx,0xf705(%rip)        # 1d1a0 <_ZN10UEFIBridge13g_diag_os_cr3E>
    da9b:	44 89 15 06 f7 00 00 	mov    %r10d,0xf706(%rip)        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    daa2:	c7 05 04 f7 00 00 02 	movl   $0x2,0xf704(%rip)        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
    daa9:	00 00 00 
    daac:	e8 4f ee ff ff       	call   c900 <_ZN10UEFIBridge9DiagWriteEv>
    dab1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dab6:	b8 0d 00 00 00       	mov    $0xd,%eax
    dabb:	ee                   	out    %al,(%dx)
    dabc:	b8 0a 00 00 00       	mov    $0xa,%eax
    dac1:	ee                   	out    %al,(%dx)
    dac2:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dac7:	48 8d 0d 32 65 00 00 	lea    0x6532(%rip),%rcx        # 14000 <_data>
    dace:	66 90                	xchg   %ax,%ax
    dad0:	48 83 c1 01          	add    $0x1,%rcx
    dad4:	ee                   	out    %al,(%dx)
    dad5:	0f b6 01             	movzbl (%rcx),%eax
    dad8:	84 c0                	test   %al,%al
    dada:	75 f4                	jne    dad0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x750>
    dadc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dae1:	ee                   	out    %al,(%dx)
    dae2:	b8 45 00 00 00       	mov    $0x45,%eax
    dae7:	48 8d 0d ab 66 00 00 	lea    0x66ab(%rip),%rcx        # 14199 <_data+0x199>
    daee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    daf3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    dafa:	00 00 00 00 
    dafe:	66 90                	xchg   %ax,%ax
    db00:	48 83 c1 01          	add    $0x1,%rcx
    db04:	ee                   	out    %al,(%dx)
    db05:	0f b6 01             	movzbl (%rcx),%eax
    db08:	84 c0                	test   %al,%al
    db0a:	75 f4                	jne    db00 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x780>
    db0c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    db11:	ee                   	out    %al,(%dx)
    db12:	b8 20 00 00 00       	mov    $0x20,%eax
    db17:	ee                   	out    %al,(%dx)
    db18:	b8 68 00 00 00       	mov    $0x68,%eax
    db1d:	48 8d 0d 84 6c 00 00 	lea    0x6c84(%rip),%rcx        # 147a8 <_data+0x7a8>
    db24:	ba f8 03 00 00       	mov    $0x3f8,%edx
    db29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    db30:	48 83 c1 01          	add    $0x1,%rcx
    db34:	ee                   	out    %al,(%dx)
    db35:	0f b6 01             	movzbl (%rcx),%eax
    db38:	84 c0                	test   %al,%al
    db3a:	75 f4                	jne    db30 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x7b0>
    db3c:	0f 28 74 24 60       	movaps 0x60(%rsp),%xmm6
    db41:	0f 28 7c 24 70       	movaps 0x70(%rsp),%xmm7
    db46:	48 89 e8             	mov    %rbp,%rax
    db49:	44 0f 28 84 24 80 00 	movaps 0x80(%rsp),%xmm8
    db50:	00 00 
    db52:	44 0f 28 8c 24 90 00 	movaps 0x90(%rsp),%xmm9
    db59:	00 00 
    db5b:	44 0f 28 94 24 a0 00 	movaps 0xa0(%rsp),%xmm10
    db62:	00 00 
    db64:	44 0f 28 9c 24 b0 00 	movaps 0xb0(%rsp),%xmm11
    db6b:	00 00 
    db6d:	44 0f 28 a4 24 c0 00 	movaps 0xc0(%rsp),%xmm12
    db74:	00 00 
    db76:	44 0f 28 ac 24 d0 00 	movaps 0xd0(%rsp),%xmm13
    db7d:	00 00 
    db7f:	44 0f 28 b4 24 e0 00 	movaps 0xe0(%rsp),%xmm14
    db86:	00 00 
    db88:	44 0f 28 bc 24 f0 00 	movaps 0xf0(%rsp),%xmm15
    db8f:	00 00 
    db91:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
    db98:	5b                   	pop    %rbx
    db99:	5e                   	pop    %rsi
    db9a:	5f                   	pop    %rdi
    db9b:	5d                   	pop    %rbp
    db9c:	41 5c                	pop    %r12
    db9e:	41 5d                	pop    %r13
    dba0:	41 5e                	pop    %r14
    dba2:	41 5f                	pop    %r15
    dba4:	c3                   	ret
    dba5:	b8 0d 00 00 00       	mov    $0xd,%eax
    dbaa:	ee                   	out    %al,(%dx)
    dbab:	b8 0a 00 00 00       	mov    $0xa,%eax
    dbb0:	ee                   	out    %al,(%dx)
    dbb1:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dbb6:	48 8d 0d 43 64 00 00 	lea    0x6443(%rip),%rcx        # 14000 <_data>
    dbbd:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dbc2:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    dbc9:	00 00 00 00 
    dbcd:	0f 1f 00             	nopl   (%rax)
    dbd0:	48 83 c1 01          	add    $0x1,%rcx
    dbd4:	ee                   	out    %al,(%dx)
    dbd5:	0f b6 01             	movzbl (%rcx),%eax
    dbd8:	84 c0                	test   %al,%al
    dbda:	75 f4                	jne    dbd0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x850>
    dbdc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dbe1:	ee                   	out    %al,(%dx)
    dbe2:	b8 45 00 00 00       	mov    $0x45,%eax
    dbe7:	48 8d 0d ab 65 00 00 	lea    0x65ab(%rip),%rcx        # 14199 <_data+0x199>
    dbee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dbf3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    dbfa:	00 00 00 00 
    dbfe:	66 90                	xchg   %ax,%ax
    dc00:	48 83 c1 01          	add    $0x1,%rcx
    dc04:	ee                   	out    %al,(%dx)
    dc05:	0f b6 01             	movzbl (%rcx),%eax
    dc08:	84 c0                	test   %al,%al
    dc0a:	75 f4                	jne    dc00 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x880>
    dc0c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    dc11:	ee                   	out    %al,(%dx)
    dc12:	b8 20 00 00 00       	mov    $0x20,%eax
    dc17:	ee                   	out    %al,(%dx)
    dc18:	b8 72 00 00 00       	mov    $0x72,%eax
    dc1d:	48 8d 0d 1c 6b 00 00 	lea    0x6b1c(%rip),%rcx        # 14740 <_data+0x740>
    dc24:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dc29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    dc30:	48 83 c1 01          	add    $0x1,%rcx
    dc34:	ee                   	out    %al,(%dx)
    dc35:	0f b6 01             	movzbl (%rcx),%eax
    dc38:	84 c0                	test   %al,%al
    dc3a:	75 f4                	jne    dc30 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x8b0>
    dc3c:	48 8b 0b             	mov    (%rbx),%rcx
    dc3f:	48 8d 05 3a f7 ff ff 	lea    -0x8c6(%rip),%rax        # d380 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm>
    dc46:	44 8b 49 0c          	mov    0xc(%rcx),%r9d
    dc4a:	48 89 81 e8 00 00 00 	mov    %rax,0xe8(%rcx)
    dc51:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%rcx)
    dc58:	4d 85 c9             	test   %r9,%r9
    dc5b:	0f 84 9f 01 00 00    	je     de00 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa80>
    dc61:	49 89 c8             	mov    %rcx,%r8
    dc64:	49 01 c9             	add    %rcx,%r9
    dc67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    dc6c:	0f 1f 40 00          	nopl   0x0(%rax)
    dc70:	41 0f b6 10          	movzbl (%r8),%edx
    dc74:	31 d0                	xor    %edx,%eax
    dc76:	ba 08 00 00 00       	mov    $0x8,%edx
    dc7b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    dc80:	41 89 c2             	mov    %eax,%r10d
    dc83:	83 e0 01             	and    $0x1,%eax
    dc86:	f7 d8                	neg    %eax
    dc88:	41 d1 ea             	shr    $1,%r10d
    dc8b:	25 20 83 b8 ed       	and    $0xedb88320,%eax
    dc90:	44 31 d0             	xor    %r10d,%eax
    dc93:	83 ea 01             	sub    $0x1,%edx
    dc96:	75 e8                	jne    dc80 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x900>
    dc98:	49 83 c0 01          	add    $0x1,%r8
    dc9c:	4d 39 c1             	cmp    %r8,%r9
    dc9f:	75 cf                	jne    dc70 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x8f0>
    dca1:	f7 d0                	not    %eax
    dca3:	89 41 10             	mov    %eax,0x10(%rcx)
    dca6:	e9 91 fe ff ff       	jmp    db3c <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x7bc>
    dcab:	41 81 fa 5d 58 00 00 	cmp    $0x585d,%r10d
    dcb2:	0f 85 c5 fd ff ff    	jne    da7d <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x6fd>
    dcb8:	41 bb 40 04 00 00    	mov    $0x440,%r11d
    dcbe:	41 b9 48 04 00 00    	mov    $0x448,%r9d
    dcc4:	41 b8 a8 05 00 00    	mov    $0x5a8,%r8d
    dcca:	b9 c8 07 00 00       	mov    $0x7c8,%ecx
    dccf:	44 89 40 20          	mov    %r8d,0x20(%rax)
    dcd3:	4c 8b 05 6e 71 00 00 	mov    0x716e(%rip),%r8        # 14e48 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x48>
    dcda:	44 89 58 18          	mov    %r11d,0x18(%rax)
    dcde:	44 89 48 1c          	mov    %r9d,0x1c(%rax)
    dce2:	4c 89 40 24          	mov    %r8,0x24(%rax)
    dce6:	89 48 2c             	mov    %ecx,0x2c(%rax)
    dce9:	c7 40 30 00 00 00 00 	movl   $0x0,0x30(%rax)
    dcf0:	c6 40 14 01          	movb   $0x1,0x14(%rax)
    dcf4:	e9 94 fd ff ff       	jmp    da8d <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x70d>
    dcf9:	41 81 fa 67 58 00 00 	cmp    $0x5867,%r10d
    dd00:	74 b6                	je     dcb8 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x938>
    dd02:	76 a7                	jbe    dcab <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x92b>
    dd04:	41 81 fa f4 65 00 00 	cmp    $0x65f4,%r10d
    dd0b:	74 0d                	je     dd1a <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x99a>
    dd0d:	41 81 fa 58 66 00 00 	cmp    $0x6658,%r10d
    dd14:	0f 85 63 fd ff ff    	jne    da7d <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x6fd>
    dd1a:	41 bb 50 04 00 00    	mov    $0x450,%r11d
    dd20:	41 b9 58 04 00 00    	mov    $0x458,%r9d
    dd26:	41 b8 b8 05 00 00    	mov    $0x5b8,%r8d
    dd2c:	b9 d8 07 00 00       	mov    $0x7d8,%ecx
    dd31:	eb 9c                	jmp    dccf <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x94f>
    dd33:	b8 0d 00 00 00       	mov    $0xd,%eax
    dd38:	ee                   	out    %al,(%dx)
    dd39:	b8 0a 00 00 00       	mov    $0xa,%eax
    dd3e:	ee                   	out    %al,(%dx)
    dd3f:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dd44:	48 8d 0d b5 62 00 00 	lea    0x62b5(%rip),%rcx        # 14000 <_data>
    dd4b:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dd50:	48 83 c1 01          	add    $0x1,%rcx
    dd54:	ee                   	out    %al,(%dx)
    dd55:	0f b6 01             	movzbl (%rcx),%eax
    dd58:	84 c0                	test   %al,%al
    dd5a:	75 f4                	jne    dd50 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x9d0>
    dd5c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    dd61:	ee                   	out    %al,(%dx)
    dd62:	b8 45 00 00 00       	mov    $0x45,%eax
    dd67:	48 8d 0d 2b 64 00 00 	lea    0x642b(%rip),%rcx        # 14199 <_data+0x199>
    dd6e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dd73:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    dd7a:	00 00 00 00 
    dd7e:	66 90                	xchg   %ax,%ax
    dd80:	48 83 c1 01          	add    $0x1,%rcx
    dd84:	ee                   	out    %al,(%dx)
    dd85:	0f b6 01             	movzbl (%rcx),%eax
    dd88:	84 c0                	test   %al,%al
    dd8a:	75 f4                	jne    dd80 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa00>
    dd8c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    dd91:	ee                   	out    %al,(%dx)
    dd92:	b8 20 00 00 00       	mov    $0x20,%eax
    dd97:	ee                   	out    %al,(%dx)
    dd98:	b8 69 00 00 00       	mov    $0x69,%eax
    dd9d:	48 8d 0d 2c 69 00 00 	lea    0x692c(%rip),%rcx        # 146d0 <_data+0x6d0>
    dda4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    dda9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ddb0:	48 83 c1 01          	add    $0x1,%rcx
    ddb4:	ee                   	out    %al,(%dx)
    ddb5:	0f b6 01             	movzbl (%rcx),%eax
    ddb8:	84 c0                	test   %al,%al
    ddba:	75 f4                	jne    ddb0 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0xa30>
    ddbc:	48 bd 0e 00 00 00 00 	movabs $0x800000000000000e,%rbp
    ddc3:	00 00 80 
    ddc6:	e9 71 fd ff ff       	jmp    db3c <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x7bc>
    ddcb:	31 c0                	xor    %eax,%eax
    ddcd:	e9 2e f7 ff ff       	jmp    d500 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x180>
    ddd2:	41 bb 40 04 00 00    	mov    $0x440,%r11d
    ddd8:	41 b9 48 04 00 00    	mov    $0x448,%r9d
    ddde:	41 b8 a8 05 00 00    	mov    $0x5a8,%r8d
    dde4:	b9 d8 07 00 00       	mov    $0x7d8,%ecx
    dde9:	e9 e1 fe ff ff       	jmp    dccf <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x94f>
    ddee:	41 81 fa 65 4a 00 00 	cmp    $0x4a65,%r10d
    ddf5:	0f 84 bd fe ff ff    	je     dcb8 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x938>
    ddfb:	e9 7d fc ff ff       	jmp    da7d <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x6fd>
    de00:	31 c0                	xor    %eax,%eax
    de02:	e9 9c fe ff ff       	jmp    dca3 <_ZN10UEFIBridge10CR3Capture22HookedExitBootServicesEPvm+0x923>
    de07:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    de0e:	00 00 

000000000000de10 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm>:
    de10:	41 57                	push   %r15
    de12:	41 56                	push   %r14
    de14:	41 55                	push   %r13
    de16:	41 54                	push   %r12
    de18:	55                   	push   %rbp
    de19:	53                   	push   %rbx
    de1a:	48 83 ec 48          	sub    $0x48,%rsp
    de1e:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
    de23:	48 89 54 24 18       	mov    %rdx,0x18(%rsp)
    de28:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
    de2d:	4d 85 c0             	test   %r8,%r8
    de30:	0f 84 92 03 00 00    	je     e1c8 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x3b8>
    de36:	48 b8 00 00 00 00 00 	movabs $0x800000000000,%rax
    de3d:	80 00 00 
    de40:	49 89 fe             	mov    %rdi,%r14
    de43:	4c 89 c3             	mov    %r8,%rbx
    de46:	48 21 f0             	and    %rsi,%rax
    de49:	49 89 c5             	mov    %rax,%r13
    de4c:	0f 85 16 02 00 00    	jne    e068 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x258>
    de52:	4c 8b 7c 24 10       	mov    0x10(%rsp),%r15
    de57:	4c 89 f8             	mov    %r15,%rax
    de5a:	48 c1 e8 30          	shr    $0x30,%rax
    de5e:	75 10                	jne    de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    de60:	66 f7 44 24 18 ff 0f 	testw  $0xfff,0x18(%rsp)
    de67:	0f 84 a5 01 00 00    	je     e012 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x202>
    de6d:	0f 1f 00             	nopl   (%rax)
    de70:	31 c0                	xor    %eax,%eax
    de72:	48 83 c4 48          	add    $0x48,%rsp
    de76:	5b                   	pop    %rbx
    de77:	5d                   	pop    %rbp
    de78:	41 5c                	pop    %r12
    de7a:	41 5d                	pop    %r13
    de7c:	41 5e                	pop    %r14
    de7e:	41 5f                	pop    %r15
    de80:	c3                   	ret
    de81:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    de88:	41 0f 20 d8          	mov    %cr3,%r8
    de8c:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    de91:	9c                   	pushf
    de92:	41 5c                	pop    %r12
    de94:	fa                   	cli
    de95:	49 8b 16             	mov    (%r14),%rdx
    de98:	0f 22 da             	mov    %rdx,%cr3
    de9b:	48 8d 6c 24 38       	lea    0x38(%rsp),%rbp
    dea0:	ba 08 00 00 00       	mov    $0x8,%edx
    dea5:	48 89 ef             	mov    %rbp,%rdi
    dea8:	e8 d3 8e ff ff       	call   6d80 <CopyMem>
    dead:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
    deb2:	41 0f 22 d8          	mov    %r8,%cr3
    deb6:	41 54                	push   %r12
    deb8:	9d                   	popf
    deb9:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    debe:	f6 c2 01             	test   $0x1,%dl
    dec1:	74 ad                	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    dec3:	48 c7 44 24 38 00 00 	movq   $0x0,0x38(%rsp)
    deca:	00 00 
    decc:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    ded1:	74 9d                	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    ded3:	48 b8 00 f0 ff ff ff 	movabs $0xffffffffff000,%rax
    deda:	ff 0f 00 
    dedd:	4c 89 fe             	mov    %r15,%rsi
    dee0:	48 c1 ee 1b          	shr    $0x1b,%rsi
    dee4:	48 21 c2             	and    %rax,%rdx
    dee7:	48 b8 f7 ff ff ff 0f 	movabs $0xffffffff7,%rax
    deee:	00 00 00 
    def1:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    def7:	48 01 d6             	add    %rdx,%rsi
    defa:	48 8d 56 ff          	lea    -0x1(%rsi),%rdx
    defe:	48 39 d0             	cmp    %rdx,%rax
    df01:	0f 82 69 ff ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    df07:	41 0f 20 d8          	mov    %cr3,%r8
    df0b:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    df10:	9c                   	pushf
    df11:	41 5c                	pop    %r12
    df13:	fa                   	cli
    df14:	49 8b 16             	mov    (%r14),%rdx
    df17:	0f 22 da             	mov    %rdx,%cr3
    df1a:	ba 08 00 00 00       	mov    $0x8,%edx
    df1f:	48 89 ef             	mov    %rbp,%rdi
    df22:	e8 59 8e ff ff       	call   6d80 <CopyMem>
    df27:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
    df2c:	41 0f 22 d8          	mov    %r8,%cr3
    df30:	41 54                	push   %r12
    df32:	9d                   	popf
    df33:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    df38:	f6 c2 01             	test   $0x1,%dl
    df3b:	0f 84 2f ff ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    df41:	48 b9 00 f0 ff ff ff 	movabs $0xffffffffff000,%rcx
    df48:	ff 0f 00 
    df4b:	48 21 d1             	and    %rdx,%rcx
    df4e:	81 e2 80 00 00 00    	and    $0x80,%edx
    df54:	0f 84 36 01 00 00    	je     e090 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x280>
    df5a:	4c 89 fe             	mov    %r15,%rsi
    df5d:	81 e6 ff ff ff 3f    	and    $0x3fffffff,%esi
    df63:	48 01 ce             	add    %rcx,%rsi
    df66:	48 85 f6             	test   %rsi,%rsi
    df69:	0f 84 01 ff ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    df6f:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    df74:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    df79:	4a 8d 3c 28          	lea    (%rax,%r13,1),%rdi
    df7d:	0f 84 ed fe ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    df83:	48 b8 ff ff ff ff 0f 	movabs $0xfffffffff,%rax
    df8a:	00 00 00 
    df8d:	48 8d 56 ff          	lea    -0x1(%rsi),%rdx
    df91:	48 39 d0             	cmp    %rdx,%rax
    df94:	0f 82 d6 fe ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    df9a:	41 81 e7 ff 0f 00 00 	and    $0xfff,%r15d
    dfa1:	bd 00 10 00 00       	mov    $0x1000,%ebp
    dfa6:	48 89 da             	mov    %rbx,%rdx
    dfa9:	4c 29 ea             	sub    %r13,%rdx
    dfac:	4c 29 fd             	sub    %r15,%rbp
    dfaf:	48 39 d5             	cmp    %rdx,%rbp
    dfb2:	48 0f 47 ea          	cmova  %rdx,%rbp
    dfb6:	48 ba 00 00 00 00 10 	movabs $0x1000000000,%rdx
    dfbd:	00 00 00 
    dfc0:	48 29 ea             	sub    %rbp,%rdx
    dfc3:	48 39 f2             	cmp    %rsi,%rdx
    dfc6:	0f 82 a4 fe ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    dfcc:	41 0f 20 dc          	mov    %cr3,%r12
    dfd0:	9c                   	pushf
    dfd1:	41 5f                	pop    %r15
    dfd3:	fa                   	cli
    dfd4:	49 8b 16             	mov    (%r14),%rdx
    dfd7:	0f 22 da             	mov    %rdx,%cr3
    dfda:	48 89 ea             	mov    %rbp,%rdx
    dfdd:	e8 9e 8d ff ff       	call   6d80 <CopyMem>
    dfe2:	41 0f 22 dc          	mov    %r12,%cr3
    dfe6:	41 57                	push   %r15
    dfe8:	9d                   	popf
    dfe9:	49 01 ed             	add    %rbp,%r13
    dfec:	49 39 dd             	cmp    %rbx,%r13
    dfef:	0f 83 d3 01 00 00    	jae    e1c8 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x3b8>
    dff5:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
    dffa:	4e 8d 3c 28          	lea    (%rax,%r13,1),%r15
    dffe:	49 0f ba e7 2f       	bt     $0x2f,%r15
    e003:	72 6b                	jb     e070 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x260>
    e005:	4c 89 f8             	mov    %r15,%rax
    e008:	48 c1 e8 30          	shr    $0x30,%rax
    e00c:	0f 85 5e fe ff ff    	jne    de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e012:	48 c7 44 24 38 00 00 	movq   $0x0,0x38(%rsp)
    e019:	00 00 
    e01b:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    e020:	0f 84 4a fe ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e026:	48 ba 00 f0 ff ff ff 	movabs $0xffffffffff000,%rdx
    e02d:	ff 0f 00 
    e030:	4c 89 fe             	mov    %r15,%rsi
    e033:	48 23 54 24 18       	and    0x18(%rsp),%rdx
    e038:	48 b8 f7 ff ff ff 0f 	movabs $0xffffffff7,%rax
    e03f:	00 00 00 
    e042:	48 c1 ee 24          	shr    $0x24,%rsi
    e046:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e04c:	48 01 d6             	add    %rdx,%rsi
    e04f:	48 8d 56 ff          	lea    -0x1(%rsi),%rdx
    e053:	48 39 d0             	cmp    %rdx,%rax
    e056:	0f 82 14 fe ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e05c:	e9 27 fe ff ff       	jmp    de88 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x78>
    e061:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    e068:	49 89 f7             	mov    %rsi,%r15
    e06b:	45 31 ed             	xor    %r13d,%r13d
    e06e:	66 90                	xchg   %ax,%ax
    e070:	48 be 00 00 00 00 00 	movabs $0xffff000000000000,%rsi
    e077:	00 ff ff 
    e07a:	4c 89 fa             	mov    %r15,%rdx
    e07d:	48 f7 d2             	not    %rdx
    e080:	48 85 f2             	test   %rsi,%rdx
    e083:	0f 84 d7 fd ff ff    	je     de60 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x50>
    e089:	e9 e2 fd ff ff       	jmp    de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e08e:	66 90                	xchg   %ax,%ax
    e090:	48 c7 44 24 38 00 00 	movq   $0x0,0x38(%rsp)
    e097:	00 00 
    e099:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    e09e:	0f 84 cc fd ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e0a4:	48 b8 f7 ff ff ff 0f 	movabs $0xffffffff7,%rax
    e0ab:	00 00 00 
    e0ae:	4c 89 fe             	mov    %r15,%rsi
    e0b1:	48 c1 ee 12          	shr    $0x12,%rsi
    e0b5:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e0bb:	48 01 ce             	add    %rcx,%rsi
    e0be:	48 8d 56 ff          	lea    -0x1(%rsi),%rdx
    e0c2:	48 39 d0             	cmp    %rdx,%rax
    e0c5:	0f 82 a5 fd ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e0cb:	41 0f 20 d8          	mov    %cr3,%r8
    e0cf:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    e0d4:	9c                   	pushf
    e0d5:	41 5c                	pop    %r12
    e0d7:	fa                   	cli
    e0d8:	49 8b 16             	mov    (%r14),%rdx
    e0db:	0f 22 da             	mov    %rdx,%cr3
    e0de:	ba 08 00 00 00       	mov    $0x8,%edx
    e0e3:	48 89 ef             	mov    %rbp,%rdi
    e0e6:	e8 95 8c ff ff       	call   6d80 <CopyMem>
    e0eb:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
    e0f0:	41 0f 22 d8          	mov    %r8,%cr3
    e0f4:	41 54                	push   %r12
    e0f6:	9d                   	popf
    e0f7:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
    e0fc:	f6 c2 01             	test   $0x1,%dl
    e0ff:	0f 84 6b fd ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e105:	49 bc 00 f0 ff ff ff 	movabs $0xffffffffff000,%r12
    e10c:	ff 0f 00 
    e10f:	48 89 d7             	mov    %rdx,%rdi
    e112:	4c 21 e7             	and    %r12,%rdi
    e115:	81 e2 80 00 00 00    	and    $0x80,%edx
    e11b:	74 11                	je     e12e <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x31e>
    e11d:	4c 89 fe             	mov    %r15,%rsi
    e120:	81 e6 ff ff 1f 00    	and    $0x1fffff,%esi
    e126:	48 01 fe             	add    %rdi,%rsi
    e129:	e9 38 fe ff ff       	jmp    df66 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x156>
    e12e:	48 c7 44 24 38 00 00 	movq   $0x0,0x38(%rsp)
    e135:	00 00 
    e137:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    e13c:	0f 84 2e fd ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e142:	4c 89 fe             	mov    %r15,%rsi
    e145:	48 c1 ee 09          	shr    $0x9,%rsi
    e149:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e14f:	48 01 fe             	add    %rdi,%rsi
    e152:	48 bf f7 ff ff ff 0f 	movabs $0xffffffff7,%rdi
    e159:	00 00 00 
    e15c:	48 8d 56 ff          	lea    -0x1(%rsi),%rdx
    e160:	48 39 d7             	cmp    %rdx,%rdi
    e163:	0f 82 07 fd ff ff    	jb     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e169:	41 0f 20 d9          	mov    %cr3,%r9
    e16d:	4c 89 4c 24 28       	mov    %r9,0x28(%rsp)
    e172:	9c                   	pushf
    e173:	41 58                	pop    %r8
    e175:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
    e17a:	fa                   	cli
    e17b:	49 8b 16             	mov    (%r14),%rdx
    e17e:	0f 22 da             	mov    %rdx,%cr3
    e181:	ba 08 00 00 00       	mov    $0x8,%edx
    e186:	48 89 ef             	mov    %rbp,%rdi
    e189:	e8 f2 8b ff ff       	call   6d80 <CopyMem>
    e18e:	4c 8b 4c 24 28       	mov    0x28(%rsp),%r9
    e193:	41 0f 22 d9          	mov    %r9,%cr3
    e197:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
    e19c:	41 50                	push   %r8
    e19e:	9d                   	popf
    e19f:	48 8b 74 24 38       	mov    0x38(%rsp),%rsi
    e1a4:	40 f6 c6 01          	test   $0x1,%sil
    e1a8:	0f 84 c2 fc ff ff    	je     de70 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x60>
    e1ae:	4c 89 fa             	mov    %r15,%rdx
    e1b1:	4c 21 e6             	and    %r12,%rsi
    e1b4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    e1ba:	48 09 d6             	or     %rdx,%rsi
    e1bd:	e9 a4 fd ff ff       	jmp    df66 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x156>
    e1c2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    e1c8:	b8 01 00 00 00       	mov    $0x1,%eax
    e1cd:	e9 a0 fc ff ff       	jmp    de72 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm+0x62>
    e1d2:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    e1d9:	00 00 00 
    e1dc:	0f 1f 40 00          	nopl   0x0(%rax)

000000000000e1e0 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE>:
    e1e0:	41 57                	push   %r15
    e1e2:	45 31 ff             	xor    %r15d,%r15d
    e1e5:	41 56                	push   %r14
    e1e7:	41 55                	push   %r13
    e1e9:	49 89 fd             	mov    %rdi,%r13
    e1ec:	41 54                	push   %r12
    e1ee:	55                   	push   %rbp
    e1ef:	53                   	push   %rbx
    e1f0:	48 89 f3             	mov    %rsi,%rbx
    e1f3:	48 81 ec 18 10 00 00 	sub    $0x1018,%rsp
    e1fa:	80 3e 00             	cmpb   $0x0,(%rsi)
    e1fd:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
    e202:	74 2d                	je     e231 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x51>
    e204:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    e20b:	00 00 00 00 
    e20f:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    e216:	00 00 00 00 
    e21a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    e220:	49 83 c7 01          	add    $0x1,%r15
    e224:	42 80 3c 3b 00       	cmpb   $0x0,(%rbx,%r15,1)
    e229:	74 06                	je     e231 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x51>
    e22b:	49 83 ff 0f          	cmp    $0xf,%r15
    e22f:	75 ef                	jne    e220 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x40>
    e231:	41 bc 00 00 01 00    	mov    $0x10000,%r12d
    e237:	48 8d 6c 24 10       	lea    0x10(%rsp),%rbp
    e23c:	49 8b 45 00          	mov    0x0(%r13),%rax
    e240:	80 78 10 00          	cmpb   $0x0,0x10(%rax)
    e244:	0f 84 06 01 00 00    	je     e350 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x170>
    e24a:	41 0f 20 d8          	mov    %cr3,%r8
    e24e:	4c 89 04 24          	mov    %r8,(%rsp)
    e252:	9c                   	pushf
    e253:	41 5e                	pop    %r14
    e255:	fa                   	cli
    e256:	48 8b 00             	mov    (%rax),%rax
    e259:	0f 22 d8             	mov    %rax,%cr3
    e25c:	ba 00 10 00 00       	mov    $0x1000,%edx
    e261:	4c 89 e6             	mov    %r12,%rsi
    e264:	48 89 ef             	mov    %rbp,%rdi
    e267:	e8 14 8b ff ff       	call   6d80 <CopyMem>
    e26c:	4c 8b 04 24          	mov    (%rsp),%r8
    e270:	41 0f 22 d8          	mov    %r8,%cr3
    e274:	41 56                	push   %r14
    e276:	9d                   	popf
    e277:	41 8b 7d 20          	mov    0x20(%r13),%edi
    e27b:	45 31 f6             	xor    %r14d,%r14d
    e27e:	48 8d 47 10          	lea    0x10(%rdi),%rax
    e282:	48 3d 00 10 00 00    	cmp    $0x1000,%rax
    e288:	76 21                	jbe    e2ab <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0xcb>
    e28a:	e9 c1 00 00 00       	jmp    e350 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x170>
    e28f:	90                   	nop
    e290:	41 8b 7d 20          	mov    0x20(%r13),%edi
    e294:	49 83 c6 10          	add    $0x10,%r14
    e298:	4c 01 f7             	add    %r14,%rdi
    e29b:	48 8d 47 10          	lea    0x10(%rdi),%rax
    e29f:	48 3d 00 10 00 00    	cmp    $0x1000,%rax
    e2a5:	0f 87 a5 00 00 00    	ja     e350 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x170>
    e2ab:	48 01 ef             	add    %rbp,%rdi
    e2ae:	4c 89 fa             	mov    %r15,%rdx
    e2b1:	48 89 de             	mov    %rbx,%rsi
    e2b4:	e8 d7 8a ff ff       	call   6d90 <CompareMem>
    e2b9:	48 85 c0             	test   %rax,%rax
    e2bc:	75 d2                	jne    e290 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0xb0>
    e2be:	41 8b 45 1c          	mov    0x1c(%r13),%eax
    e2c2:	49 8d 44 06 10       	lea    0x10(%r14,%rax,1),%rax
    e2c7:	48 3d 00 10 00 00    	cmp    $0x1000,%rax
    e2cd:	77 c1                	ja     e290 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0xb0>
    e2cf:	41 8b 55 18          	mov    0x18(%r13),%edx
    e2d3:	49 8d 86 10 10 00 00 	lea    0x1010(%r14),%rax
    e2da:	48 01 e0             	add    %rsp,%rax
    e2dd:	8b 94 02 00 f0 ff ff 	mov    -0x1000(%rdx,%rax,1),%edx
    e2e4:	8d 72 ff             	lea    -0x1(%rdx),%esi
    e2e7:	81 fe fe ff 0f 00    	cmp    $0xffffe,%esi
    e2ed:	77 a1                	ja     e290 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0xb0>
    e2ef:	41 8b 75 24          	mov    0x24(%r13),%esi
    e2f3:	48 8b 84 30 00 f0 ff 	mov    -0x1000(%rax,%rsi,1),%rax
    e2fa:	ff 
    e2fb:	a9 ff 0f 00 00       	test   $0xfff,%eax
    e300:	75 8e                	jne    e290 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0xb0>
    e302:	48 8b 5c 24 08       	mov    0x8(%rsp),%rbx
    e307:	4d 01 f4             	add    %r14,%r12
    e30a:	89 53 10             	mov    %edx,0x10(%rbx)
    e30d:	41 8b 75 20          	mov    0x20(%r13),%esi
    e311:	48 8d 7b 14          	lea    0x14(%rbx),%rdi
    e315:	ba 0f 00 00 00       	mov    $0xf,%edx
    e31a:	48 89 43 08          	mov    %rax,0x8(%rbx)
    e31e:	4c 89 23             	mov    %r12,(%rbx)
    e321:	4c 01 f6             	add    %r14,%rsi
    e324:	48 01 ee             	add    %rbp,%rsi
    e327:	e8 54 8a ff ff       	call   6d80 <CopyMem>
    e32c:	c6 43 23 00          	movb   $0x0,0x23(%rbx)
    e330:	b8 01 00 00 00       	mov    $0x1,%eax
    e335:	48 81 c4 18 10 00 00 	add    $0x1018,%rsp
    e33c:	5b                   	pop    %rbx
    e33d:	5d                   	pop    %rbp
    e33e:	41 5c                	pop    %r12
    e340:	41 5d                	pop    %r13
    e342:	41 5e                	pop    %r14
    e344:	41 5f                	pop    %r15
    e346:	c3                   	ret
    e347:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    e34e:	00 00 
    e350:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
    e357:	49 81 fc 00 00 00 10 	cmp    $0x10000000,%r12
    e35e:	0f 85 d8 fe ff ff    	jne    e23c <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x5c>
    e364:	31 c0                	xor    %eax,%eax
    e366:	eb cd                	jmp    e335 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE+0x155>
    e368:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    e36f:	00 

000000000000e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>:
    e370:	48 83 3f 00          	cmpq   $0x0,(%rdi)
    e374:	0f 84 5b 05 00 00    	je     e8d5 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x565>
    e37a:	41 57                	push   %r15
    e37c:	41 56                	push   %r14
    e37e:	41 55                	push   %r13
    e380:	41 54                	push   %r12
    e382:	55                   	push   %rbp
    e383:	53                   	push   %rbx
    e384:	48 89 d3             	mov    %rdx,%rbx
    e387:	48 83 ec 78          	sub    $0x78,%rsp
    e38b:	48 85 d2             	test   %rdx,%rdx
    e38e:	0f 84 ad 03 00 00    	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e394:	48 8b 57 08          	mov    0x8(%rdi),%rdx
    e398:	49 89 fc             	mov    %rdi,%r12
    e39b:	48 85 d2             	test   %rdx,%rdx
    e39e:	0f 84 9d 03 00 00    	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e3a4:	80 7f 14 00          	cmpb   $0x0,0x14(%rdi)
    e3a8:	48 89 f5             	mov    %rsi,%rbp
    e3ab:	0f 85 9d 00 00 00    	jne    e44e <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0xde>
    e3b1:	8b 05 f1 ed 00 00    	mov    0xedf1(%rip),%eax        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
    e3b7:	85 c0                	test   %eax,%eax
    e3b9:	0f 84 82 03 00 00    	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e3bf:	48 8b 0d da ed 00 00 	mov    0xedda(%rip),%rcx        # 1d1a0 <_ZN10UEFIBridge13g_diag_os_cr3E>
    e3c6:	89 47 10             	mov    %eax,0x10(%rdi)
    e3c9:	48 85 c9             	test   %rcx,%rcx
    e3cc:	48 0f 44 ca          	cmove  %rdx,%rcx
    e3d0:	48 89 4f 08          	mov    %rcx,0x8(%rdi)
    e3d4:	3d f0 55 00 00       	cmp    $0x55f0,%eax
    e3d9:	0f 84 04 05 00 00    	je     e8e3 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x573>
    e3df:	0f 87 17 05 00 00    	ja     e8fc <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x58c>
    e3e5:	3d 64 4a 00 00       	cmp    $0x4a64,%eax
    e3ea:	0f 87 e8 04 00 00    	ja     e8d8 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x568>
    e3f0:	3d 60 4a 00 00       	cmp    $0x4a60,%eax
    e3f5:	0f 87 39 05 00 00    	ja     e934 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x5c4>
    e3fb:	3d 63 45 00 00       	cmp    $0x4563,%eax
    e400:	0f 85 25 03 00 00    	jne    e72b <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3bb>
    e406:	be e8 02 00 00       	mov    $0x2e8,%esi
    e40b:	b9 f0 02 00 00       	mov    $0x2f0,%ecx
    e410:	ba a8 05 00 00       	mov    $0x5a8,%edx
    e415:	b8 d8 07 00 00       	mov    $0x7d8,%eax
    e41a:	41 89 54 24 20       	mov    %edx,0x20(%r12)
    e41f:	48 8b 15 22 6a 00 00 	mov    0x6a22(%rip),%rdx        # 14e48 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x48>
    e426:	41 89 74 24 18       	mov    %esi,0x18(%r12)
    e42b:	41 89 4c 24 1c       	mov    %ecx,0x1c(%r12)
    e430:	41 89 44 24 2c       	mov    %eax,0x2c(%r12)
    e435:	41 c7 44 24 30 00 00 	movl   $0x0,0x30(%r12)
    e43c:	00 00 
    e43e:	41 c6 44 24 14 01    	movb   $0x1,0x14(%r12)
    e444:	49 89 54 24 24       	mov    %rdx,0x24(%r12)
    e449:	49 8b 54 24 08       	mov    0x8(%r12),%rdx
    e44e:	66 0f ef c0          	pxor   %xmm0,%xmm0
    e452:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
    e457:	0f 01 4c 24 50       	sidt   0x50(%rsp)
    e45c:	49 8b 3c 24          	mov    (%r12),%rdi
    e460:	48 8b 74 24 58       	mov    0x58(%rsp),%rsi
    e465:	48 8d 4c 24 60       	lea    0x60(%rsp),%rcx
    e46a:	41 b8 10 00 00 00    	mov    $0x10,%r8d
    e470:	e8 9b f9 ff ff       	call   de10 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm>
    e475:	84 c0                	test   %al,%al
    e477:	0f 84 c4 02 00 00    	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e47d:	8b 4c 24 68          	mov    0x68(%rsp),%ecx
    e481:	0f b7 44 24 66       	movzwl 0x66(%rsp),%eax
    e486:	4c 89 64 24 20       	mov    %r12,0x20(%rsp)
    e48b:	48 89 6c 24 30       	mov    %rbp,0x30(%rsp)
    e490:	48 c1 e0 10          	shl    $0x10,%rax
    e494:	48 c1 e1 20          	shl    $0x20,%rcx
    e498:	48 89 5c 24 38       	mov    %rbx,0x38(%rsp)
    e49d:	48 09 c1             	or     %rax,%rcx
    e4a0:	0f b7 44 24 60       	movzwl 0x60(%rsp),%eax
    e4a5:	48 09 c1             	or     %rax,%rcx
    e4a8:	48 8d 81 00 00 00 ff 	lea    -0x1000000(%rcx),%rax
    e4af:	49 89 cd             	mov    %rcx,%r13
    e4b2:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    e4b7:	eb 1c                	jmp    e4d5 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x165>
    e4b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    e4c0:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    e4c5:	49 81 ed 00 10 00 00 	sub    $0x1000,%r13
    e4cc:	49 39 c5             	cmp    %rax,%r13
    e4cf:	0f 84 6c 02 00 00    	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e4d5:	48 bd 00 00 00 00 00 	movabs $0x800000000000,%rbp
    e4dc:	80 00 00 
    e4df:	31 c0                	xor    %eax,%eax
    e4e1:	66 89 44 24 46       	mov    %ax,0x46(%rsp)
    e4e6:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
    e4eb:	4c 8b 38             	mov    (%rax),%r15
    e4ee:	48 8b 40 08          	mov    0x8(%rax),%rax
    e4f2:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
    e4f7:	4c 21 ed             	and    %r13,%rbp
    e4fa:	0f 84 98 02 00 00    	je     e798 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x428>
    e500:	4d 89 ec             	mov    %r13,%r12
    e503:	31 ed                	xor    %ebp,%ebp
    e505:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    e50c:	00 00 00 00 
    e510:	48 be 00 00 00 00 00 	movabs $0xffff000000000000,%rsi
    e517:	00 ff ff 
    e51a:	4c 89 e2             	mov    %r12,%rdx
    e51d:	48 f7 d2             	not    %rdx
    e520:	48 85 f2             	test   %rsi,%rdx
    e523:	75 9b                	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e525:	66 f7 44 24 10 ff 0f 	testw  $0xfff,0x10(%rsp)
    e52c:	75 92                	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e52e:	48 b8 00 00 00 00 00 	movabs $0x800000000000,%rax
    e535:	80 00 00 
    e538:	4d 8d 75 01          	lea    0x1(%r13),%r14
    e53c:	4c 21 f0             	and    %r14,%rax
    e53f:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
    e544:	49 89 ee             	mov    %rbp,%r14
    e547:	4c 89 fd             	mov    %r15,%rbp
    e54a:	48 89 04 24          	mov    %rax,(%rsp)
    e54e:	eb 0a                	jmp    e55a <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x1ea>
    e550:	48 c1 e8 30          	shr    $0x30,%rax
    e554:	0f 85 66 ff ff ff    	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e55a:	48 c7 44 24 48 00 00 	movq   $0x0,0x48(%rsp)
    e561:	00 00 
    e563:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    e567:	0f 84 53 ff ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e56d:	48 b8 00 f0 ff ff ff 	movabs $0xffffffffff000,%rax
    e574:	ff 0f 00 
    e577:	4c 89 e6             	mov    %r12,%rsi
    e57a:	48 23 44 24 10       	and    0x10(%rsp),%rax
    e57f:	48 b9 f7 ff ff ff 0f 	movabs $0xffffffff7,%rcx
    e586:	00 00 00 
    e589:	48 c1 ee 24          	shr    $0x24,%rsi
    e58d:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e593:	48 01 c6             	add    %rax,%rsi
    e596:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    e59a:	48 39 c1             	cmp    %rax,%rcx
    e59d:	0f 82 1d ff ff ff    	jb     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e5a3:	41 0f 20 d9          	mov    %cr3,%r9
    e5a7:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
    e5ac:	9c                   	pushf
    e5ad:	5b                   	pop    %rbx
    e5ae:	fa                   	cli
    e5af:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    e5b3:	0f 22 da             	mov    %rdx,%cr3
    e5b6:	4c 8d 7c 24 48       	lea    0x48(%rsp),%r15
    e5bb:	ba 08 00 00 00       	mov    $0x8,%edx
    e5c0:	4c 89 ff             	mov    %r15,%rdi
    e5c3:	e8 b8 87 ff ff       	call   6d80 <CopyMem>
    e5c8:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    e5cd:	41 0f 22 d9          	mov    %r9,%cr3
    e5d1:	53                   	push   %rbx
    e5d2:	9d                   	popf
    e5d3:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    e5d8:	a8 01                	test   $0x1,%al
    e5da:	0f 84 e0 fe ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e5e0:	48 c7 44 24 48 00 00 	movq   $0x0,0x48(%rsp)
    e5e7:	00 00 
    e5e9:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    e5ed:	0f 84 cd fe ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e5f3:	48 b9 00 f0 ff ff ff 	movabs $0xffffffffff000,%rcx
    e5fa:	ff 0f 00 
    e5fd:	4c 89 e6             	mov    %r12,%rsi
    e600:	48 c1 ee 1b          	shr    $0x1b,%rsi
    e604:	48 21 c8             	and    %rcx,%rax
    e607:	48 b9 f7 ff ff ff 0f 	movabs $0xffffffff7,%rcx
    e60e:	00 00 00 
    e611:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e617:	48 01 c6             	add    %rax,%rsi
    e61a:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    e61e:	48 39 c1             	cmp    %rax,%rcx
    e621:	0f 82 99 fe ff ff    	jb     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e627:	41 0f 20 d9          	mov    %cr3,%r9
    e62b:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
    e630:	9c                   	pushf
    e631:	5b                   	pop    %rbx
    e632:	fa                   	cli
    e633:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    e637:	0f 22 da             	mov    %rdx,%cr3
    e63a:	ba 08 00 00 00       	mov    $0x8,%edx
    e63f:	4c 89 ff             	mov    %r15,%rdi
    e642:	e8 39 87 ff ff       	call   6d80 <CopyMem>
    e647:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    e64c:	41 0f 22 d9          	mov    %r9,%cr3
    e650:	53                   	push   %rbx
    e651:	9d                   	popf
    e652:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    e657:	a8 01                	test   $0x1,%al
    e659:	0f 84 61 fe ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e65f:	48 ba 00 f0 ff ff ff 	movabs $0xffffffffff000,%rdx
    e666:	ff 0f 00 
    e669:	48 21 c2             	and    %rax,%rdx
    e66c:	a8 80                	test   $0x80,%al
    e66e:	0f 84 3c 01 00 00    	je     e7b0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x440>
    e674:	4c 89 e6             	mov    %r12,%rsi
    e677:	81 e6 ff ff ff 3f    	and    $0x3fffffff,%esi
    e67d:	48 01 d6             	add    %rdx,%rsi
    e680:	48 85 f6             	test   %rsi,%rsi
    e683:	0f 84 37 fe ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e689:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    e68d:	4a 8d 7c 34 46       	lea    0x46(%rsp,%r14,1),%rdi
    e692:	0f 84 28 fe ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e698:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    e69c:	48 c1 e8 24          	shr    $0x24,%rax
    e6a0:	0f 85 1a fe ff ff    	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e6a6:	41 81 e4 ff 0f 00 00 	and    $0xfff,%r12d
    e6ad:	ba 00 10 00 00       	mov    $0x1000,%edx
    e6b2:	b8 02 00 00 00       	mov    $0x2,%eax
    e6b7:	4c 29 e2             	sub    %r12,%rdx
    e6ba:	4c 29 f0             	sub    %r14,%rax
    e6bd:	48 39 c2             	cmp    %rax,%rdx
    e6c0:	48 0f 46 c2          	cmovbe %rdx,%rax
    e6c4:	49 89 c4             	mov    %rax,%r12
    e6c7:	48 b8 00 00 00 00 10 	movabs $0x1000000000,%rax
    e6ce:	00 00 00 
    e6d1:	4c 29 e0             	sub    %r12,%rax
    e6d4:	48 39 f0             	cmp    %rsi,%rax
    e6d7:	0f 82 e3 fd ff ff    	jb     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e6dd:	0f 20 db             	mov    %cr3,%rbx
    e6e0:	9c                   	pushf
    e6e1:	41 5f                	pop    %r15
    e6e3:	fa                   	cli
    e6e4:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    e6e8:	0f 22 da             	mov    %rdx,%cr3
    e6eb:	4c 89 e2             	mov    %r12,%rdx
    e6ee:	e8 8d 86 ff ff       	call   6d80 <CopyMem>
    e6f3:	0f 22 db             	mov    %rbx,%cr3
    e6f6:	41 57                	push   %r15
    e6f8:	9d                   	popf
    e6f9:	4d 01 e6             	add    %r12,%r14
    e6fc:	49 83 fe 01          	cmp    $0x1,%r14
    e700:	75 56                	jne    e758 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3e8>
    e702:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    e707:	48 83 3c 24 00       	cmpq   $0x0,(%rsp)
    e70c:	49 89 c4             	mov    %rax,%r12
    e70f:	0f 84 3b fe ff ff    	je     e550 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x1e0>
    e715:	49 89 ef             	mov    %rbp,%r15
    e718:	4c 89 f5             	mov    %r14,%rbp
    e71b:	e9 f0 fd ff ff       	jmp    e510 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x1a0>
    e720:	3d 5d 58 00 00       	cmp    $0x585d,%eax
    e725:	0f 84 b8 01 00 00    	je     e8e3 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x573>
    e72b:	41 c6 44 24 14 00    	movb   $0x0,0x14(%r12)
    e731:	66 0f ef c0          	pxor   %xmm0,%xmm0
    e735:	41 0f 11 44 24 18    	movups %xmm0,0x18(%r12)
    e73b:	41 0f 11 44 24 24    	movups %xmm0,0x24(%r12)
    e741:	48 83 c4 78          	add    $0x78,%rsp
    e745:	31 c0                	xor    %eax,%eax
    e747:	5b                   	pop    %rbx
    e748:	5d                   	pop    %rbp
    e749:	41 5c                	pop    %r12
    e74b:	41 5d                	pop    %r13
    e74d:	41 5e                	pop    %r14
    e74f:	41 5f                	pop    %r15
    e751:	c3                   	ret
    e752:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    e758:	66 81 7c 24 46 4d 5a 	cmpw   $0x5a4d,0x46(%rsp)
    e75f:	0f 85 5b fd ff ff    	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e765:	4c 8b 64 24 20       	mov    0x20(%rsp),%r12
    e76a:	48 8b 6c 24 30       	mov    0x30(%rsp),%rbp
    e76f:	48 8b 5c 24 38       	mov    0x38(%rsp),%rbx
    e774:	4d 85 ed             	test   %r13,%r13
    e777:	74 c8                	je     e741 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3d1>
    e779:	48 83 c4 78          	add    $0x78,%rsp
    e77d:	48 89 da             	mov    %rbx,%rdx
    e780:	48 89 ee             	mov    %rbp,%rsi
    e783:	4c 89 e7             	mov    %r12,%rdi
    e786:	5b                   	pop    %rbx
    e787:	5d                   	pop    %rbp
    e788:	41 5c                	pop    %r12
    e78a:	41 5d                	pop    %r13
    e78c:	41 5e                	pop    %r14
    e78e:	41 5f                	pop    %r15
    e790:	e9 4b fa ff ff       	jmp    e1e0 <_ZN10UEFIBridge13ProcessFinder20ScanForProcessByNameEPKhPNS_11ProcessInfoE>
    e795:	0f 1f 00             	nopl   (%rax)
    e798:	4c 89 e8             	mov    %r13,%rax
    e79b:	48 c1 e8 30          	shr    $0x30,%rax
    e79f:	0f 85 1b fd ff ff    	jne    e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e7a5:	4d 89 ec             	mov    %r13,%r12
    e7a8:	e9 78 fd ff ff       	jmp    e525 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x1b5>
    e7ad:	0f 1f 00             	nopl   (%rax)
    e7b0:	48 c7 44 24 48 00 00 	movq   $0x0,0x48(%rsp)
    e7b7:	00 00 
    e7b9:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    e7bd:	0f 84 fd fc ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e7c3:	48 bb f7 ff ff ff 0f 	movabs $0xffffffff7,%rbx
    e7ca:	00 00 00 
    e7cd:	4c 89 e6             	mov    %r12,%rsi
    e7d0:	48 c1 ee 12          	shr    $0x12,%rsi
    e7d4:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e7da:	48 01 d6             	add    %rdx,%rsi
    e7dd:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    e7e1:	48 39 c3             	cmp    %rax,%rbx
    e7e4:	0f 82 d6 fc ff ff    	jb     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e7ea:	41 0f 20 d9          	mov    %cr3,%r9
    e7ee:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
    e7f3:	9c                   	pushf
    e7f4:	5b                   	pop    %rbx
    e7f5:	fa                   	cli
    e7f6:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    e7fa:	0f 22 da             	mov    %rdx,%cr3
    e7fd:	ba 08 00 00 00       	mov    $0x8,%edx
    e802:	4c 89 ff             	mov    %r15,%rdi
    e805:	e8 76 85 ff ff       	call   6d80 <CopyMem>
    e80a:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    e80f:	41 0f 22 d9          	mov    %r9,%cr3
    e813:	53                   	push   %rbx
    e814:	9d                   	popf
    e815:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    e81a:	a8 01                	test   $0x1,%al
    e81c:	0f 84 9e fc ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e822:	48 ba 00 f0 ff ff ff 	movabs $0xffffffffff000,%rdx
    e829:	ff 0f 00 
    e82c:	48 21 c2             	and    %rax,%rdx
    e82f:	a8 80                	test   $0x80,%al
    e831:	74 11                	je     e844 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x4d4>
    e833:	4c 89 e6             	mov    %r12,%rsi
    e836:	81 e6 ff ff 1f 00    	and    $0x1fffff,%esi
    e83c:	48 01 d6             	add    %rdx,%rsi
    e83f:	e9 3c fe ff ff       	jmp    e680 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x310>
    e844:	48 c7 44 24 48 00 00 	movq   $0x0,0x48(%rsp)
    e84b:	00 00 
    e84d:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    e851:	0f 84 69 fc ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e857:	48 bb f7 ff ff ff 0f 	movabs $0xffffffff7,%rbx
    e85e:	00 00 00 
    e861:	4c 89 e6             	mov    %r12,%rsi
    e864:	48 c1 ee 09          	shr    $0x9,%rsi
    e868:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
    e86e:	48 01 d6             	add    %rdx,%rsi
    e871:	48 8d 46 ff          	lea    -0x1(%rsi),%rax
    e875:	48 39 c3             	cmp    %rax,%rbx
    e878:	0f 82 42 fc ff ff    	jb     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e87e:	41 0f 20 d9          	mov    %cr3,%r9
    e882:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
    e887:	9c                   	pushf
    e888:	5b                   	pop    %rbx
    e889:	fa                   	cli
    e88a:	48 8b 55 00          	mov    0x0(%rbp),%rdx
    e88e:	0f 22 da             	mov    %rdx,%cr3
    e891:	ba 08 00 00 00       	mov    $0x8,%edx
    e896:	4c 89 ff             	mov    %r15,%rdi
    e899:	e8 e2 84 ff ff       	call   6d80 <CopyMem>
    e89e:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    e8a3:	41 0f 22 d9          	mov    %r9,%cr3
    e8a7:	53                   	push   %rbx
    e8a8:	9d                   	popf
    e8a9:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
    e8ae:	40 f6 c6 01          	test   $0x1,%sil
    e8b2:	0f 84 08 fc ff ff    	je     e4c0 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x150>
    e8b8:	48 b8 00 f0 ff ff ff 	movabs $0xffffffffff000,%rax
    e8bf:	ff 0f 00 
    e8c2:	48 21 c6             	and    %rax,%rsi
    e8c5:	4c 89 e0             	mov    %r12,%rax
    e8c8:	25 ff 0f 00 00       	and    $0xfff,%eax
    e8cd:	48 09 c6             	or     %rax,%rsi
    e8d0:	e9 ab fd ff ff       	jmp    e680 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x310>
    e8d5:	31 c0                	xor    %eax,%eax
    e8d7:	c3                   	ret
    e8d8:	3d 65 4a 00 00       	cmp    $0x4a65,%eax
    e8dd:	0f 85 48 fe ff ff    	jne    e72b <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3bb>
    e8e3:	be 40 04 00 00       	mov    $0x440,%esi
    e8e8:	b9 48 04 00 00       	mov    $0x448,%ecx
    e8ed:	ba a8 05 00 00       	mov    $0x5a8,%edx
    e8f2:	b8 c8 07 00 00       	mov    $0x7c8,%eax
    e8f7:	e9 1e fb ff ff       	jmp    e41a <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0xaa>
    e8fc:	3d 67 58 00 00       	cmp    $0x5867,%eax
    e901:	74 e0                	je     e8e3 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x573>
    e903:	0f 86 17 fe ff ff    	jbe    e720 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3b0>
    e909:	3d f4 65 00 00       	cmp    $0x65f4,%eax
    e90e:	74 0b                	je     e91b <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x5ab>
    e910:	3d 58 66 00 00       	cmp    $0x6658,%eax
    e915:	0f 85 10 fe ff ff    	jne    e72b <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0x3bb>
    e91b:	be 50 04 00 00       	mov    $0x450,%esi
    e920:	b9 58 04 00 00       	mov    $0x458,%ecx
    e925:	ba b8 05 00 00       	mov    $0x5b8,%edx
    e92a:	b8 d8 07 00 00       	mov    $0x7d8,%eax
    e92f:	e9 e6 fa ff ff       	jmp    e41a <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0xaa>
    e934:	be 40 04 00 00       	mov    $0x440,%esi
    e939:	b9 48 04 00 00       	mov    $0x448,%ecx
    e93e:	ba a8 05 00 00       	mov    $0x5a8,%edx
    e943:	b8 d8 07 00 00       	mov    $0x7d8,%eax
    e948:	e9 cd fa ff ff       	jmp    e41a <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE+0xaa>
    e94d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    e954:	00 00 00 
    e957:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    e95e:	00 00 

000000000000e960 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm>:
    e960:	41 57                	push   %r15
    e962:	41 56                	push   %r14
    e964:	41 55                	push   %r13
    e966:	41 54                	push   %r12
    e968:	55                   	push   %rbp
    e969:	53                   	push   %rbx
    e96a:	48 89 d3             	mov    %rdx,%rbx
    e96d:	48 83 ec 68          	sub    $0x68,%rsp
    e971:	48 85 d2             	test   %rdx,%rdx
    e974:	0f 94 c0             	sete   %al
    e977:	4d 85 c0             	test   %r8,%r8
    e97a:	0f 94 c2             	sete   %dl
    e97d:	08 d0                	or     %dl,%al
    e97f:	75 5f                	jne    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    e981:	48 89 f5             	mov    %rsi,%rbp
    e984:	48 85 f6             	test   %rsi,%rsi
    e987:	74 57                	je     e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    e989:	8b 06                	mov    (%rsi),%eax
    e98b:	44 8b 6e 0c          	mov    0xc(%rsi),%r13d
    e98f:	66 0f ef c0          	pxor   %xmm0,%xmm0
    e993:	4d 89 c6             	mov    %r8,%r14
    e996:	c7 43 04 02 00 00 00 	movl   $0x2,0x4(%rbx)
    e99d:	89 03                	mov    %eax,(%rbx)
    e99f:	0f 11 43 08          	movups %xmm0,0x8(%rbx)
    e9a3:	41 81 fd 00 10 00 00 	cmp    $0x1000,%r13d
    e9aa:	77 44                	ja     e9f0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x90>
    e9ac:	44 8b 4e 04          	mov    0x4(%rsi),%r9d
    e9b0:	49 89 ff             	mov    %rdi,%r15
    e9b3:	41 83 f9 07          	cmp    $0x7,%r9d
    e9b7:	0f 84 5b 01 00 00    	je     eb18 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1b8>
    e9bd:	49 89 cc             	mov    %rcx,%r12
    e9c0:	76 4e                	jbe    ea10 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xb0>
    e9c2:	41 83 f9 09          	cmp    $0x9,%r9d
    e9c6:	0f 84 24 02 00 00    	je     ebf0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x290>
    e9cc:	41 81 f9 ef be ad de 	cmp    $0xdeadbeef,%r9d
    e9d3:	0f 85 07 02 00 00    	jne    ebe0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x280>
    e9d9:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%rbx)
    e9e0:	48 83 c4 68          	add    $0x68,%rsp
    e9e4:	5b                   	pop    %rbx
    e9e5:	5d                   	pop    %rbp
    e9e6:	41 5c                	pop    %r12
    e9e8:	41 5d                	pop    %r13
    e9ea:	41 5e                	pop    %r14
    e9ec:	41 5f                	pop    %r15
    e9ee:	c3                   	ret
    e9ef:	90                   	nop
    e9f0:	c7 43 04 05 00 00 00 	movl   $0x5,0x4(%rbx)
    e9f7:	49 c7 00 00 00 00 00 	movq   $0x0,(%r8)
    e9fe:	48 83 c4 68          	add    $0x68,%rsp
    ea02:	5b                   	pop    %rbx
    ea03:	5d                   	pop    %rbp
    ea04:	41 5c                	pop    %r12
    ea06:	41 5d                	pop    %r13
    ea08:	41 5e                	pop    %r14
    ea0a:	41 5f                	pop    %r15
    ea0c:	c3                   	ret
    ea0d:	0f 1f 00             	nopl   (%rax)
    ea10:	41 83 f9 01          	cmp    $0x1,%r9d
    ea14:	0f 84 66 01 00 00    	je     eb80 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x220>
    ea1a:	41 83 f9 02          	cmp    $0x2,%r9d
    ea1e:	0f 85 bc 01 00 00    	jne    ebe0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x280>
    ea24:	48 8b 47 08          	mov    0x8(%rdi),%rax
    ea28:	48 8b 50 08          	mov    0x8(%rax),%rdx
    ea2c:	4c 8b 30             	mov    (%rax),%r14
    ea2f:	48 85 d2             	test   %rdx,%rdx
    ea32:	0f 84 c8 00 00 00    	je     eb00 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1a0>
    ea38:	4d 85 f6             	test   %r14,%r14
    ea3b:	0f 84 bf 00 00 00    	je     eb00 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1a0>
    ea41:	44 89 e9             	mov    %r13d,%ecx
    ea44:	48 85 c9             	test   %rcx,%rcx
    ea47:	0f 84 a7 0d 00 00    	je     f7f4 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xe94>
    ea4d:	48 8b 46 10          	mov    0x10(%rsi),%rax
    ea51:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
    ea56:	45 31 ff             	xor    %r15d,%r15d
    ea59:	48 89 cd             	mov    %rcx,%rbp
    ea5c:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    ea61:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    ea66:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
    ea6b:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
    ea70:	4d 89 fc             	mov    %r15,%r12
    ea73:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ea7a:	00 00 00 00 
    ea7e:	66 90                	xchg   %ax,%ax
    ea80:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    ea85:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
    ea8a:	4c 89 f7             	mov    %r14,%rdi
    ea8d:	4a 8d 1c 20          	lea    (%rax,%r12,1),%rbx
    ea91:	48 89 de             	mov    %rbx,%rsi
    ea94:	e8 57 e6 ff ff       	call   d0f0 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm>
    ea99:	48 89 c7             	mov    %rax,%rdi
    ea9c:	48 85 c0             	test   %rax,%rax
    ea9f:	74 5a                	je     eafb <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x19b>
    eaa1:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    eaa6:	41 80 7e 10 00       	cmpb   $0x0,0x10(%r14)
    eaab:	4e 8d 04 20          	lea    (%rax,%r12,1),%r8
    eaaf:	74 4a                	je     eafb <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x19b>
    eab1:	48 be ff ff ff ff 0f 	movabs $0xfffffffff,%rsi
    eab8:	00 00 00 
    eabb:	48 8d 47 ff          	lea    -0x1(%rdi),%rax
    eabf:	48 39 c6             	cmp    %rax,%rsi
    eac2:	72 37                	jb     eafb <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x19b>
    eac4:	48 89 de             	mov    %rbx,%rsi
    eac7:	b8 00 10 00 00       	mov    $0x1000,%eax
    eacc:	48 89 ea             	mov    %rbp,%rdx
    eacf:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
    ead5:	4c 29 e2             	sub    %r12,%rdx
    ead8:	48 29 f0             	sub    %rsi,%rax
    eadb:	48 39 d0             	cmp    %rdx,%rax
    eade:	48 0f 46 d0          	cmovbe %rax,%rdx
    eae2:	49 89 d5             	mov    %rdx,%r13
    eae5:	48 ba 00 00 00 00 10 	movabs $0x1000000000,%rdx
    eaec:	00 00 00 
    eaef:	4c 29 ea             	sub    %r13,%rdx
    eaf2:	48 39 fa             	cmp    %rdi,%rdx
    eaf5:	0f 83 c5 0c 00 00    	jae    f7c0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xe60>
    eafb:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
    eb00:	ba 04 00 00 00       	mov    $0x4,%edx
    eb05:	31 c0                	xor    %eax,%eax
    eb07:	89 53 04             	mov    %edx,0x4(%rbx)
    eb0a:	48 89 43 08          	mov    %rax,0x8(%rbx)
    eb0e:	e9 cd fe ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    eb13:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    eb18:	4c 8d 64 24 30       	lea    0x30(%rsp),%r12
    eb1d:	48 8b 7f 10          	mov    0x10(%rdi),%rdi
    eb21:	66 0f ef c0          	pxor   %xmm0,%xmm0
    eb25:	48 8d 35 1b 57 00 00 	lea    0x571b(%rip),%rsi        # 14247 <_data+0x247>
    eb2c:	4c 89 e2             	mov    %r12,%rdx
    eb2f:	0f 29 44 24 30       	movaps %xmm0,0x30(%rsp)
    eb34:	48 c7 44 24 50 00 00 	movq   $0x0,0x50(%rsp)
    eb3b:	00 00 
    eb3d:	0f 29 44 24 40       	movaps %xmm0,0x40(%rsp)
    eb42:	e8 29 f8 ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
    eb47:	84 c0                	test   %al,%al
    eb49:	0f 84 07 0c 00 00    	je     f756 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xdf6>
    eb4f:	8b 45 08             	mov    0x8(%rbp),%eax
    eb52:	49 8b 57 08          	mov    0x8(%r15),%rdx
    eb56:	85 c0                	test   %eax,%eax
    eb58:	0f 84 aa 01 00 00    	je     ed08 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x3a8>
    eb5e:	3b 44 24 40          	cmp    0x40(%rsp),%eax
    eb62:	0f 84 a0 01 00 00    	je     ed08 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x3a8>
    eb68:	c7 43 04 07 00 00 00 	movl   $0x7,0x4(%rbx)
    eb6f:	48 c7 42 08 00 00 00 	movq   $0x0,0x8(%rdx)
    eb76:	00 
    eb77:	e9 64 fe ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    eb7c:	0f 1f 40 00          	nopl   0x0(%rax)
    eb80:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%rbp)
    eb84:	48 8b 76 10          	mov    0x10(%rsi),%rsi
    eb88:	45 89 e8             	mov    %r13d,%r8d
    eb8b:	0f 84 cf 09 00 00    	je     f560 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xc00>
    eb91:	48 8b 47 08          	mov    0x8(%rdi),%rax
    eb95:	48 8b 50 08          	mov    0x8(%rax),%rdx
    eb99:	48 8b 38             	mov    (%rax),%rdi
    eb9c:	48 85 d2             	test   %rdx,%rdx
    eb9f:	0f 84 63 0c 00 00    	je     f808 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xea8>
    eba5:	48 85 ff             	test   %rdi,%rdi
    eba8:	0f 84 5a 0c 00 00    	je     f808 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xea8>
    ebae:	44 89 4c 24 08       	mov    %r9d,0x8(%rsp)
    ebb3:	e8 58 f2 ff ff       	call   de10 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm>
    ebb8:	44 8b 4c 24 08       	mov    0x8(%rsp),%r9d
    ebbd:	89 c7                	mov    %eax,%edi
    ebbf:	90                   	nop
    ebc0:	40 84 ff             	test   %dil,%dil
    ebc3:	0f 84 3f 0c 00 00    	je     f808 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xea8>
    ebc9:	8b 45 0c             	mov    0xc(%rbp),%eax
    ebcc:	48 89 43 08          	mov    %rax,0x8(%rbx)
    ebd0:	44 89 4b 04          	mov    %r9d,0x4(%rbx)
    ebd4:	49 89 06             	mov    %rax,(%r14)
    ebd7:	e9 04 fe ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    ebdc:	0f 1f 40 00          	nopl   0x0(%rax)
    ebe0:	c7 43 04 08 00 00 00 	movl   $0x8,0x4(%rbx)
    ebe7:	e9 f4 fd ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    ebec:	0f 1f 40 00          	nopl   0x0(%rax)
    ebf0:	8b 15 2a e1 00 00    	mov    0xe12a(%rip),%edx        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    ebf6:	85 d2                	test   %edx,%edx
    ebf8:	0f 84 2a 01 00 00    	je     ed28 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x3c8>
    ebfe:	66 0f ef c0          	pxor   %xmm0,%xmm0
    ec02:	41 0f 11 04 24       	movups %xmm0,(%r12)
    ec07:	8b 05 13 e1 00 00    	mov    0xe113(%rip),%eax        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    ec0d:	41 0f 11 44 24 10    	movups %xmm0,0x10(%r12)
    ec13:	41 89 04 24          	mov    %eax,(%r12)
    ec17:	8b 05 07 e1 00 00    	mov    0xe107(%rip),%eax        # 1cd24 <_ZN10UEFIBridge2ka8g_resultE+0x4>
    ec1d:	41 89 44 24 04       	mov    %eax,0x4(%r12)
    ec22:	48 8b 35 27 e1 00 00 	mov    0xe127(%rip),%rsi        # 1cd50 <_ZN10UEFIBridge2ka8g_resultE+0x30>
    ec29:	31 c0                	xor    %eax,%eax
    ec2b:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ec32:	00 00 00 00 
    ec36:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ec3d:	00 00 00 
    ec40:	8d 0c c5 00 00 00 00 	lea    0x0(,%rax,8),%ecx
    ec47:	48 89 f2             	mov    %rsi,%rdx
    ec4a:	48 d3 ea             	shr    %cl,%rdx
    ec4d:	41 88 54 04 08       	mov    %dl,0x8(%r12,%rax,1)
    ec52:	48 83 c0 01          	add    $0x1,%rax
    ec56:	48 83 f8 08          	cmp    $0x8,%rax
    ec5a:	75 e4                	jne    ec40 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x2e0>
    ec5c:	48 8b 35 f5 e0 00 00 	mov    0xe0f5(%rip),%rsi        # 1cd58 <_ZN10UEFIBridge2ka8g_resultE+0x38>
    ec63:	31 c0                	xor    %eax,%eax
    ec65:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ec6c:	00 00 00 00 
    ec70:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ec77:	00 00 00 00 
    ec7b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ec80:	8d 0c c5 00 00 00 00 	lea    0x0(,%rax,8),%ecx
    ec87:	48 89 f2             	mov    %rsi,%rdx
    ec8a:	48 d3 ea             	shr    %cl,%rdx
    ec8d:	41 88 54 04 10       	mov    %dl,0x10(%r12,%rax,1)
    ec92:	48 83 c0 01          	add    $0x1,%rax
    ec96:	48 83 f8 08          	cmp    $0x8,%rax
    ec9a:	75 e4                	jne    ec80 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x320>
    ec9c:	48 8b 35 85 e0 00 00 	mov    0xe085(%rip),%rsi        # 1cd28 <_ZN10UEFIBridge2ka8g_resultE+0x8>
    eca3:	31 c0                	xor    %eax,%eax
    eca5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ecac:	00 00 00 00 
    ecb0:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ecb7:	00 00 00 00 
    ecbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ecc0:	8d 0c c5 00 00 00 00 	lea    0x0(,%rax,8),%ecx
    ecc7:	48 89 f2             	mov    %rsi,%rdx
    ecca:	48 d3 ea             	shr    %cl,%rdx
    eccd:	41 88 54 04 18       	mov    %dl,0x18(%r12,%rax,1)
    ecd2:	48 83 c0 01          	add    $0x1,%rax
    ecd6:	48 83 f8 08          	cmp    $0x8,%rax
    ecda:	75 e4                	jne    ecc0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x360>
    ecdc:	31 c0                	xor    %eax,%eax
    ecde:	83 3d 3b e0 00 00 01 	cmpl   $0x1,0xe03b(%rip)        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    ece5:	48 c7 43 08 20 00 00 	movq   $0x20,0x8(%rbx)
    ecec:	00 
    eced:	0f 95 c0             	setne  %al
    ecf0:	8d 44 40 01          	lea    0x1(%rax,%rax,2),%eax
    ecf4:	89 43 04             	mov    %eax,0x4(%rbx)
    ecf7:	49 c7 06 20 00 00 00 	movq   $0x20,(%r14)
    ecfe:	e9 dd fc ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    ed03:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ed08:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    ed0d:	48 89 42 08          	mov    %rax,0x8(%rdx)
    ed11:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%rbx)
    ed18:	48 89 43 10          	mov    %rax,0x10(%rbx)
    ed1c:	e9 bf fc ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    ed21:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    ed28:	0f 01 4c 24 30       	sidt   0x30(%rsp)
    ed2d:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ed32:	48 8b 6c 24 32       	mov    0x32(%rsp),%rbp
    ed37:	b8 0d 00 00 00       	mov    $0xd,%eax
    ed3c:	ee                   	out    %al,(%dx)
    ed3d:	b8 0a 00 00 00       	mov    $0xa,%eax
    ed42:	ee                   	out    %al,(%dx)
    ed43:	b8 5b 00 00 00       	mov    $0x5b,%eax
    ed48:	48 8d 0d b1 52 00 00 	lea    0x52b1(%rip),%rcx        # 14000 <_data>
    ed4f:	90                   	nop
    ed50:	48 83 c1 01          	add    $0x1,%rcx
    ed54:	ee                   	out    %al,(%dx)
    ed55:	0f b6 01             	movzbl (%rcx),%eax
    ed58:	84 c0                	test   %al,%al
    ed5a:	75 f4                	jne    ed50 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x3f0>
    ed5c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    ed61:	ee                   	out    %al,(%dx)
    ed62:	b8 41 00 00 00       	mov    $0x41,%eax
    ed67:	48 8d 0d 53 54 00 00 	lea    0x5453(%rip),%rcx        # 141c1 <_data+0x1c1>
    ed6e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ed73:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ed7a:	00 00 00 00 
    ed7e:	66 90                	xchg   %ax,%ax
    ed80:	48 83 c1 01          	add    $0x1,%rcx
    ed84:	ee                   	out    %al,(%dx)
    ed85:	0f b6 01             	movzbl (%rcx),%eax
    ed88:	84 c0                	test   %al,%al
    ed8a:	75 f4                	jne    ed80 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x420>
    ed8c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    ed91:	ee                   	out    %al,(%dx)
    ed92:	b8 20 00 00 00       	mov    $0x20,%eax
    ed97:	ee                   	out    %al,(%dx)
    ed98:	b8 73 00 00 00       	mov    $0x73,%eax
    ed9d:	48 8d 0d 20 54 00 00 	lea    0x5420(%rip),%rcx        # 141c4 <_data+0x1c4>
    eda4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    eda9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    edb0:	48 83 c1 01          	add    $0x1,%rcx
    edb4:	ee                   	out    %al,(%dx)
    edb5:	0f b6 01             	movzbl (%rcx),%eax
    edb8:	84 c0                	test   %al,%al
    edba:	75 f4                	jne    edb0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x450>
    edbc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    edc1:	48 8d 0d fe 52 00 00 	lea    0x52fe(%rip),%rcx        # 140c6 <_data+0xc6>
    edc8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    edcd:	0f 1f 00             	nopl   (%rax)
    edd0:	48 83 c1 01          	add    $0x1,%rcx
    edd4:	ee                   	out    %al,(%dx)
    edd5:	0f b6 01             	movzbl (%rcx),%eax
    edd8:	84 c0                	test   %al,%al
    edda:	75 f4                	jne    edd0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x470>
    eddc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    ede1:	4c 8d 3d 18 60 00 00 	lea    0x6018(%rip),%r15        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    ede8:	bf f8 03 00 00       	mov    $0x3f8,%edi
    eded:	0f 1f 00             	nopl   (%rax)
    edf0:	48 89 e8             	mov    %rbp,%rax
    edf3:	89 fa                	mov    %edi,%edx
    edf5:	48 d3 e8             	shr    %cl,%rax
    edf8:	83 e0 0f             	and    $0xf,%eax
    edfb:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    ee00:	ee                   	out    %al,(%dx)
    ee01:	83 e9 04             	sub    $0x4,%ecx
    ee04:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    ee07:	75 e7                	jne    edf0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x490>
    ee09:	66 81 7c 24 30 fe 00 	cmpw   $0xfe,0x30(%rsp)
    ee10:	0f 86 09 0a 00 00    	jbe    f81f <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xebf>
    ee16:	8b b5 e0 00 00 00    	mov    0xe0(%rbp),%esi
    ee1c:	8b 85 e4 00 00 00    	mov    0xe4(%rbp),%eax
    ee22:	b9 82 00 00 c0       	mov    $0xc0000082,%ecx
    ee27:	8b 95 e8 00 00 00    	mov    0xe8(%rbp),%edx
    ee2d:	44 8b 6d 30          	mov    0x30(%rbp),%r13d
    ee31:	c1 e8 10             	shr    $0x10,%eax
    ee34:	0f b7 f6             	movzwl %si,%esi
    ee37:	48 c1 e2 20          	shl    $0x20,%rdx
    ee3b:	48 c1 e0 10          	shl    $0x10,%rax
    ee3f:	45 0f b7 ed          	movzwl %r13w,%r13d
    ee43:	48 09 d6             	or     %rdx,%rsi
    ee46:	48 09 c6             	or     %rax,%rsi
    ee49:	8b 45 34             	mov    0x34(%rbp),%eax
    ee4c:	8b 55 38             	mov    0x38(%rbp),%edx
    ee4f:	c1 e8 10             	shr    $0x10,%eax
    ee52:	48 c1 e2 20          	shl    $0x20,%rdx
    ee56:	49 09 d5             	or     %rdx,%r13
    ee59:	48 c1 e0 10          	shl    $0x10,%rax
    ee5d:	49 09 c5             	or     %rax,%r13
    ee60:	0f 32                	rdmsr
    ee62:	48 c1 e2 20          	shl    $0x20,%rdx
    ee66:	89 c0                	mov    %eax,%eax
    ee68:	48 09 c2             	or     %rax,%rdx
    ee6b:	b8 0d 00 00 00       	mov    $0xd,%eax
    ee70:	49 89 d0             	mov    %rdx,%r8
    ee73:	89 fa                	mov    %edi,%edx
    ee75:	ee                   	out    %al,(%dx)
    ee76:	b8 0a 00 00 00       	mov    $0xa,%eax
    ee7b:	ee                   	out    %al,(%dx)
    ee7c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    ee81:	48 8d 0d 78 51 00 00 	lea    0x5178(%rip),%rcx        # 14000 <_data>
    ee88:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ee8d:	0f 1f 00             	nopl   (%rax)
    ee90:	48 83 c1 01          	add    $0x1,%rcx
    ee94:	ee                   	out    %al,(%dx)
    ee95:	0f b6 01             	movzbl (%rcx),%eax
    ee98:	84 c0                	test   %al,%al
    ee9a:	75 f4                	jne    ee90 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x530>
    ee9c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    eea1:	ee                   	out    %al,(%dx)
    eea2:	b8 41 00 00 00       	mov    $0x41,%eax
    eea7:	48 8d 0d 13 53 00 00 	lea    0x5313(%rip),%rcx        # 141c1 <_data+0x1c1>
    eeae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    eeb3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    eeba:	00 00 00 00 
    eebe:	66 90                	xchg   %ax,%ax
    eec0:	48 83 c1 01          	add    $0x1,%rcx
    eec4:	ee                   	out    %al,(%dx)
    eec5:	0f b6 01             	movzbl (%rcx),%eax
    eec8:	84 c0                	test   %al,%al
    eeca:	75 f4                	jne    eec0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x560>
    eecc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    eed1:	ee                   	out    %al,(%dx)
    eed2:	b8 20 00 00 00       	mov    $0x20,%eax
    eed7:	ee                   	out    %al,(%dx)
    eed8:	b8 69 00 00 00       	mov    $0x69,%eax
    eedd:	48 8d 0d fd 52 00 00 	lea    0x52fd(%rip),%rcx        # 141e1 <_data+0x1e1>
    eee4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    eee9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    eef0:	48 83 c1 01          	add    $0x1,%rcx
    eef4:	ee                   	out    %al,(%dx)
    eef5:	0f b6 01             	movzbl (%rcx),%eax
    eef8:	84 c0                	test   %al,%al
    eefa:	75 f4                	jne    eef0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x590>
    eefc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    ef01:	48 8d 0d be 51 00 00 	lea    0x51be(%rip),%rcx        # 140c6 <_data+0xc6>
    ef08:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ef0d:	0f 1f 00             	nopl   (%rax)
    ef10:	48 83 c1 01          	add    $0x1,%rcx
    ef14:	ee                   	out    %al,(%dx)
    ef15:	0f b6 01             	movzbl (%rcx),%eax
    ef18:	84 c0                	test   %al,%al
    ef1a:	75 f4                	jne    ef10 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x5b0>
    ef1c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    ef21:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ef26:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    ef2d:	00 00 00 
    ef30:	48 89 f0             	mov    %rsi,%rax
    ef33:	48 d3 e8             	shr    %cl,%rax
    ef36:	83 e0 0f             	and    $0xf,%eax
    ef39:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    ef3e:	ee                   	out    %al,(%dx)
    ef3f:	83 e9 04             	sub    $0x4,%ecx
    ef42:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    ef45:	75 e9                	jne    ef30 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x5d0>
    ef47:	b8 0d 00 00 00       	mov    $0xd,%eax
    ef4c:	ee                   	out    %al,(%dx)
    ef4d:	b8 0a 00 00 00       	mov    $0xa,%eax
    ef52:	ee                   	out    %al,(%dx)
    ef53:	b8 5b 00 00 00       	mov    $0x5b,%eax
    ef58:	48 8d 0d a1 50 00 00 	lea    0x50a1(%rip),%rcx        # 14000 <_data>
    ef5f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ef64:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ef6b:	00 00 00 00 
    ef6f:	90                   	nop
    ef70:	48 83 c1 01          	add    $0x1,%rcx
    ef74:	ee                   	out    %al,(%dx)
    ef75:	0f b6 01             	movzbl (%rcx),%eax
    ef78:	84 c0                	test   %al,%al
    ef7a:	75 f4                	jne    ef70 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x610>
    ef7c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    ef81:	ee                   	out    %al,(%dx)
    ef82:	b8 41 00 00 00       	mov    $0x41,%eax
    ef87:	48 8d 0d 33 52 00 00 	lea    0x5233(%rip),%rcx        # 141c1 <_data+0x1c1>
    ef8e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    ef93:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    ef9a:	00 00 00 00 
    ef9e:	66 90                	xchg   %ax,%ax
    efa0:	48 83 c1 01          	add    $0x1,%rcx
    efa4:	ee                   	out    %al,(%dx)
    efa5:	0f b6 01             	movzbl (%rcx),%eax
    efa8:	84 c0                	test   %al,%al
    efaa:	75 f4                	jne    efa0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x640>
    efac:	b8 5d 00 00 00       	mov    $0x5d,%eax
    efb1:	ee                   	out    %al,(%dx)
    efb2:	b8 20 00 00 00       	mov    $0x20,%eax
    efb7:	ee                   	out    %al,(%dx)
    efb8:	b8 69 00 00 00       	mov    $0x69,%eax
    efbd:	48 8d 0d 24 52 00 00 	lea    0x5224(%rip),%rcx        # 141e8 <_data+0x1e8>
    efc4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    efc9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    efd0:	48 83 c1 01          	add    $0x1,%rcx
    efd4:	ee                   	out    %al,(%dx)
    efd5:	0f b6 01             	movzbl (%rcx),%eax
    efd8:	84 c0                	test   %al,%al
    efda:	75 f4                	jne    efd0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x670>
    efdc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    efe1:	48 8d 0d de 50 00 00 	lea    0x50de(%rip),%rcx        # 140c6 <_data+0xc6>
    efe8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    efed:	0f 1f 00             	nopl   (%rax)
    eff0:	48 83 c1 01          	add    $0x1,%rcx
    eff4:	ee                   	out    %al,(%dx)
    eff5:	0f b6 01             	movzbl (%rcx),%eax
    eff8:	84 c0                	test   %al,%al
    effa:	75 f4                	jne    eff0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x690>
    effc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f001:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f006:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f00d:	00 00 00 
    f010:	4c 89 e8             	mov    %r13,%rax
    f013:	48 d3 e8             	shr    %cl,%rax
    f016:	83 e0 0f             	and    $0xf,%eax
    f019:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f01e:	ee                   	out    %al,(%dx)
    f01f:	83 e9 04             	sub    $0x4,%ecx
    f022:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f025:	75 e9                	jne    f010 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x6b0>
    f027:	b8 0d 00 00 00       	mov    $0xd,%eax
    f02c:	ee                   	out    %al,(%dx)
    f02d:	b8 0a 00 00 00       	mov    $0xa,%eax
    f032:	ee                   	out    %al,(%dx)
    f033:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f038:	48 8d 0d c1 4f 00 00 	lea    0x4fc1(%rip),%rcx        # 14000 <_data>
    f03f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f044:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f04b:	00 00 00 00 
    f04f:	90                   	nop
    f050:	48 83 c1 01          	add    $0x1,%rcx
    f054:	ee                   	out    %al,(%dx)
    f055:	0f b6 01             	movzbl (%rcx),%eax
    f058:	84 c0                	test   %al,%al
    f05a:	75 f4                	jne    f050 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x6f0>
    f05c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f061:	ee                   	out    %al,(%dx)
    f062:	b8 41 00 00 00       	mov    $0x41,%eax
    f067:	48 8d 0d 53 51 00 00 	lea    0x5153(%rip),%rcx        # 141c1 <_data+0x1c1>
    f06e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f073:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f07a:	00 00 00 00 
    f07e:	66 90                	xchg   %ax,%ax
    f080:	48 83 c1 01          	add    $0x1,%rcx
    f084:	ee                   	out    %al,(%dx)
    f085:	0f b6 01             	movzbl (%rcx),%eax
    f088:	84 c0                	test   %al,%al
    f08a:	75 f4                	jne    f080 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x720>
    f08c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f091:	ee                   	out    %al,(%dx)
    f092:	b8 20 00 00 00       	mov    $0x20,%eax
    f097:	ee                   	out    %al,(%dx)
    f098:	b8 6c 00 00 00       	mov    $0x6c,%eax
    f09d:	48 8d 0d 4b 51 00 00 	lea    0x514b(%rip),%rcx        # 141ef <_data+0x1ef>
    f0a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f0a9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f0b0:	48 83 c1 01          	add    $0x1,%rcx
    f0b4:	ee                   	out    %al,(%dx)
    f0b5:	0f b6 01             	movzbl (%rcx),%eax
    f0b8:	84 c0                	test   %al,%al
    f0ba:	75 f4                	jne    f0b0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x750>
    f0bc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f0c1:	48 8d 0d fe 4f 00 00 	lea    0x4ffe(%rip),%rcx        # 140c6 <_data+0xc6>
    f0c8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f0cd:	0f 1f 00             	nopl   (%rax)
    f0d0:	48 83 c1 01          	add    $0x1,%rcx
    f0d4:	ee                   	out    %al,(%dx)
    f0d5:	0f b6 01             	movzbl (%rcx),%eax
    f0d8:	84 c0                	test   %al,%al
    f0da:	75 f4                	jne    f0d0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x770>
    f0dc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f0e1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f0e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f0ed:	00 00 00 
    f0f0:	4c 89 c0             	mov    %r8,%rax
    f0f3:	48 d3 e8             	shr    %cl,%rax
    f0f6:	83 e0 0f             	and    $0xf,%eax
    f0f9:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f0fe:	ee                   	out    %al,(%dx)
    f0ff:	83 e9 04             	sub    $0x4,%ecx
    f102:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f105:	75 e9                	jne    f0f0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x790>
    f107:	48 b8 ff ff ff ff ff 	movabs $0xffff7fffffffffff,%rax
    f10e:	7f ff ff 
    f111:	48 39 e8             	cmp    %rbp,%rax
    f114:	0f 83 d9 09 00 00    	jae    faf3 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1193>
    f11a:	48 39 f0             	cmp    %rsi,%rax
    f11d:	0f 93 c2             	setae  %dl
    f120:	4c 39 e8             	cmp    %r13,%rax
    f123:	0f 93 c1             	setae  %cl
    f126:	08 ca                	or     %cl,%dl
    f128:	0f 85 e6 07 00 00    	jne    f914 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xfb4>
    f12e:	4c 39 c0             	cmp    %r8,%rax
    f131:	0f 83 dd 07 00 00    	jae    f914 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xfb4>
    f137:	48 89 f7             	mov    %rsi,%rdi
    f13a:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
    f13f:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
    f144:	e8 77 d6 ff ff       	call   c7c0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm>
    f149:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
    f14e:	48 85 c0             	test   %rax,%rax
    f151:	49 89 c1             	mov    %rax,%r9
    f154:	0f 84 ea 09 00 00    	je     fb44 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11e4>
    f15a:	4c 89 ef             	mov    %r13,%rdi
    f15d:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
    f162:	e8 59 d6 ff ff       	call   c7c0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm>
    f167:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
    f16c:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
    f171:	48 85 c0             	test   %rax,%rax
    f174:	49 89 c2             	mov    %rax,%r10
    f177:	0f 84 03 0a 00 00    	je     fb80 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1220>
    f17d:	4c 89 c7             	mov    %r8,%rdi
    f180:	4c 89 4c 24 20       	mov    %r9,0x20(%rsp)
    f185:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
    f18a:	e8 31 d6 ff ff       	call   c7c0 <_ZN10UEFIBridge2kaL12WalkBackToPEEm>
    f18f:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
    f194:	4c 8b 54 24 18       	mov    0x18(%rsp),%r10
    f199:	48 85 c0             	test   %rax,%rax
    f19c:	4c 8b 4c 24 20       	mov    0x20(%rsp),%r9
    f1a1:	48 89 c7             	mov    %rax,%rdi
    f1a4:	0f 84 e5 09 00 00    	je     fb8f <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x122f>
    f1aa:	4d 39 d1             	cmp    %r10,%r9
    f1ad:	75 0e                	jne    f1bd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x85d>
    f1af:	49 39 c2             	cmp    %rax,%r10
    f1b2:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
    f1b7:	0f 84 df 09 00 00    	je     fb9c <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x123c>
    f1bd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%rsp)
    f1c4:	00 
    f1c5:	45 31 db             	xor    %r11d,%r11d
    f1c8:	31 f6                	xor    %esi,%esi
    f1ca:	41 bd 02 00 00 00    	mov    $0x2,%r13d
    f1d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f1d5:	b8 0d 00 00 00       	mov    $0xd,%eax
    f1da:	ee                   	out    %al,(%dx)
    f1db:	b8 0a 00 00 00       	mov    $0xa,%eax
    f1e0:	ee                   	out    %al,(%dx)
    f1e1:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f1e6:	48 8d 0d 13 4e 00 00 	lea    0x4e13(%rip),%rcx        # 14000 <_data>
    f1ed:	0f 1f 00             	nopl   (%rax)
    f1f0:	48 83 c1 01          	add    $0x1,%rcx
    f1f4:	ee                   	out    %al,(%dx)
    f1f5:	0f b6 01             	movzbl (%rcx),%eax
    f1f8:	84 c0                	test   %al,%al
    f1fa:	75 f4                	jne    f1f0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x890>
    f1fc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f201:	ee                   	out    %al,(%dx)
    f202:	b8 41 00 00 00       	mov    $0x41,%eax
    f207:	48 8d 0d b3 4f 00 00 	lea    0x4fb3(%rip),%rcx        # 141c1 <_data+0x1c1>
    f20e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f213:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f21a:	00 00 00 00 
    f21e:	66 90                	xchg   %ax,%ax
    f220:	48 83 c1 01          	add    $0x1,%rcx
    f224:	ee                   	out    %al,(%dx)
    f225:	0f b6 01             	movzbl (%rcx),%eax
    f228:	84 c0                	test   %al,%al
    f22a:	75 f4                	jne    f220 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x8c0>
    f22c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f231:	ee                   	out    %al,(%dx)
    f232:	b8 20 00 00 00       	mov    $0x20,%eax
    f237:	ee                   	out    %al,(%dx)
    f238:	b8 77 00 00 00       	mov    $0x77,%eax
    f23d:	48 8d 0d b1 4f 00 00 	lea    0x4fb1(%rip),%rcx        # 141f5 <_data+0x1f5>
    f244:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f249:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f250:	48 83 c1 01          	add    $0x1,%rcx
    f254:	ee                   	out    %al,(%dx)
    f255:	0f b6 01             	movzbl (%rcx),%eax
    f258:	84 c0                	test   %al,%al
    f25a:	75 f4                	jne    f250 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x8f0>
    f25c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f261:	48 8d 0d 5e 4e 00 00 	lea    0x4e5e(%rip),%rcx        # 140c6 <_data+0xc6>
    f268:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f26d:	0f 1f 00             	nopl   (%rax)
    f270:	48 83 c1 01          	add    $0x1,%rcx
    f274:	ee                   	out    %al,(%dx)
    f275:	0f b6 01             	movzbl (%rcx),%eax
    f278:	84 c0                	test   %al,%al
    f27a:	75 f4                	jne    f270 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x910>
    f27c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f281:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f286:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f28d:	00 00 00 
    f290:	4c 89 c8             	mov    %r9,%rax
    f293:	48 d3 e8             	shr    %cl,%rax
    f296:	83 e0 0f             	and    $0xf,%eax
    f299:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f29e:	ee                   	out    %al,(%dx)
    f29f:	83 e9 04             	sub    $0x4,%ecx
    f2a2:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f2a5:	75 e9                	jne    f290 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x930>
    f2a7:	b8 0d 00 00 00       	mov    $0xd,%eax
    f2ac:	ee                   	out    %al,(%dx)
    f2ad:	b8 0a 00 00 00       	mov    $0xa,%eax
    f2b2:	ee                   	out    %al,(%dx)
    f2b3:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f2b8:	48 8d 0d 41 4d 00 00 	lea    0x4d41(%rip),%rcx        # 14000 <_data>
    f2bf:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f2c4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f2cb:	00 00 00 00 
    f2cf:	90                   	nop
    f2d0:	48 83 c1 01          	add    $0x1,%rcx
    f2d4:	ee                   	out    %al,(%dx)
    f2d5:	0f b6 01             	movzbl (%rcx),%eax
    f2d8:	84 c0                	test   %al,%al
    f2da:	75 f4                	jne    f2d0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x970>
    f2dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f2e1:	ee                   	out    %al,(%dx)
    f2e2:	b8 41 00 00 00       	mov    $0x41,%eax
    f2e7:	48 8d 0d d3 4e 00 00 	lea    0x4ed3(%rip),%rcx        # 141c1 <_data+0x1c1>
    f2ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f2f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f2fa:	00 00 00 00 
    f2fe:	66 90                	xchg   %ax,%ax
    f300:	48 83 c1 01          	add    $0x1,%rcx
    f304:	ee                   	out    %al,(%dx)
    f305:	0f b6 01             	movzbl (%rcx),%eax
    f308:	84 c0                	test   %al,%al
    f30a:	75 f4                	jne    f300 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x9a0>
    f30c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f311:	ee                   	out    %al,(%dx)
    f312:	b8 20 00 00 00       	mov    $0x20,%eax
    f317:	ee                   	out    %al,(%dx)
    f318:	b8 77 00 00 00       	mov    $0x77,%eax
    f31d:	48 8d 0d d9 4e 00 00 	lea    0x4ed9(%rip),%rcx        # 141fd <_data+0x1fd>
    f324:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f329:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f330:	48 83 c1 01          	add    $0x1,%rcx
    f334:	ee                   	out    %al,(%dx)
    f335:	0f b6 01             	movzbl (%rcx),%eax
    f338:	84 c0                	test   %al,%al
    f33a:	75 f4                	jne    f330 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x9d0>
    f33c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f341:	48 8d 0d 7e 4d 00 00 	lea    0x4d7e(%rip),%rcx        # 140c6 <_data+0xc6>
    f348:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f34d:	0f 1f 00             	nopl   (%rax)
    f350:	48 83 c1 01          	add    $0x1,%rcx
    f354:	ee                   	out    %al,(%dx)
    f355:	0f b6 01             	movzbl (%rcx),%eax
    f358:	84 c0                	test   %al,%al
    f35a:	75 f4                	jne    f350 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x9f0>
    f35c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f361:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f366:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f36d:	00 00 00 
    f370:	4c 89 d0             	mov    %r10,%rax
    f373:	48 d3 e8             	shr    %cl,%rax
    f376:	83 e0 0f             	and    $0xf,%eax
    f379:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f37e:	ee                   	out    %al,(%dx)
    f37f:	83 e9 04             	sub    $0x4,%ecx
    f382:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f385:	75 e9                	jne    f370 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xa10>
    f387:	b8 0d 00 00 00       	mov    $0xd,%eax
    f38c:	ee                   	out    %al,(%dx)
    f38d:	b8 0a 00 00 00       	mov    $0xa,%eax
    f392:	ee                   	out    %al,(%dx)
    f393:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f398:	48 8d 0d 61 4c 00 00 	lea    0x4c61(%rip),%rcx        # 14000 <_data>
    f39f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f3a4:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f3ab:	00 00 00 00 
    f3af:	90                   	nop
    f3b0:	48 83 c1 01          	add    $0x1,%rcx
    f3b4:	ee                   	out    %al,(%dx)
    f3b5:	0f b6 01             	movzbl (%rcx),%eax
    f3b8:	84 c0                	test   %al,%al
    f3ba:	75 f4                	jne    f3b0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xa50>
    f3bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f3c1:	ee                   	out    %al,(%dx)
    f3c2:	b8 41 00 00 00       	mov    $0x41,%eax
    f3c7:	48 8d 0d f3 4d 00 00 	lea    0x4df3(%rip),%rcx        # 141c1 <_data+0x1c1>
    f3ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f3d3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f3da:	00 00 00 00 
    f3de:	66 90                	xchg   %ax,%ax
    f3e0:	48 83 c1 01          	add    $0x1,%rcx
    f3e4:	ee                   	out    %al,(%dx)
    f3e5:	0f b6 01             	movzbl (%rcx),%eax
    f3e8:	84 c0                	test   %al,%al
    f3ea:	75 f4                	jne    f3e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xa80>
    f3ec:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f3f1:	ee                   	out    %al,(%dx)
    f3f2:	b8 20 00 00 00       	mov    $0x20,%eax
    f3f7:	ee                   	out    %al,(%dx)
    f3f8:	b8 77 00 00 00       	mov    $0x77,%eax
    f3fd:	48 8d 0d 01 4e 00 00 	lea    0x4e01(%rip),%rcx        # 14205 <_data+0x205>
    f404:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f409:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f410:	48 83 c1 01          	add    $0x1,%rcx
    f414:	ee                   	out    %al,(%dx)
    f415:	0f b6 01             	movzbl (%rcx),%eax
    f418:	84 c0                	test   %al,%al
    f41a:	75 f4                	jne    f410 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xab0>
    f41c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f421:	48 8d 0d 9e 4c 00 00 	lea    0x4c9e(%rip),%rcx        # 140c6 <_data+0xc6>
    f428:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f42d:	0f 1f 00             	nopl   (%rax)
    f430:	48 83 c1 01          	add    $0x1,%rcx
    f434:	ee                   	out    %al,(%dx)
    f435:	0f b6 01             	movzbl (%rcx),%eax
    f438:	84 c0                	test   %al,%al
    f43a:	75 f4                	jne    f430 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xad0>
    f43c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f441:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f446:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f44d:	00 00 00 
    f450:	48 89 f8             	mov    %rdi,%rax
    f453:	48 d3 e8             	shr    %cl,%rax
    f456:	83 e0 0f             	and    $0xf,%eax
    f459:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f45e:	ee                   	out    %al,(%dx)
    f45f:	83 e9 04             	sub    $0x4,%ecx
    f462:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f465:	75 e9                	jne    f450 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xaf0>
    f467:	b8 0d 00 00 00       	mov    $0xd,%eax
    f46c:	41 83 fd 01          	cmp    $0x1,%r13d
    f470:	0f 84 be 04 00 00    	je     f934 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xfd4>
    f476:	ee                   	out    %al,(%dx)
    f477:	b8 0a 00 00 00       	mov    $0xa,%eax
    f47c:	ee                   	out    %al,(%dx)
    f47d:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f482:	48 8d 0d 77 4b 00 00 	lea    0x4b77(%rip),%rcx        # 14000 <_data>
    f489:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f48e:	66 90                	xchg   %ax,%ax
    f490:	48 83 c1 01          	add    $0x1,%rcx
    f494:	ee                   	out    %al,(%dx)
    f495:	0f b6 01             	movzbl (%rcx),%eax
    f498:	84 c0                	test   %al,%al
    f49a:	75 f4                	jne    f490 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xb30>
    f49c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f4a1:	ee                   	out    %al,(%dx)
    f4a2:	b8 41 00 00 00       	mov    $0x41,%eax
    f4a7:	48 8d 0d 13 4d 00 00 	lea    0x4d13(%rip),%rcx        # 141c1 <_data+0x1c1>
    f4ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f4b3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f4ba:	00 00 00 00 
    f4be:	66 90                	xchg   %ax,%ax
    f4c0:	48 83 c1 01          	add    $0x1,%rcx
    f4c4:	ee                   	out    %al,(%dx)
    f4c5:	0f b6 01             	movzbl (%rcx),%eax
    f4c8:	84 c0                	test   %al,%al
    f4ca:	75 f4                	jne    f4c0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xb60>
    f4cc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f4d1:	ee                   	out    %al,(%dx)
    f4d2:	b8 20 00 00 00       	mov    $0x20,%eax
    f4d7:	ee                   	out    %al,(%dx)
    f4d8:	b8 46 00 00 00       	mov    $0x46,%eax
    f4dd:	48 8d 0d ea 4c 00 00 	lea    0x4cea(%rip),%rcx        # 141ce <_data+0x1ce>
    f4e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f4e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f4f0:	48 83 c1 01          	add    $0x1,%rcx
    f4f4:	ee                   	out    %al,(%dx)
    f4f5:	0f b6 01             	movzbl (%rcx),%eax
    f4f8:	84 c0                	test   %al,%al
    f4fa:	75 f4                	jne    f4f0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xb90>
    f4fc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f501:	ee                   	out    %al,(%dx)
    f502:	8b 44 24 08          	mov    0x8(%rsp),%eax
    f506:	85 c0                	test   %eax,%eax
    f508:	0f 84 fa 05 00 00    	je     fb08 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11a8>
    f50e:	83 c0 30             	add    $0x30,%eax
    f511:	ee                   	out    %al,(%dx)
    f512:	8b 44 24 08          	mov    0x8(%rsp),%eax
    f516:	44 89 2d 03 d8 00 00 	mov    %r13d,0xd803(%rip)        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    f51d:	48 89 2d 04 d8 00 00 	mov    %rbp,0xd804(%rip)        # 1cd28 <_ZN10UEFIBridge2ka8g_resultE+0x8>
    f524:	89 05 fa d7 00 00    	mov    %eax,0xd7fa(%rip)        # 1cd24 <_ZN10UEFIBridge2ka8g_resultE+0x4>
    f52a:	4c 89 05 ff d7 00 00 	mov    %r8,0xd7ff(%rip)        # 1cd30 <_ZN10UEFIBridge2ka8g_resultE+0x10>
    f531:	4c 89 0d 00 d8 00 00 	mov    %r9,0xd800(%rip)        # 1cd38 <_ZN10UEFIBridge2ka8g_resultE+0x18>
    f538:	4c 89 15 01 d8 00 00 	mov    %r10,0xd801(%rip)        # 1cd40 <_ZN10UEFIBridge2ka8g_resultE+0x20>
    f53f:	48 89 3d 02 d8 00 00 	mov    %rdi,0xd802(%rip)        # 1cd48 <_ZN10UEFIBridge2ka8g_resultE+0x28>
    f546:	48 89 35 03 d8 00 00 	mov    %rsi,0xd803(%rip)        # 1cd50 <_ZN10UEFIBridge2ka8g_resultE+0x30>
    f54d:	4c 89 1d 04 d8 00 00 	mov    %r11,0xd804(%rip)        # 1cd58 <_ZN10UEFIBridge2ka8g_resultE+0x38>
    f554:	e9 a5 f6 ff ff       	jmp    ebfe <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x29e>
    f559:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f560:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f565:	b8 0d 00 00 00       	mov    $0xd,%eax
    f56a:	ee                   	out    %al,(%dx)
    f56b:	b8 0a 00 00 00       	mov    $0xa,%eax
    f570:	ee                   	out    %al,(%dx)
    f571:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f576:	48 8d 0d 83 4a 00 00 	lea    0x4a83(%rip),%rcx        # 14000 <_data>
    f57d:	0f 1f 00             	nopl   (%rax)
    f580:	48 83 c1 01          	add    $0x1,%rcx
    f584:	ee                   	out    %al,(%dx)
    f585:	0f b6 01             	movzbl (%rcx),%eax
    f588:	84 c0                	test   %al,%al
    f58a:	75 f4                	jne    f580 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xc20>
    f58c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f591:	ee                   	out    %al,(%dx)
    f592:	b8 52 00 00 00       	mov    $0x52,%eax
    f597:	48 8d 0d 8d 4c 00 00 	lea    0x4c8d(%rip),%rcx        # 1422b <_data+0x22b>
    f59e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f5a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f5aa:	00 00 00 00 
    f5ae:	66 90                	xchg   %ax,%ax
    f5b0:	48 83 c1 01          	add    $0x1,%rcx
    f5b4:	ee                   	out    %al,(%dx)
    f5b5:	0f b6 01             	movzbl (%rcx),%eax
    f5b8:	84 c0                	test   %al,%al
    f5ba:	75 f4                	jne    f5b0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xc50>
    f5bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f5c1:	ee                   	out    %al,(%dx)
    f5c2:	b8 20 00 00 00       	mov    $0x20,%eax
    f5c7:	ee                   	out    %al,(%dx)
    f5c8:	b8 6d 00 00 00       	mov    $0x6d,%eax
    f5cd:	48 8d 0d 5a 4c 00 00 	lea    0x4c5a(%rip),%rcx        # 1422e <_data+0x22e>
    f5d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f5d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f5e0:	48 83 c1 01          	add    $0x1,%rcx
    f5e4:	ee                   	out    %al,(%dx)
    f5e5:	0f b6 01             	movzbl (%rcx),%eax
    f5e8:	84 c0                	test   %al,%al
    f5ea:	75 f4                	jne    f5e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xc80>
    f5ec:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f5f1:	48 8d 0d ce 4a 00 00 	lea    0x4ace(%rip),%rcx        # 140c6 <_data+0xc6>
    f5f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f5fd:	0f 1f 00             	nopl   (%rax)
    f600:	48 83 c1 01          	add    $0x1,%rcx
    f604:	ee                   	out    %al,(%dx)
    f605:	0f b6 01             	movzbl (%rcx),%eax
    f608:	84 c0                	test   %al,%al
    f60a:	75 f4                	jne    f600 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xca0>
    f60c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f611:	4c 8d 3d e8 57 00 00 	lea    0x57e8(%rip),%r15        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
    f618:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f61d:	0f 1f 00             	nopl   (%rax)
    f620:	48 89 f0             	mov    %rsi,%rax
    f623:	48 d3 e8             	shr    %cl,%rax
    f626:	83 e0 0f             	and    $0xf,%eax
    f629:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f62e:	ee                   	out    %al,(%dx)
    f62f:	83 e9 04             	sub    $0x4,%ecx
    f632:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    f635:	75 e9                	jne    f620 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xcc0>
    f637:	4d 85 e4             	test   %r12,%r12
    f63a:	0f 84 d5 01 00 00    	je     f815 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xeb5>
    f640:	4d 85 c0             	test   %r8,%r8
    f643:	0f 84 cc 01 00 00    	je     f815 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xeb5>
    f649:	49 8d 44 30 ff       	lea    -0x1(%r8,%rsi,1),%rax
    f64e:	48 39 f0             	cmp    %rsi,%rax
    f651:	0f 82 be 01 00 00    	jb     f815 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xeb5>
    f657:	48 81 fe ff ff fd 7f 	cmp    $0x7ffdffff,%rsi
    f65e:	0f 97 c1             	seta   %cl
    f661:	48 3d ff ff fe 7f    	cmp    $0x7ffeffff,%rax
    f667:	0f 96 c2             	setbe  %dl
    f66a:	89 cf                	mov    %ecx,%edi
    f66c:	21 d7                	and    %edx,%edi
    f66e:	48 ba ff ff ff ff 7f 	movabs $0xfffff77fffffffff,%rdx
    f675:	f7 ff ff 
    f678:	48 39 f2             	cmp    %rsi,%rdx
    f67b:	0f 92 c1             	setb   %cl
    f67e:	48 81 c2 00 00 01 00 	add    $0x10000,%rdx
    f685:	48 39 c2             	cmp    %rax,%rdx
    f688:	0f 93 c2             	setae  %dl
    f68b:	21 d1                	and    %edx,%ecx
    f68d:	83 3d 8c d6 00 00 01 	cmpl   $0x1,0xd68c(%rip)        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    f694:	0f 84 bc 04 00 00    	je     fb56 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11f6>
    f69a:	40 84 ff             	test   %dil,%dil
    f69d:	0f 85 70 04 00 00    	jne    fb13 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11b3>
    f6a3:	45 31 d2             	xor    %r10d,%r10d
    f6a6:	84 c9                	test   %cl,%cl
    f6a8:	0f 85 65 04 00 00    	jne    fb13 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11b3>
    f6ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f6b3:	b8 0d 00 00 00       	mov    $0xd,%eax
    f6b8:	ee                   	out    %al,(%dx)
    f6b9:	b8 0a 00 00 00       	mov    $0xa,%eax
    f6be:	ee                   	out    %al,(%dx)
    f6bf:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f6c4:	48 8d 0d 35 49 00 00 	lea    0x4935(%rip),%rcx        # 14000 <_data>
    f6cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    f6d0:	48 83 c1 01          	add    $0x1,%rcx
    f6d4:	ee                   	out    %al,(%dx)
    f6d5:	0f b6 01             	movzbl (%rcx),%eax
    f6d8:	84 c0                	test   %al,%al
    f6da:	75 f4                	jne    f6d0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xd70>
    f6dc:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f6e1:	ee                   	out    %al,(%dx)
    f6e2:	b8 52 00 00 00       	mov    $0x52,%eax
    f6e7:	48 8d 0d 3d 4b 00 00 	lea    0x4b3d(%rip),%rcx        # 1422b <_data+0x22b>
    f6ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f6f3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f6fa:	00 00 00 00 
    f6fe:	66 90                	xchg   %ax,%ax
    f700:	48 83 c1 01          	add    $0x1,%rcx
    f704:	ee                   	out    %al,(%dx)
    f705:	0f b6 01             	movzbl (%rcx),%eax
    f708:	84 c0                	test   %al,%al
    f70a:	75 f4                	jne    f700 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xda0>
    f70c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f711:	ee                   	out    %al,(%dx)
    f712:	b8 20 00 00 00       	mov    $0x20,%eax
    f717:	ee                   	out    %al,(%dx)
    f718:	b8 6d 00 00 00       	mov    $0x6d,%eax
    f71d:	48 8d 0d 14 4b 00 00 	lea    0x4b14(%rip),%rcx        # 14238 <_data+0x238>
    f724:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f729:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f730:	48 83 c1 01          	add    $0x1,%rcx
    f734:	ee                   	out    %al,(%dx)
    f735:	0f b6 01             	movzbl (%rcx),%eax
    f738:	84 c0                	test   %al,%al
    f73a:	75 f4                	jne    f730 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xdd0>
    f73c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f741:	ee                   	out    %al,(%dx)
    f742:	4d 85 d2             	test   %r10,%r10
    f745:	0f 84 de 01 00 00    	je     f929 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xfc9>
    f74b:	b8 31 00 00 00       	mov    $0x31,%eax
    f750:	ee                   	out    %al,(%dx)
    f751:	e9 6a f4 ff ff       	jmp    ebc0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x260>
    f756:	49 8b 7f 10          	mov    0x10(%r15),%rdi
    f75a:	4c 89 e2             	mov    %r12,%rdx
    f75d:	48 8d 35 ef 4a 00 00 	lea    0x4aef(%rip),%rsi        # 14253 <_data+0x253>
    f764:	e8 07 ec ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
    f769:	84 c0                	test   %al,%al
    f76b:	0f 85 de f3 ff ff    	jne    eb4f <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1ef>
    f771:	49 8b 7f 10          	mov    0x10(%r15),%rdi
    f775:	4c 89 e2             	mov    %r12,%rdx
    f778:	48 8d 35 e7 4a 00 00 	lea    0x4ae7(%rip),%rsi        # 14266 <_data+0x266>
    f77f:	e8 ec eb ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
    f784:	84 c0                	test   %al,%al
    f786:	0f 85 c3 f3 ff ff    	jne    eb4f <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1ef>
    f78c:	49 8b 7f 10          	mov    0x10(%r15),%rdi
    f790:	4c 89 e2             	mov    %r12,%rdx
    f793:	48 8d 35 df 4a 00 00 	lea    0x4adf(%rip),%rsi        # 14279 <_data+0x279>
    f79a:	e8 d1 eb ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
    f79f:	84 c0                	test   %al,%al
    f7a1:	0f 85 a8 f3 ff ff    	jne    eb4f <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1ef>
    f7a7:	49 8b 47 08          	mov    0x8(%r15),%rax
    f7ab:	c7 43 04 07 00 00 00 	movl   $0x7,0x4(%rbx)
    f7b2:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
    f7b9:	00 
    f7ba:	e9 21 f2 ff ff       	jmp    e9e0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x80>
    f7bf:	90                   	nop
    f7c0:	41 0f 20 df          	mov    %cr3,%r15
    f7c4:	9c                   	pushf
    f7c5:	5b                   	pop    %rbx
    f7c6:	fa                   	cli
    f7c7:	49 8b 16             	mov    (%r14),%rdx
    f7ca:	0f 22 da             	mov    %rdx,%cr3
    f7cd:	4c 89 ea             	mov    %r13,%rdx
    f7d0:	4c 89 c6             	mov    %r8,%rsi
    f7d3:	e8 a8 75 ff ff       	call   6d80 <CopyMem>
    f7d8:	41 0f 22 df          	mov    %r15,%cr3
    f7dc:	53                   	push   %rbx
    f7dd:	9d                   	popf
    f7de:	4d 01 ec             	add    %r13,%r12
    f7e1:	49 39 ec             	cmp    %rbp,%r12
    f7e4:	0f 82 96 f2 ff ff    	jb     ea80 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x120>
    f7ea:	48 8b 6c 24 28       	mov    0x28(%rsp),%rbp
    f7ef:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
    f7f4:	8b 45 0c             	mov    0xc(%rbp),%eax
    f7f7:	ba 01 00 00 00       	mov    $0x1,%edx
    f7fc:	e9 06 f3 ff ff       	jmp    eb07 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1a7>
    f801:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f808:	41 b9 04 00 00 00    	mov    $0x4,%r9d
    f80e:	31 c0                	xor    %eax,%eax
    f810:	e9 b7 f3 ff ff       	jmp    ebcc <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x26c>
    f815:	31 ff                	xor    %edi,%edi
    f817:	45 31 d2             	xor    %r10d,%r10d
    f81a:	e9 8f fe ff ff       	jmp    f6ae <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xd4e>
    f81f:	b8 0d 00 00 00       	mov    $0xd,%eax
    f824:	ee                   	out    %al,(%dx)
    f825:	b8 0a 00 00 00       	mov    $0xa,%eax
    f82a:	ee                   	out    %al,(%dx)
    f82b:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f830:	48 8d 0d c9 47 00 00 	lea    0x47c9(%rip),%rcx        # 14000 <_data>
    f837:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f83c:	0f 1f 40 00          	nopl   0x0(%rax)
    f840:	48 83 c1 01          	add    $0x1,%rcx
    f844:	ee                   	out    %al,(%dx)
    f845:	0f b6 01             	movzbl (%rcx),%eax
    f848:	84 c0                	test   %al,%al
    f84a:	75 f4                	jne    f840 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xee0>
    f84c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f851:	ee                   	out    %al,(%dx)
    f852:	b8 41 00 00 00       	mov    $0x41,%eax
    f857:	48 8d 0d 63 49 00 00 	lea    0x4963(%rip),%rcx        # 141c1 <_data+0x1c1>
    f85e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f863:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f86a:	00 00 00 00 
    f86e:	66 90                	xchg   %ax,%ax
    f870:	48 83 c1 01          	add    $0x1,%rcx
    f874:	ee                   	out    %al,(%dx)
    f875:	0f b6 01             	movzbl (%rcx),%eax
    f878:	84 c0                	test   %al,%al
    f87a:	75 f4                	jne    f870 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xf10>
    f87c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f881:	ee                   	out    %al,(%dx)
    f882:	b8 20 00 00 00       	mov    $0x20,%eax
    f887:	ee                   	out    %al,(%dx)
    f888:	b8 46 00 00 00       	mov    $0x46,%eax
    f88d:	48 8d 0d 3a 49 00 00 	lea    0x493a(%rip),%rcx        # 141ce <_data+0x1ce>
    f894:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f899:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f8a0:	48 83 c1 01          	add    $0x1,%rcx
    f8a4:	ee                   	out    %al,(%dx)
    f8a5:	0f b6 01             	movzbl (%rcx),%eax
    f8a8:	84 c0                	test   %al,%al
    f8aa:	75 f4                	jne    f8a0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xf40>
    f8ac:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f8b1:	ee                   	out    %al,(%dx)
    f8b2:	b8 37 00 00 00       	mov    $0x37,%eax
    f8b7:	ee                   	out    %al,(%dx)
    f8b8:	48 8b 05 91 55 00 00 	mov    0x5591(%rip),%rax        # 14e50 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k+0x50>
    f8bf:	48 89 2d 62 d4 00 00 	mov    %rbp,0xd462(%rip)        # 1cd28 <_ZN10UEFIBridge2ka8g_resultE+0x8>
    f8c6:	48 c7 05 5f d4 00 00 	movq   $0x0,0xd45f(%rip)        # 1cd30 <_ZN10UEFIBridge2ka8g_resultE+0x10>
    f8cd:	00 00 00 00 
    f8d1:	48 89 05 48 d4 00 00 	mov    %rax,0xd448(%rip)        # 1cd20 <_ZN10UEFIBridge2ka8g_resultE>
    f8d8:	48 c7 05 55 d4 00 00 	movq   $0x0,0xd455(%rip)        # 1cd38 <_ZN10UEFIBridge2ka8g_resultE+0x18>
    f8df:	00 00 00 00 
    f8e3:	48 c7 05 52 d4 00 00 	movq   $0x0,0xd452(%rip)        # 1cd40 <_ZN10UEFIBridge2ka8g_resultE+0x20>
    f8ea:	00 00 00 00 
    f8ee:	48 c7 05 4f d4 00 00 	movq   $0x0,0xd44f(%rip)        # 1cd48 <_ZN10UEFIBridge2ka8g_resultE+0x28>
    f8f5:	00 00 00 00 
    f8f9:	48 c7 05 4c d4 00 00 	movq   $0x0,0xd44c(%rip)        # 1cd50 <_ZN10UEFIBridge2ka8g_resultE+0x30>
    f900:	00 00 00 00 
    f904:	48 c7 05 49 d4 00 00 	movq   $0x0,0xd449(%rip)        # 1cd58 <_ZN10UEFIBridge2ka8g_resultE+0x38>
    f90b:	00 00 00 00 
    f90f:	e9 ea f2 ff ff       	jmp    ebfe <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x29e>
    f914:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%rsp)
    f91b:	00 
    f91c:	31 ff                	xor    %edi,%edi
    f91e:	45 31 d2             	xor    %r10d,%r10d
    f921:	45 31 c9             	xor    %r9d,%r9d
    f924:	e9 9c f8 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    f929:	b8 30 00 00 00       	mov    $0x30,%eax
    f92e:	ee                   	out    %al,(%dx)
    f92f:	e9 8c f2 ff ff       	jmp    ebc0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x260>
    f934:	ee                   	out    %al,(%dx)
    f935:	b8 0a 00 00 00       	mov    $0xa,%eax
    f93a:	ee                   	out    %al,(%dx)
    f93b:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f940:	48 8d 0d b9 46 00 00 	lea    0x46b9(%rip),%rcx        # 14000 <_data>
    f947:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f94c:	0f 1f 40 00          	nopl   0x0(%rax)
    f950:	48 83 c1 01          	add    $0x1,%rcx
    f954:	ee                   	out    %al,(%dx)
    f955:	0f b6 01             	movzbl (%rcx),%eax
    f958:	84 c0                	test   %al,%al
    f95a:	75 f4                	jne    f950 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xff0>
    f95c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    f961:	ee                   	out    %al,(%dx)
    f962:	b8 41 00 00 00       	mov    $0x41,%eax
    f967:	48 8d 0d 53 48 00 00 	lea    0x4853(%rip),%rcx        # 141c1 <_data+0x1c1>
    f96e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f973:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    f97a:	00 00 00 00 
    f97e:	66 90                	xchg   %ax,%ax
    f980:	48 83 c1 01          	add    $0x1,%rcx
    f984:	ee                   	out    %al,(%dx)
    f985:	0f b6 01             	movzbl (%rcx),%eax
    f988:	84 c0                	test   %al,%al
    f98a:	75 f4                	jne    f980 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1020>
    f98c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    f991:	ee                   	out    %al,(%dx)
    f992:	b8 20 00 00 00       	mov    $0x20,%eax
    f997:	ee                   	out    %al,(%dx)
    f998:	b8 43 00 00 00       	mov    $0x43,%eax
    f99d:	48 8d 0d 69 48 00 00 	lea    0x4869(%rip),%rcx        # 1420d <_data+0x20d>
    f9a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f9a9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    f9b0:	48 83 c1 01          	add    $0x1,%rcx
    f9b4:	ee                   	out    %al,(%dx)
    f9b5:	0f b6 01             	movzbl (%rcx),%eax
    f9b8:	84 c0                	test   %al,%al
    f9ba:	75 f4                	jne    f9b0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1050>
    f9bc:	b8 3d 00 00 00       	mov    $0x3d,%eax
    f9c1:	48 8d 0d fe 46 00 00 	lea    0x46fe(%rip),%rcx        # 140c6 <_data+0xc6>
    f9c8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f9cd:	0f 1f 00             	nopl   (%rax)
    f9d0:	48 83 c1 01          	add    $0x1,%rcx
    f9d4:	ee                   	out    %al,(%dx)
    f9d5:	0f b6 01             	movzbl (%rcx),%eax
    f9d8:	84 c0                	test   %al,%al
    f9da:	75 f4                	jne    f9d0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1070>
    f9dc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    f9e1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    f9e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    f9ed:	00 00 00 
    f9f0:	48 89 f0             	mov    %rsi,%rax
    f9f3:	48 d3 e8             	shr    %cl,%rax
    f9f6:	83 e0 0f             	and    $0xf,%eax
    f9f9:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    f9fe:	ee                   	out    %al,(%dx)
    f9ff:	83 e9 04             	sub    $0x4,%ecx
    fa02:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    fa05:	75 e9                	jne    f9f0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1090>
    fa07:	b8 0d 00 00 00       	mov    $0xd,%eax
    fa0c:	ee                   	out    %al,(%dx)
    fa0d:	b8 0a 00 00 00       	mov    $0xa,%eax
    fa12:	ee                   	out    %al,(%dx)
    fa13:	b8 5b 00 00 00       	mov    $0x5b,%eax
    fa18:	48 8d 0d e1 45 00 00 	lea    0x45e1(%rip),%rcx        # 14000 <_data>
    fa1f:	ba f8 03 00 00       	mov    $0x3f8,%edx
    fa24:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    fa2b:	00 00 00 00 
    fa2f:	90                   	nop
    fa30:	48 83 c1 01          	add    $0x1,%rcx
    fa34:	ee                   	out    %al,(%dx)
    fa35:	0f b6 01             	movzbl (%rcx),%eax
    fa38:	84 c0                	test   %al,%al
    fa3a:	75 f4                	jne    fa30 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x10d0>
    fa3c:	b8 5b 00 00 00       	mov    $0x5b,%eax
    fa41:	ee                   	out    %al,(%dx)
    fa42:	b8 41 00 00 00       	mov    $0x41,%eax
    fa47:	48 8d 0d 73 47 00 00 	lea    0x4773(%rip),%rcx        # 141c1 <_data+0x1c1>
    fa4e:	ba f8 03 00 00       	mov    $0x3f8,%edx
    fa53:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    fa5a:	00 00 00 00 
    fa5e:	66 90                	xchg   %ax,%ax
    fa60:	48 83 c1 01          	add    $0x1,%rcx
    fa64:	ee                   	out    %al,(%dx)
    fa65:	0f b6 01             	movzbl (%rcx),%eax
    fa68:	84 c0                	test   %al,%al
    fa6a:	75 f4                	jne    fa60 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1100>
    fa6c:	b8 5d 00 00 00       	mov    $0x5d,%eax
    fa71:	ee                   	out    %al,(%dx)
    fa72:	b8 20 00 00 00       	mov    $0x20,%eax
    fa77:	ee                   	out    %al,(%dx)
    fa78:	b8 43 00 00 00       	mov    $0x43,%eax
    fa7d:	48 8d 0d 98 47 00 00 	lea    0x4798(%rip),%rcx        # 1421c <_data+0x21c>
    fa84:	ba f8 03 00 00       	mov    $0x3f8,%edx
    fa89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    fa90:	48 83 c1 01          	add    $0x1,%rcx
    fa94:	ee                   	out    %al,(%dx)
    fa95:	0f b6 01             	movzbl (%rcx),%eax
    fa98:	84 c0                	test   %al,%al
    fa9a:	75 f4                	jne    fa90 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1130>
    fa9c:	b8 3d 00 00 00       	mov    $0x3d,%eax
    faa1:	48 8d 0d 1e 46 00 00 	lea    0x461e(%rip),%rcx        # 140c6 <_data+0xc6>
    faa8:	ba f8 03 00 00       	mov    $0x3f8,%edx
    faad:	0f 1f 00             	nopl   (%rax)
    fab0:	48 83 c1 01          	add    $0x1,%rcx
    fab4:	ee                   	out    %al,(%dx)
    fab5:	0f b6 01             	movzbl (%rcx),%eax
    fab8:	84 c0                	test   %al,%al
    faba:	75 f4                	jne    fab0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1150>
    fabc:	b9 3c 00 00 00       	mov    $0x3c,%ecx
    fac1:	ba f8 03 00 00       	mov    $0x3f8,%edx
    fac6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    facd:	00 00 00 
    fad0:	4c 89 d8             	mov    %r11,%rax
    fad3:	48 d3 e8             	shr    %cl,%rax
    fad6:	83 e0 0f             	and    $0xf,%eax
    fad9:	41 0f b6 04 07       	movzbl (%r15,%rax,1),%eax
    fade:	ee                   	out    %al,(%dx)
    fadf:	83 e9 04             	sub    $0x4,%ecx
    fae2:	83 f9 fc             	cmp    $0xfffffffc,%ecx
    fae5:	75 e9                	jne    fad0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1170>
    fae7:	83 0d be d6 00 00 40 	orl    $0x40,0xd6be(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
    faee:	e9 1f fa ff ff       	jmp    f512 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xbb2>
    faf3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%rsp)
    fafa:	00 
    fafb:	31 ff                	xor    %edi,%edi
    fafd:	45 31 d2             	xor    %r10d,%r10d
    fb00:	45 31 c9             	xor    %r9d,%r9d
    fb03:	e9 bd f6 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fb08:	b8 30 00 00 00       	mov    $0x30,%eax
    fb0d:	ee                   	out    %al,(%dx)
    fb0e:	e9 ff f9 ff ff       	jmp    f512 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xbb2>
    fb13:	31 c0                	xor    %eax,%eax
    fb15:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    fb1c:	00 00 00 00 
    fb20:	48 8d 14 30          	lea    (%rax,%rsi,1),%rdx
    fb24:	0f b6 12             	movzbl (%rdx),%edx
    fb27:	41 88 14 04          	mov    %dl,(%r12,%rax,1)
    fb2b:	48 83 c0 01          	add    $0x1,%rax
    fb2f:	4c 39 c0             	cmp    %r8,%rax
    fb32:	72 ec                	jb     fb20 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11c0>
    fb34:	bf 01 00 00 00       	mov    $0x1,%edi
    fb39:	41 ba 01 00 00 00    	mov    $0x1,%r10d
    fb3f:	e9 6a fb ff ff       	jmp    f6ae <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xd4e>
    fb44:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%rsp)
    fb4b:	00 
    fb4c:	31 ff                	xor    %edi,%edi
    fb4e:	45 31 d2             	xor    %r10d,%r10d
    fb51:	e9 6f f6 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fb56:	4c 8b 15 f3 d1 00 00 	mov    0xd1f3(%rip),%r10        # 1cd50 <_ZN10UEFIBridge2ka8g_resultE+0x30>
    fb5d:	48 8b 15 f4 d1 00 00 	mov    0xd1f4(%rip),%rdx        # 1cd58 <_ZN10UEFIBridge2ka8g_resultE+0x38>
    fb64:	4c 01 d2             	add    %r10,%rdx
    fb67:	48 83 ea 01          	sub    $0x1,%rdx
    fb6b:	48 39 c2             	cmp    %rax,%rdx
    fb6e:	0f 82 26 fb ff ff    	jb     f69a <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xd3a>
    fb74:	31 c0                	xor    %eax,%eax
    fb76:	4c 39 d6             	cmp    %r10,%rsi
    fb79:	73 a5                	jae    fb20 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x11c0>
    fb7b:	e9 1a fb ff ff       	jmp    f69a <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0xd3a>
    fb80:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%rsp)
    fb87:	00 
    fb88:	31 ff                	xor    %edi,%edi
    fb8a:	e9 36 f6 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fb8f:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%rsp)
    fb96:	00 
    fb97:	e9 29 f6 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fb9c:	41 0f b7 01          	movzwl (%r9),%eax
    fba0:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%rsp)
    fba7:	00 
    fba8:	66 3d 4d 5a          	cmp    $0x5a4d,%ax
    fbac:	0f 85 13 f6 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fbb2:	41 8b 41 3c          	mov    0x3c(%r9),%eax
    fbb6:	8d 50 c0             	lea    -0x40(%rax),%edx
    fbb9:	81 fa c0 0f 00 00    	cmp    $0xfc0,%edx
    fbbf:	0f 87 f8 00 00 00    	ja     fcbd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x135d>
    fbc5:	4c 01 c8             	add    %r9,%rax
    fbc8:	8b 10                	mov    (%rax),%edx
    fbca:	81 fa 50 45 00 00    	cmp    $0x4550,%edx
    fbd0:	0f 85 ef f5 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fbd6:	0f b7 50 04          	movzwl 0x4(%rax),%edx
    fbda:	66 81 fa 64 86       	cmp    $0x8664,%dx
    fbdf:	0f 85 e0 f5 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fbe5:	0f b7 50 06          	movzwl 0x6(%rax),%edx
    fbe9:	89 54 24 20          	mov    %edx,0x20(%rsp)
    fbed:	83 ea 01             	sub    $0x1,%edx
    fbf0:	83 fa 5f             	cmp    $0x5f,%edx
    fbf3:	0f 87 cc f5 ff ff    	ja     f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fbf9:	0f b7 50 14          	movzwl 0x14(%rax),%edx
    fbfd:	66 81 fa f0 00       	cmp    $0xf0,%dx
    fc02:	0f 85 bd f5 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fc08:	0f b7 50 18          	movzwl 0x18(%rax),%edx
    fc0c:	66 81 fa 0b 02       	cmp    $0x20b,%dx
    fc11:	0f 85 ae f5 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fc17:	44 8b 58 50          	mov    0x50(%rax),%r11d
    fc1b:	41 8d 93 00 00 fe ff 	lea    -0x20000(%r11),%edx
    fc22:	81 fa 00 00 fe 03    	cmp    $0x3fe0000,%edx
    fc28:	0f 87 97 f5 ff ff    	ja     f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fc2e:	44 89 da             	mov    %r11d,%edx
    fc31:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
    fc37:	89 54 24 10          	mov    %edx,0x10(%rsp)
    fc3b:	0f 85 84 f5 ff ff    	jne    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fc41:	8b 50 28             	mov    0x28(%rax),%edx
    fc44:	44 39 da             	cmp    %r11d,%edx
    fc47:	0f 83 78 f5 ff ff    	jae    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fc4d:	8b 50 54             	mov    0x54(%rax),%edx
    fc50:	83 ea 01             	sub    $0x1,%edx
    fc53:	44 39 da             	cmp    %r11d,%edx
    fc56:	73 65                	jae    fcbd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x135d>
    fc58:	48 8d 88 10 01 00 00 	lea    0x110(%rax),%rcx
    fc5f:	31 c0                	xor    %eax,%eax
    fc61:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
    fc66:	89 44 24 18          	mov    %eax,0x18(%rsp)
    fc6a:	eb 3e                	jmp    fcaa <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x134a>
    fc6c:	05 ff 0f 00 00       	add    $0xfff,%eax
    fc71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    fc76:	01 d0                	add    %edx,%eax
    fc78:	44 39 da             	cmp    %r11d,%edx
    fc7b:	73 40                	jae    fcbd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x135d>
    fc7d:	41 39 c3             	cmp    %eax,%r11d
    fc80:	72 3b                	jb     fcbd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x135d>
    fc82:	83 7c 24 10 00       	cmpl   $0x0,0x10(%rsp)
    fc87:	74 08                	je     fc91 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x1331>
    fc89:	8b 74 24 18          	mov    0x18(%rsp),%esi
    fc8d:	39 f2                	cmp    %esi,%edx
    fc8f:	72 2c                	jb     fcbd <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x135d>
    fc91:	83 44 24 10 01       	addl   $0x1,0x10(%rsp)
    fc96:	8b 74 24 20          	mov    0x20(%rsp),%esi
    fc9a:	48 83 c1 28          	add    $0x28,%rcx
    fc9e:	8b 54 24 10          	mov    0x10(%rsp),%edx
    fca2:	39 f2                	cmp    %esi,%edx
    fca4:	73 24                	jae    fcca <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x136a>
    fca6:	89 44 24 18          	mov    %eax,0x18(%rsp)
    fcaa:	8b 01                	mov    (%rcx),%eax
    fcac:	8b 51 04             	mov    0x4(%rcx),%edx
    fcaf:	89 d6                	mov    %edx,%esi
    fcb1:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
    fcb7:	89 74 24 08          	mov    %esi,0x8(%rsp)
    fcbb:	74 af                	je     fc6c <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x130c>
    fcbd:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%rsp)
    fcc4:	00 
    fcc5:	e9 fb f4 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fcca:	48 8b 74 24 28       	mov    0x28(%rsp),%rsi
    fccf:	4b 8d 14 19          	lea    (%r9,%r11,1),%rdx
    fcd3:	49 39 f5             	cmp    %rsi,%r13
    fcd6:	48 89 f0             	mov    %rsi,%rax
    fcd9:	49 0f 46 c5          	cmovbe %r13,%rax
    fcdd:	4c 39 c0             	cmp    %r8,%rax
    fce0:	49 0f 47 c0          	cmova  %r8,%rax
    fce4:	4c 39 c8             	cmp    %r9,%rax
    fce7:	0f 92 c0             	setb   %al
    fcea:	49 39 f5             	cmp    %rsi,%r13
    fced:	4c 0f 42 ee          	cmovb  %rsi,%r13
    fcf1:	49 39 d5             	cmp    %rdx,%r13
    fcf4:	0f 93 c1             	setae  %cl
    fcf7:	08 c1                	or     %al,%cl
    fcf9:	75 05                	jne    fd00 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x13a0>
    fcfb:	49 39 d0             	cmp    %rdx,%r8
    fcfe:	72 0d                	jb     fd0d <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x13ad>
    fd00:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%rsp)
    fd07:	00 
    fd08:	e9 b8 f4 ff ff       	jmp    f1c5 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x865>
    fd0d:	4c 89 ce             	mov    %r9,%rsi
    fd10:	41 bd 01 00 00 00    	mov    $0x1,%r13d
    fd16:	e9 b5 f4 ff ff       	jmp    f1d0 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm+0x870>
    fd1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

000000000000fd20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot>:
    fd20:	41 57                	push   %r15
    fd22:	41 56                	push   %r14
    fd24:	41 55                	push   %r13
    fd26:	41 54                	push   %r12
    fd28:	49 89 fc             	mov    %rdi,%r12
    fd2b:	55                   	push   %rbp
    fd2c:	48 89 f5             	mov    %rsi,%rbp
    fd2f:	53                   	push   %rbx
    fd30:	48 83 ec 78          	sub    $0x78,%rsp
    fd34:	48 8b 37             	mov    (%rdi),%rsi
    fd37:	48 8b 4e 10          	mov    0x10(%rsi),%rcx
    fd3b:	8b 41 18             	mov    0x18(%rcx),%eax
    fd3e:	8b 79 1c             	mov    0x1c(%rcx),%edi
    fd41:	44 8d 68 01          	lea    0x1(%rax),%r13d
    fd45:	41 83 e5 3f          	and    $0x3f,%r13d
    fd49:	44 39 ef             	cmp    %r13d,%edi
    fd4c:	0f 84 ce 01 00 00    	je     ff20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x200>
    fd52:	48 c1 e0 06          	shl    $0x6,%rax
    fd56:	66 0f ef c0          	pxor   %xmm0,%xmm0
    fd5a:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
    fd5e:	8b 45 00             	mov    0x0(%rbp),%eax
    fd61:	48 c7 43 18 00 00 00 	movq   $0x0,0x18(%rbx)
    fd68:	00 
    fd69:	44 8b 75 0c          	mov    0xc(%rbp),%r14d
    fd6d:	89 03                	mov    %eax,(%rbx)
    fd6f:	c7 43 04 02 00 00 00 	movl   $0x2,0x4(%rbx)
    fd76:	48 c7 43 20 00 00 00 	movq   $0x0,0x20(%rbx)
    fd7d:	00 
    fd7e:	0f 11 43 08          	movups %xmm0,0x8(%rbx)
    fd82:	41 81 fe 00 dc 3f 00 	cmp    $0x3fdc00,%r14d
    fd89:	0f 87 71 01 00 00    	ja     ff00 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1e0>
    fd8f:	4c 8b 7d 28          	mov    0x28(%rbp),%r15
    fd93:	49 81 ff 00 dc 3f 00 	cmp    $0x3fdc00,%r15
    fd9a:	0f 87 60 01 00 00    	ja     ff00 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1e0>
    fda0:	b8 00 dc 3f 00       	mov    $0x3fdc00,%eax
    fda5:	4c 29 f0             	sub    %r14,%rax
    fda8:	4c 39 f8             	cmp    %r15,%rax
    fdab:	0f 82 4f 01 00 00    	jb     ff00 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1e0>
    fdb1:	44 8b 4d 04          	mov    0x4(%rbp),%r9d
    fdb5:	41 83 f9 07          	cmp    $0x7,%r9d
    fdb9:	0f 84 31 02 00 00    	je     fff0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x2d0>
    fdbf:	0f 87 0b 02 00 00    	ja     ffd0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x2b0>
    fdc5:	41 83 f9 01          	cmp    $0x1,%r9d
    fdc9:	0f 84 71 01 00 00    	je     ff40 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x220>
    fdcf:	b8 08 00 00 00       	mov    $0x8,%eax
    fdd4:	41 83 f9 02          	cmp    $0x2,%r9d
    fdd8:	0f 85 06 02 00 00    	jne    ffe4 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x2c4>
    fdde:	49 8b 44 24 08       	mov    0x8(%r12),%rax
    fde3:	4c 8b 00             	mov    (%rax),%r8
    fde6:	48 8b 40 08          	mov    0x8(%rax),%rax
    fdea:	4d 85 c0             	test   %r8,%r8
    fded:	0f 84 85 02 00 00    	je     10078 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x358>
    fdf3:	48 85 c0             	test   %rax,%rax
    fdf6:	0f 84 7c 02 00 00    	je     10078 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x358>
    fdfc:	4d 85 f6             	test   %r14,%r14
    fdff:	0f 84 d0 02 00 00    	je     100d5 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x3b5>
    fe05:	48 8b 16             	mov    (%rsi),%rdx
    fe08:	4c 89 7c 24 18       	mov    %r15,0x18(%rsp)
    fe0d:	44 89 6c 24 24       	mov    %r13d,0x24(%rsp)
    fe12:	48 8d 8a 00 24 00 00 	lea    0x2400(%rdx),%rcx
    fe19:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    fe1e:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
    fe23:	48 8b 4d 10          	mov    0x10(%rbp),%rcx
    fe27:	4c 89 64 24 30       	mov    %r12,0x30(%rsp)
    fe2c:	48 89 0c 24          	mov    %rcx,(%rsp)
    fe30:	31 c9                	xor    %ecx,%ecx
    fe32:	48 89 5c 24 28       	mov    %rbx,0x28(%rsp)
    fe37:	48 89 cb             	mov    %rcx,%rbx
    fe3a:	48 89 6c 24 38       	mov    %rbp,0x38(%rsp)
    fe3f:	4c 89 c5             	mov    %r8,%rbp
    fe42:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    fe49:	00 00 00 00 
    fe4d:	0f 1f 00             	nopl   (%rax)
    fe50:	48 8b 04 24          	mov    (%rsp),%rax
    fe54:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
    fe59:	48 89 ef             	mov    %rbp,%rdi
    fe5c:	4c 8d 24 18          	lea    (%rax,%rbx,1),%r12
    fe60:	4c 89 e6             	mov    %r12,%rsi
    fe63:	e8 88 d2 ff ff       	call   d0f0 <_ZN10UEFIBridge14PhysicalMemory11TranslateVAEmm>
    fe68:	48 89 c7             	mov    %rax,%rdi
    fe6b:	48 85 c0             	test   %rax,%rax
    fe6e:	74 61                	je     fed1 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1b1>
    fe70:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    fe75:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
    fe7a:	48 01 d8             	add    %rbx,%rax
    fe7d:	80 7d 10 00          	cmpb   $0x0,0x10(%rbp)
    fe81:	4c 8d 04 01          	lea    (%rcx,%rax,1),%r8
    fe85:	74 4a                	je     fed1 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1b1>
    fe87:	48 b9 ff ff ff ff 0f 	movabs $0xfffffffff,%rcx
    fe8e:	00 00 00 
    fe91:	48 8d 47 ff          	lea    -0x1(%rdi),%rax
    fe95:	48 39 c1             	cmp    %rax,%rcx
    fe98:	72 37                	jb     fed1 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1b1>
    fe9a:	4c 89 e6             	mov    %r12,%rsi
    fe9d:	b8 00 10 00 00       	mov    $0x1000,%eax
    fea2:	4c 89 f2             	mov    %r14,%rdx
    fea5:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
    feab:	48 29 da             	sub    %rbx,%rdx
    feae:	48 29 f0             	sub    %rsi,%rax
    feb1:	48 39 d0             	cmp    %rdx,%rax
    feb4:	48 0f 46 d0          	cmovbe %rax,%rdx
    feb8:	49 89 d4             	mov    %rdx,%r12
    febb:	48 ba 00 00 00 00 10 	movabs $0x1000000000,%rdx
    fec2:	00 00 00 
    fec5:	4c 29 e2             	sub    %r12,%rdx
    fec8:	48 39 fa             	cmp    %rdi,%rdx
    fecb:	0f 83 b7 01 00 00    	jae    10088 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x368>
    fed1:	4c 8b 64 24 30       	mov    0x30(%rsp),%r12
    fed6:	44 8b 6c 24 24       	mov    0x24(%rsp),%r13d
    fedb:	45 31 f6             	xor    %r14d,%r14d
    fede:	48 8b 5c 24 28       	mov    0x28(%rsp),%rbx
    fee3:	49 8b 04 24          	mov    (%r12),%rax
    fee7:	48 8b 48 10          	mov    0x10(%rax),%rcx
    feeb:	b8 04 00 00 00       	mov    $0x4,%eax
    fef0:	89 43 04             	mov    %eax,0x4(%rbx)
    fef3:	4c 89 73 08          	mov    %r14,0x8(%rbx)
    fef7:	e9 a4 00 00 00       	jmp    ffa0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x280>
    fefc:	0f 1f 40 00          	nopl   0x0(%rax)
    ff00:	c7 43 04 05 00 00 00 	movl   $0x5,0x4(%rbx)
    ff07:	44 89 69 18          	mov    %r13d,0x18(%rcx)
    ff0b:	48 83 c4 78          	add    $0x78,%rsp
    ff0f:	5b                   	pop    %rbx
    ff10:	5d                   	pop    %rbp
    ff11:	41 5c                	pop    %r12
    ff13:	41 5d                	pop    %r13
    ff15:	41 5e                	pop    %r14
    ff17:	41 5f                	pop    %r15
    ff19:	c3                   	ret
    ff1a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    ff20:	48 8b 41 38          	mov    0x38(%rcx),%rax
    ff24:	48 83 c0 01          	add    $0x1,%rax
    ff28:	48 89 41 38          	mov    %rax,0x38(%rcx)
    ff2c:	48 83 c4 78          	add    $0x78,%rsp
    ff30:	5b                   	pop    %rbx
    ff31:	5d                   	pop    %rbp
    ff32:	41 5c                	pop    %r12
    ff34:	41 5d                	pop    %r13
    ff36:	41 5e                	pop    %r14
    ff38:	41 5f                	pop    %r15
    ff3a:	c3                   	ret
    ff3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    ff40:	49 8b 44 24 08       	mov    0x8(%r12),%rax
    ff45:	44 89 0c 24          	mov    %r9d,(%rsp)
    ff49:	48 8b 38             	mov    (%rax),%rdi
    ff4c:	48 8b 50 08          	mov    0x8(%rax),%rdx
    ff50:	48 85 ff             	test   %rdi,%rdi
    ff53:	74 33                	je     ff88 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x268>
    ff55:	48 85 d2             	test   %rdx,%rdx
    ff58:	74 2e                	je     ff88 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x268>
    ff5a:	48 8b 0e             	mov    (%rsi),%rcx
    ff5d:	48 8b 75 10          	mov    0x10(%rbp),%rsi
    ff61:	4d 89 f0             	mov    %r14,%r8
    ff64:	48 81 c1 00 24 00 00 	add    $0x2400,%rcx
    ff6b:	e8 a0 de ff ff       	call   de10 <_ZN10UEFIBridge14PhysicalMemory6ReadVAEmmPvm>
    ff70:	49 8b 14 24          	mov    (%r12),%rdx
    ff74:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
    ff78:	84 c0                	test   %al,%al
    ff7a:	74 0c                	je     ff88 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x268>
    ff7c:	8b 45 0c             	mov    0xc(%rbp),%eax
    ff7f:	44 8b 0c 24          	mov    (%rsp),%r9d
    ff83:	eb 0b                	jmp    ff90 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x270>
    ff85:	0f 1f 00             	nopl   (%rax)
    ff88:	41 b9 04 00 00 00    	mov    $0x4,%r9d
    ff8e:	31 c0                	xor    %eax,%eax
    ff90:	44 89 4b 04          	mov    %r9d,0x4(%rbx)
    ff94:	48 89 43 08          	mov    %rax,0x8(%rbx)
    ff98:	48 c7 43 20 00 00 00 	movq   $0x0,0x20(%rbx)
    ff9f:	00 
    ffa0:	44 89 69 18          	mov    %r13d,0x18(%rcx)
    ffa4:	49 8b 04 24          	mov    (%r12),%rax
    ffa8:	48 8b 50 10          	mov    0x10(%rax),%rdx
    ffac:	48 8b 42 30          	mov    0x30(%rdx),%rax
    ffb0:	48 83 c0 01          	add    $0x1,%rax
    ffb4:	48 89 42 30          	mov    %rax,0x30(%rdx)
    ffb8:	48 83 c4 78          	add    $0x78,%rsp
    ffbc:	5b                   	pop    %rbx
    ffbd:	5d                   	pop    %rbp
    ffbe:	41 5c                	pop    %r12
    ffc0:	41 5d                	pop    %r13
    ffc2:	41 5e                	pop    %r14
    ffc4:	41 5f                	pop    %r15
    ffc6:	c3                   	ret
    ffc7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    ffce:	00 00 
    ffd0:	41 81 f9 ef be ad de 	cmp    $0xdeadbeef,%r9d
    ffd7:	b8 08 00 00 00       	mov    $0x8,%eax
    ffdc:	ba 01 00 00 00       	mov    $0x1,%edx
    ffe1:	0f 44 c2             	cmove  %edx,%eax
    ffe4:	89 43 04             	mov    %eax,0x4(%rbx)
    ffe7:	eb b7                	jmp    ffa0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x280>
    ffe9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    fff0:	4c 8d 74 24 40       	lea    0x40(%rsp),%r14
    fff5:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
    fffa:	66 0f ef c0          	pxor   %xmm0,%xmm0
    fffe:	48 8d 35 42 42 00 00 	lea    0x4242(%rip),%rsi        # 14247 <_data+0x247>
   10005:	4c 89 f2             	mov    %r14,%rdx
   10008:	0f 29 44 24 40       	movaps %xmm0,0x40(%rsp)
   1000d:	48 c7 44 24 60 00 00 	movq   $0x0,0x60(%rsp)
   10014:	00 00 
   10016:	0f 29 44 24 50       	movaps %xmm0,0x50(%rsp)
   1001b:	e8 50 e3 ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
   10020:	84 c0                	test   %al,%al
   10022:	0f 84 b8 00 00 00    	je     100e0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x3c0>
   10028:	8b 45 30             	mov    0x30(%rbp),%eax
   1002b:	49 8b 54 24 08       	mov    0x8(%r12),%rdx
   10030:	85 c0                	test   %eax,%eax
   10032:	74 1c                	je     10050 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x330>
   10034:	3b 44 24 50          	cmp    0x50(%rsp),%eax
   10038:	74 16                	je     10050 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x330>
   1003a:	c7 43 04 07 00 00 00 	movl   $0x7,0x4(%rbx)
   10041:	48 c7 42 08 00 00 00 	movq   $0x0,0x8(%rdx)
   10048:	00 
   10049:	eb 19                	jmp    10064 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x344>
   1004b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   10050:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
   10055:	48 89 42 08          	mov    %rax,0x8(%rdx)
   10059:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%rbx)
   10060:	48 89 43 10          	mov    %rax,0x10(%rbx)
   10064:	49 8b 04 24          	mov    (%r12),%rax
   10068:	48 8b 48 10          	mov    0x10(%rax),%rcx
   1006c:	e9 2f ff ff ff       	jmp    ffa0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x280>
   10071:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10078:	b8 04 00 00 00       	mov    $0x4,%eax
   1007d:	45 31 f6             	xor    %r14d,%r14d
   10080:	e9 6b fe ff ff       	jmp    fef0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1d0>
   10085:	0f 1f 00             	nopl   (%rax)
   10088:	41 0f 20 df          	mov    %cr3,%r15
   1008c:	9c                   	pushf
   1008d:	41 5d                	pop    %r13
   1008f:	fa                   	cli
   10090:	48 8b 55 00          	mov    0x0(%rbp),%rdx
   10094:	0f 22 da             	mov    %rdx,%cr3
   10097:	4c 89 e2             	mov    %r12,%rdx
   1009a:	4c 89 c6             	mov    %r8,%rsi
   1009d:	e8 de 6c ff ff       	call   6d80 <CopyMem>
   100a2:	41 0f 22 df          	mov    %r15,%cr3
   100a6:	41 55                	push   %r13
   100a8:	9d                   	popf
   100a9:	4c 01 e3             	add    %r12,%rbx
   100ac:	4c 39 f3             	cmp    %r14,%rbx
   100af:	0f 82 9b fd ff ff    	jb     fe50 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x130>
   100b5:	4c 8b 64 24 30       	mov    0x30(%rsp),%r12
   100ba:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
   100bf:	44 8b 6c 24 24       	mov    0x24(%rsp),%r13d
   100c4:	48 8b 5c 24 28       	mov    0x28(%rsp),%rbx
   100c9:	49 8b 04 24          	mov    (%r12),%rax
   100cd:	44 8b 75 0c          	mov    0xc(%rbp),%r14d
   100d1:	48 8b 48 10          	mov    0x10(%rax),%rcx
   100d5:	b8 01 00 00 00       	mov    $0x1,%eax
   100da:	e9 11 fe ff ff       	jmp    fef0 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x1d0>
   100df:	90                   	nop
   100e0:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
   100e5:	4c 89 f2             	mov    %r14,%rdx
   100e8:	48 8d 35 64 41 00 00 	lea    0x4164(%rip),%rsi        # 14253 <_data+0x253>
   100ef:	e8 7c e2 ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
   100f4:	84 c0                	test   %al,%al
   100f6:	0f 85 2c ff ff ff    	jne    10028 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x308>
   100fc:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
   10101:	4c 89 f2             	mov    %r14,%rdx
   10104:	48 8d 35 5b 41 00 00 	lea    0x415b(%rip),%rsi        # 14266 <_data+0x266>
   1010b:	e8 60 e2 ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
   10110:	84 c0                	test   %al,%al
   10112:	0f 85 10 ff ff ff    	jne    10028 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x308>
   10118:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
   1011d:	4c 89 f2             	mov    %r14,%rdx
   10120:	48 8d 35 52 41 00 00 	lea    0x4152(%rip),%rsi        # 14279 <_data+0x279>
   10127:	e8 44 e2 ff ff       	call   e370 <_ZN10UEFIBridge13ProcessFinder10FindByNameEPKhPNS_11ProcessInfoE>
   1012c:	84 c0                	test   %al,%al
   1012e:	0f 85 f4 fe ff ff    	jne    10028 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x308>
   10134:	49 8b 44 24 08       	mov    0x8(%r12),%rax
   10139:	c7 43 04 07 00 00 00 	movl   $0x7,0x4(%rbx)
   10140:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
   10147:	00 
   10148:	e9 17 ff ff ff       	jmp    10064 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot+0x344>
   1014d:	0f 1f 00             	nopl   (%rax)

0000000000010150 <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_>:
   10150:	48 8b 02             	mov    (%rdx),%rax
   10153:	48 85 c0             	test   %rax,%rax
   10156:	0f 84 14 01 00 00    	je     10270 <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_+0x120>
   1015c:	41 56                	push   %r14
   1015e:	41 55                	push   %r13
   10160:	41 54                	push   %r12
   10162:	55                   	push   %rbp
   10163:	48 89 d5             	mov    %rdx,%rbp
   10166:	57                   	push   %rdi
   10167:	56                   	push   %rsi
   10168:	53                   	push   %rbx
   10169:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
   10170:	48 83 7a 08 00       	cmpq   $0x0,0x8(%rdx)
   10175:	0f 29 34 24          	movaps %xmm6,(%rsp)
   10179:	0f 29 7c 24 10       	movaps %xmm7,0x10(%rsp)
   1017e:	44 0f 29 44 24 20    	movaps %xmm8,0x20(%rsp)
   10184:	44 0f 29 4c 24 30    	movaps %xmm9,0x30(%rsp)
   1018a:	44 0f 29 54 24 40    	movaps %xmm10,0x40(%rsp)
   10190:	44 0f 29 5c 24 50    	movaps %xmm11,0x50(%rsp)
   10196:	44 0f 29 64 24 60    	movaps %xmm12,0x60(%rsp)
   1019c:	44 0f 29 6c 24 70    	movaps %xmm13,0x70(%rsp)
   101a2:	44 0f 29 b4 24 80 00 	movaps %xmm14,0x80(%rsp)
   101a9:	00 00 
   101ab:	44 0f 29 bc 24 90 00 	movaps %xmm15,0x90(%rsp)
   101b2:	00 00 
   101b4:	74 68                	je     1021e <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_+0xce>
   101b6:	4c 8b 70 10          	mov    0x10(%rax),%r14
   101ba:	48 8b 12             	mov    (%rdx),%rdx
   101bd:	41 8b 46 10          	mov    0x10(%r14),%eax
   101c1:	41 8b 5e 14          	mov    0x14(%r14),%ebx
   101c5:	4c 8b 22             	mov    (%rdx),%r12
   101c8:	4d 8d ac 24 00 04 00 	lea    0x400(%r12),%r13
   101cf:	00 
   101d0:	49 81 c4 00 14 00 00 	add    $0x1400,%r12
   101d7:	39 d8                	cmp    %ebx,%eax
   101d9:	74 37                	je     10212 <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_+0xc2>
   101db:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   101e0:	89 de                	mov    %ebx,%esi
   101e2:	83 c3 01             	add    $0x1,%ebx
   101e5:	4c 89 e2             	mov    %r12,%rdx
   101e8:	48 89 ef             	mov    %rbp,%rdi
   101eb:	48 c1 e6 06          	shl    $0x6,%rsi
   101ef:	83 e3 3f             	and    $0x3f,%ebx
   101f2:	4c 01 ee             	add    %r13,%rsi
   101f5:	e8 26 fb ff ff       	call   fd20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot>
   101fa:	41 89 5e 14          	mov    %ebx,0x14(%r14)
   101fe:	49 8b 46 28          	mov    0x28(%r14),%rax
   10202:	48 83 c0 01          	add    $0x1,%rax
   10206:	49 89 46 28          	mov    %rax,0x28(%r14)
   1020a:	41 8b 46 10          	mov    0x10(%r14),%eax
   1020e:	39 c3                	cmp    %eax,%ebx
   10210:	75 ce                	jne    101e0 <_ZN10UEFIBridge14RequestHandler13TimerCallbackEPvS1_+0x90>
   10212:	49 8b 46 20          	mov    0x20(%r14),%rax
   10216:	48 83 c0 01          	add    $0x1,%rax
   1021a:	49 89 46 20          	mov    %rax,0x20(%r14)
   1021e:	0f 28 34 24          	movaps (%rsp),%xmm6
   10222:	0f 28 7c 24 10       	movaps 0x10(%rsp),%xmm7
   10227:	44 0f 28 44 24 20    	movaps 0x20(%rsp),%xmm8
   1022d:	44 0f 28 4c 24 30    	movaps 0x30(%rsp),%xmm9
   10233:	44 0f 28 54 24 40    	movaps 0x40(%rsp),%xmm10
   10239:	44 0f 28 5c 24 50    	movaps 0x50(%rsp),%xmm11
   1023f:	44 0f 28 64 24 60    	movaps 0x60(%rsp),%xmm12
   10245:	44 0f 28 6c 24 70    	movaps 0x70(%rsp),%xmm13
   1024b:	44 0f 28 b4 24 80 00 	movaps 0x80(%rsp),%xmm14
   10252:	00 00 
   10254:	44 0f 28 bc 24 90 00 	movaps 0x90(%rsp),%xmm15
   1025b:	00 00 
   1025d:	48 81 c4 a0 00 00 00 	add    $0xa0,%rsp
   10264:	5b                   	pop    %rbx
   10265:	5e                   	pop    %rsi
   10266:	5f                   	pop    %rdi
   10267:	5d                   	pop    %rbp
   10268:	41 5c                	pop    %r12
   1026a:	41 5d                	pop    %r13
   1026c:	41 5e                	pop    %r14
   1026e:	c3                   	ret
   1026f:	90                   	nop
   10270:	c3                   	ret
   10271:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   10278:	00 00 00 
   1027b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000010280 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv>:
   10280:	48 8d 05 99 cf 00 00 	lea    0xcf99(%rip),%rax        # 1d220 <RT>
   10287:	49 89 f8             	mov    %rdi,%r8
   1028a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1028f:	48 89 3d 82 ca 00 00 	mov    %rdi,0xca82(%rip)        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   10296:	48 8b 38             	mov    (%rax),%rdi
   10299:	4c 8b 5f 18          	mov    0x18(%rdi),%r11
   1029d:	4d 89 58 08          	mov    %r11,0x8(%r8)
   102a1:	4c 8b 57 48          	mov    0x48(%rdi),%r10
   102a5:	4d 89 50 10          	mov    %r10,0x10(%r8)
   102a9:	4c 8b 4f 58          	mov    0x58(%rdi),%r9
   102ad:	4d 89 48 18          	mov    %r9,0x18(%r8)
   102b1:	48 8b 47 50          	mov    0x50(%rdi),%rax
   102b5:	49 89 40 20          	mov    %rax,0x20(%r8)
   102b9:	48 8b 47 30          	mov    0x30(%rdi),%rax
   102bd:	49 89 40 28          	mov    %rax,0x28(%r8)
   102c1:	b8 0d 00 00 00       	mov    $0xd,%eax
   102c6:	ee                   	out    %al,(%dx)
   102c7:	b8 0a 00 00 00       	mov    $0xa,%eax
   102cc:	ee                   	out    %al,(%dx)
   102cd:	b8 5b 00 00 00       	mov    $0x5b,%eax
   102d2:	48 8d 0d 27 3d 00 00 	lea    0x3d27(%rip),%rcx        # 14000 <_data>
   102d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   102e0:	48 83 c1 01          	add    $0x1,%rcx
   102e4:	ee                   	out    %al,(%dx)
   102e5:	0f b6 01             	movzbl (%rcx),%eax
   102e8:	84 c0                	test   %al,%al
   102ea:	75 f4                	jne    102e0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x60>
   102ec:	b8 5b 00 00 00       	mov    $0x5b,%eax
   102f1:	ee                   	out    %al,(%dx)
   102f2:	b8 52 00 00 00       	mov    $0x52,%eax
   102f7:	48 8d 0d 89 3f 00 00 	lea    0x3f89(%rip),%rcx        # 14287 <_data+0x287>
   102fe:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10303:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1030a:	00 00 00 00 
   1030e:	66 90                	xchg   %ax,%ax
   10310:	48 83 c1 01          	add    $0x1,%rcx
   10314:	ee                   	out    %al,(%dx)
   10315:	0f b6 01             	movzbl (%rcx),%eax
   10318:	84 c0                	test   %al,%al
   1031a:	75 f4                	jne    10310 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x90>
   1031c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10321:	ee                   	out    %al,(%dx)
   10322:	b8 20 00 00 00       	mov    $0x20,%eax
   10327:	ee                   	out    %al,(%dx)
   10328:	b8 6f 00 00 00       	mov    $0x6f,%eax
   1032d:	48 8d 0d 5c 3f 00 00 	lea    0x3f5c(%rip),%rcx        # 14290 <_data+0x290>
   10334:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10339:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10340:	48 83 c1 01          	add    $0x1,%rcx
   10344:	ee                   	out    %al,(%dx)
   10345:	0f b6 01             	movzbl (%rcx),%eax
   10348:	84 c0                	test   %al,%al
   1034a:	75 f4                	jne    10340 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0xc0>
   1034c:	b8 3d 00 00 00       	mov    $0x3d,%eax
   10351:	48 8d 0d 6e 3d 00 00 	lea    0x3d6e(%rip),%rcx        # 140c6 <_data+0xc6>
   10358:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1035d:	0f 1f 00             	nopl   (%rax)
   10360:	48 83 c1 01          	add    $0x1,%rcx
   10364:	ee                   	out    %al,(%dx)
   10365:	0f b6 01             	movzbl (%rcx),%eax
   10368:	84 c0                	test   %al,%al
   1036a:	75 f4                	jne    10360 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0xe0>
   1036c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   10371:	48 8d 35 88 4a 00 00 	lea    0x4a88(%rip),%rsi        # 14e00 <_ZZN10UEFIBridge11SerialTrace5Hex64EmE1k>
   10378:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1037d:	0f 1f 00             	nopl   (%rax)
   10380:	4c 89 d8             	mov    %r11,%rax
   10383:	48 d3 e8             	shr    %cl,%rax
   10386:	83 e0 0f             	and    $0xf,%eax
   10389:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1038d:	ee                   	out    %al,(%dx)
   1038e:	83 e9 04             	sub    $0x4,%ecx
   10391:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10394:	75 ea                	jne    10380 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x100>
   10396:	b8 0d 00 00 00       	mov    $0xd,%eax
   1039b:	ee                   	out    %al,(%dx)
   1039c:	b8 0a 00 00 00       	mov    $0xa,%eax
   103a1:	ee                   	out    %al,(%dx)
   103a2:	b8 5b 00 00 00       	mov    $0x5b,%eax
   103a7:	48 8d 0d 52 3c 00 00 	lea    0x3c52(%rip),%rcx        # 14000 <_data>
   103ae:	ba f8 03 00 00       	mov    $0x3f8,%edx
   103b3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   103ba:	00 00 00 00 
   103be:	66 90                	xchg   %ax,%ax
   103c0:	48 83 c1 01          	add    $0x1,%rcx
   103c4:	ee                   	out    %al,(%dx)
   103c5:	0f b6 01             	movzbl (%rcx),%eax
   103c8:	84 c0                	test   %al,%al
   103ca:	75 f4                	jne    103c0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x140>
   103cc:	b8 5b 00 00 00       	mov    $0x5b,%eax
   103d1:	ee                   	out    %al,(%dx)
   103d2:	b8 52 00 00 00       	mov    $0x52,%eax
   103d7:	48 8d 0d a9 3e 00 00 	lea    0x3ea9(%rip),%rcx        # 14287 <_data+0x287>
   103de:	ba f8 03 00 00       	mov    $0x3f8,%edx
   103e3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   103ea:	00 00 00 00 
   103ee:	66 90                	xchg   %ax,%ax
   103f0:	48 83 c1 01          	add    $0x1,%rcx
   103f4:	ee                   	out    %al,(%dx)
   103f5:	0f b6 01             	movzbl (%rcx),%eax
   103f8:	84 c0                	test   %al,%al
   103fa:	75 f4                	jne    103f0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x170>
   103fc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10401:	ee                   	out    %al,(%dx)
   10402:	b8 20 00 00 00       	mov    $0x20,%eax
   10407:	ee                   	out    %al,(%dx)
   10408:	b8 6f 00 00 00       	mov    $0x6f,%eax
   1040d:	48 8d 0d 91 3e 00 00 	lea    0x3e91(%rip),%rcx        # 142a5 <_data+0x2a5>
   10414:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10419:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10420:	48 83 c1 01          	add    $0x1,%rcx
   10424:	ee                   	out    %al,(%dx)
   10425:	0f b6 01             	movzbl (%rcx),%eax
   10428:	84 c0                	test   %al,%al
   1042a:	75 f4                	jne    10420 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x1a0>
   1042c:	b8 3d 00 00 00       	mov    $0x3d,%eax
   10431:	48 8d 0d 8e 3c 00 00 	lea    0x3c8e(%rip),%rcx        # 140c6 <_data+0xc6>
   10438:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1043d:	0f 1f 00             	nopl   (%rax)
   10440:	48 83 c1 01          	add    $0x1,%rcx
   10444:	ee                   	out    %al,(%dx)
   10445:	0f b6 01             	movzbl (%rcx),%eax
   10448:	84 c0                	test   %al,%al
   1044a:	75 f4                	jne    10440 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x1c0>
   1044c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   10451:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10456:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1045d:	00 00 00 
   10460:	4c 89 d0             	mov    %r10,%rax
   10463:	48 d3 e8             	shr    %cl,%rax
   10466:	83 e0 0f             	and    $0xf,%eax
   10469:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1046d:	ee                   	out    %al,(%dx)
   1046e:	83 e9 04             	sub    $0x4,%ecx
   10471:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10474:	75 ea                	jne    10460 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x1e0>
   10476:	b8 0d 00 00 00       	mov    $0xd,%eax
   1047b:	ee                   	out    %al,(%dx)
   1047c:	b8 0a 00 00 00       	mov    $0xa,%eax
   10481:	ee                   	out    %al,(%dx)
   10482:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10487:	48 8d 0d 72 3b 00 00 	lea    0x3b72(%rip),%rcx        # 14000 <_data>
   1048e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10493:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1049a:	00 00 00 00 
   1049e:	66 90                	xchg   %ax,%ax
   104a0:	48 83 c1 01          	add    $0x1,%rcx
   104a4:	ee                   	out    %al,(%dx)
   104a5:	0f b6 01             	movzbl (%rcx),%eax
   104a8:	84 c0                	test   %al,%al
   104aa:	75 f4                	jne    104a0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x220>
   104ac:	b8 5b 00 00 00       	mov    $0x5b,%eax
   104b1:	ee                   	out    %al,(%dx)
   104b2:	b8 52 00 00 00       	mov    $0x52,%eax
   104b7:	48 8d 0d c9 3d 00 00 	lea    0x3dc9(%rip),%rcx        # 14287 <_data+0x287>
   104be:	ba f8 03 00 00       	mov    $0x3f8,%edx
   104c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   104ca:	00 00 00 00 
   104ce:	66 90                	xchg   %ax,%ax
   104d0:	48 83 c1 01          	add    $0x1,%rcx
   104d4:	ee                   	out    %al,(%dx)
   104d5:	0f b6 01             	movzbl (%rcx),%eax
   104d8:	84 c0                	test   %al,%al
   104da:	75 f4                	jne    104d0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x250>
   104dc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   104e1:	ee                   	out    %al,(%dx)
   104e2:	b8 20 00 00 00       	mov    $0x20,%eax
   104e7:	ee                   	out    %al,(%dx)
   104e8:	b8 6f 00 00 00       	mov    $0x6f,%eax
   104ed:	48 8d 0d c6 3d 00 00 	lea    0x3dc6(%rip),%rcx        # 142ba <_data+0x2ba>
   104f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   104f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10500:	48 83 c1 01          	add    $0x1,%rcx
   10504:	ee                   	out    %al,(%dx)
   10505:	0f b6 01             	movzbl (%rcx),%eax
   10508:	84 c0                	test   %al,%al
   1050a:	75 f4                	jne    10500 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x280>
   1050c:	b8 3d 00 00 00       	mov    $0x3d,%eax
   10511:	48 8d 0d ae 3b 00 00 	lea    0x3bae(%rip),%rcx        # 140c6 <_data+0xc6>
   10518:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1051d:	0f 1f 00             	nopl   (%rax)
   10520:	48 83 c1 01          	add    $0x1,%rcx
   10524:	ee                   	out    %al,(%dx)
   10525:	0f b6 01             	movzbl (%rcx),%eax
   10528:	84 c0                	test   %al,%al
   1052a:	75 f4                	jne    10520 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x2a0>
   1052c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   10531:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10536:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1053d:	00 00 00 
   10540:	4c 89 c8             	mov    %r9,%rax
   10543:	48 d3 e8             	shr    %cl,%rax
   10546:	83 e0 0f             	and    $0xf,%eax
   10549:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1054d:	ee                   	out    %al,(%dx)
   1054e:	83 e9 04             	sub    $0x4,%ecx
   10551:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10554:	75 ea                	jne    10540 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x2c0>
   10556:	4c 8d 1d e3 1a 00 00 	lea    0x1ae3(%rip),%r11        # 12040 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES>
   1055d:	4c 8d 15 6c 10 00 00 	lea    0x106c(%rip),%r10        # 115d0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv>
   10564:	b8 0d 00 00 00       	mov    $0xd,%eax
   10569:	4c 8d 0d 60 07 00 00 	lea    0x760(%rip),%r9        # 10cd0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv>
   10570:	4c 89 5f 18          	mov    %r11,0x18(%rdi)
   10574:	4c 89 57 48          	mov    %r10,0x48(%rdi)
   10578:	4c 89 4f 58          	mov    %r9,0x58(%rdi)
   1057c:	ee                   	out    %al,(%dx)
   1057d:	b8 0a 00 00 00       	mov    $0xa,%eax
   10582:	ee                   	out    %al,(%dx)
   10583:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10588:	48 8d 0d 71 3a 00 00 	lea    0x3a71(%rip),%rcx        # 14000 <_data>
   1058f:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10594:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1059b:	00 00 00 00 
   1059f:	90                   	nop
   105a0:	48 83 c1 01          	add    $0x1,%rcx
   105a4:	ee                   	out    %al,(%dx)
   105a5:	0f b6 01             	movzbl (%rcx),%eax
   105a8:	84 c0                	test   %al,%al
   105aa:	75 f4                	jne    105a0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x320>
   105ac:	b8 5b 00 00 00       	mov    $0x5b,%eax
   105b1:	ee                   	out    %al,(%dx)
   105b2:	b8 52 00 00 00       	mov    $0x52,%eax
   105b7:	48 8d 0d c9 3c 00 00 	lea    0x3cc9(%rip),%rcx        # 14287 <_data+0x287>
   105be:	ba f8 03 00 00       	mov    $0x3f8,%edx
   105c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   105ca:	00 00 00 00 
   105ce:	66 90                	xchg   %ax,%ax
   105d0:	48 83 c1 01          	add    $0x1,%rcx
   105d4:	ee                   	out    %al,(%dx)
   105d5:	0f b6 01             	movzbl (%rcx),%eax
   105d8:	84 c0                	test   %al,%al
   105da:	75 f4                	jne    105d0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x350>
   105dc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   105e1:	ee                   	out    %al,(%dx)
   105e2:	b8 20 00 00 00       	mov    $0x20,%eax
   105e7:	ee                   	out    %al,(%dx)
   105e8:	b8 68 00 00 00       	mov    $0x68,%eax
   105ed:	48 8d 0d db 3c 00 00 	lea    0x3cdb(%rip),%rcx        # 142cf <_data+0x2cf>
   105f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   105f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10600:	48 83 c1 01          	add    $0x1,%rcx
   10604:	ee                   	out    %al,(%dx)
   10605:	0f b6 01             	movzbl (%rcx),%eax
   10608:	84 c0                	test   %al,%al
   1060a:	75 f4                	jne    10600 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x380>
   1060c:	b8 3d 00 00 00       	mov    $0x3d,%eax
   10611:	48 8d 0d ae 3a 00 00 	lea    0x3aae(%rip),%rcx        # 140c6 <_data+0xc6>
   10618:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1061d:	0f 1f 00             	nopl   (%rax)
   10620:	48 83 c1 01          	add    $0x1,%rcx
   10624:	ee                   	out    %al,(%dx)
   10625:	0f b6 01             	movzbl (%rcx),%eax
   10628:	84 c0                	test   %al,%al
   1062a:	75 f4                	jne    10620 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x3a0>
   1062c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   10631:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10636:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1063d:	00 00 00 
   10640:	4c 89 d8             	mov    %r11,%rax
   10643:	48 d3 e8             	shr    %cl,%rax
   10646:	83 e0 0f             	and    $0xf,%eax
   10649:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1064d:	ee                   	out    %al,(%dx)
   1064e:	83 e9 04             	sub    $0x4,%ecx
   10651:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10654:	75 ea                	jne    10640 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x3c0>
   10656:	b8 0d 00 00 00       	mov    $0xd,%eax
   1065b:	ee                   	out    %al,(%dx)
   1065c:	b8 0a 00 00 00       	mov    $0xa,%eax
   10661:	ee                   	out    %al,(%dx)
   10662:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10667:	48 8d 0d 92 39 00 00 	lea    0x3992(%rip),%rcx        # 14000 <_data>
   1066e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10673:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1067a:	00 00 00 00 
   1067e:	66 90                	xchg   %ax,%ax
   10680:	48 83 c1 01          	add    $0x1,%rcx
   10684:	ee                   	out    %al,(%dx)
   10685:	0f b6 01             	movzbl (%rcx),%eax
   10688:	84 c0                	test   %al,%al
   1068a:	75 f4                	jne    10680 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x400>
   1068c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10691:	ee                   	out    %al,(%dx)
   10692:	b8 52 00 00 00       	mov    $0x52,%eax
   10697:	48 8d 0d e9 3b 00 00 	lea    0x3be9(%rip),%rcx        # 14287 <_data+0x287>
   1069e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   106a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   106aa:	00 00 00 00 
   106ae:	66 90                	xchg   %ax,%ax
   106b0:	48 83 c1 01          	add    $0x1,%rcx
   106b4:	ee                   	out    %al,(%dx)
   106b5:	0f b6 01             	movzbl (%rcx),%eax
   106b8:	84 c0                	test   %al,%al
   106ba:	75 f4                	jne    106b0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x430>
   106bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   106c1:	ee                   	out    %al,(%dx)
   106c2:	b8 20 00 00 00       	mov    $0x20,%eax
   106c7:	ee                   	out    %al,(%dx)
   106c8:	b8 68 00 00 00       	mov    $0x68,%eax
   106cd:	48 8d 0d 10 3c 00 00 	lea    0x3c10(%rip),%rcx        # 142e4 <_data+0x2e4>
   106d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   106d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   106e0:	48 83 c1 01          	add    $0x1,%rcx
   106e4:	ee                   	out    %al,(%dx)
   106e5:	0f b6 01             	movzbl (%rcx),%eax
   106e8:	84 c0                	test   %al,%al
   106ea:	75 f4                	jne    106e0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x460>
   106ec:	b8 3d 00 00 00       	mov    $0x3d,%eax
   106f1:	48 8d 0d ce 39 00 00 	lea    0x39ce(%rip),%rcx        # 140c6 <_data+0xc6>
   106f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
   106fd:	0f 1f 00             	nopl   (%rax)
   10700:	48 83 c1 01          	add    $0x1,%rcx
   10704:	ee                   	out    %al,(%dx)
   10705:	0f b6 01             	movzbl (%rcx),%eax
   10708:	84 c0                	test   %al,%al
   1070a:	75 f4                	jne    10700 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x480>
   1070c:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   10711:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10716:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1071d:	00 00 00 
   10720:	4c 89 d0             	mov    %r10,%rax
   10723:	48 d3 e8             	shr    %cl,%rax
   10726:	83 e0 0f             	and    $0xf,%eax
   10729:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1072d:	ee                   	out    %al,(%dx)
   1072e:	83 e9 04             	sub    $0x4,%ecx
   10731:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10734:	75 ea                	jne    10720 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x4a0>
   10736:	b8 0d 00 00 00       	mov    $0xd,%eax
   1073b:	ee                   	out    %al,(%dx)
   1073c:	b8 0a 00 00 00       	mov    $0xa,%eax
   10741:	ee                   	out    %al,(%dx)
   10742:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10747:	48 8d 0d b2 38 00 00 	lea    0x38b2(%rip),%rcx        # 14000 <_data>
   1074e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10753:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1075a:	00 00 00 00 
   1075e:	66 90                	xchg   %ax,%ax
   10760:	48 83 c1 01          	add    $0x1,%rcx
   10764:	ee                   	out    %al,(%dx)
   10765:	0f b6 01             	movzbl (%rcx),%eax
   10768:	84 c0                	test   %al,%al
   1076a:	75 f4                	jne    10760 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x4e0>
   1076c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10771:	ee                   	out    %al,(%dx)
   10772:	b8 52 00 00 00       	mov    $0x52,%eax
   10777:	48 8d 0d 09 3b 00 00 	lea    0x3b09(%rip),%rcx        # 14287 <_data+0x287>
   1077e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10783:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1078a:	00 00 00 00 
   1078e:	66 90                	xchg   %ax,%ax
   10790:	48 83 c1 01          	add    $0x1,%rcx
   10794:	ee                   	out    %al,(%dx)
   10795:	0f b6 01             	movzbl (%rcx),%eax
   10798:	84 c0                	test   %al,%al
   1079a:	75 f4                	jne    10790 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x510>
   1079c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   107a1:	ee                   	out    %al,(%dx)
   107a2:	b8 20 00 00 00       	mov    $0x20,%eax
   107a7:	ee                   	out    %al,(%dx)
   107a8:	b8 68 00 00 00       	mov    $0x68,%eax
   107ad:	48 8d 0d 45 3b 00 00 	lea    0x3b45(%rip),%rcx        # 142f9 <_data+0x2f9>
   107b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   107b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   107c0:	48 83 c1 01          	add    $0x1,%rcx
   107c4:	ee                   	out    %al,(%dx)
   107c5:	0f b6 01             	movzbl (%rcx),%eax
   107c8:	84 c0                	test   %al,%al
   107ca:	75 f4                	jne    107c0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x540>
   107cc:	b8 3d 00 00 00       	mov    $0x3d,%eax
   107d1:	48 8d 0d ee 38 00 00 	lea    0x38ee(%rip),%rcx        # 140c6 <_data+0xc6>
   107d8:	ba f8 03 00 00       	mov    $0x3f8,%edx
   107dd:	0f 1f 00             	nopl   (%rax)
   107e0:	48 83 c1 01          	add    $0x1,%rcx
   107e4:	ee                   	out    %al,(%dx)
   107e5:	0f b6 01             	movzbl (%rcx),%eax
   107e8:	84 c0                	test   %al,%al
   107ea:	75 f4                	jne    107e0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x560>
   107ec:	b9 3c 00 00 00       	mov    $0x3c,%ecx
   107f1:	ba f8 03 00 00       	mov    $0x3f8,%edx
   107f6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   107fd:	00 00 00 
   10800:	4c 89 c8             	mov    %r9,%rax
   10803:	48 d3 e8             	shr    %cl,%rax
   10806:	83 e0 0f             	and    $0xf,%eax
   10809:	0f b6 04 06          	movzbl (%rsi,%rax,1),%eax
   1080d:	ee                   	out    %al,(%dx)
   1080e:	83 e9 04             	sub    $0x4,%ecx
   10811:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   10814:	75 ea                	jne    10800 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x580>
   10816:	44 8b 4f 0c          	mov    0xc(%rdi),%r9d
   1081a:	c7 47 10 00 00 00 00 	movl   $0x0,0x10(%rdi)
   10821:	4d 85 c9             	test   %r9,%r9
   10824:	0f 84 83 01 00 00    	je     109ad <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x72d>
   1082a:	48 89 fe             	mov    %rdi,%rsi
   1082d:	49 01 f9             	add    %rdi,%r9
   10830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   10835:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1083c:	00 00 00 00 
   10840:	0f b6 16             	movzbl (%rsi),%edx
   10843:	31 d0                	xor    %edx,%eax
   10845:	ba 08 00 00 00       	mov    $0x8,%edx
   1084a:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10851:	00 00 00 00 
   10855:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1085c:	00 00 00 00 
   10860:	89 c1                	mov    %eax,%ecx
   10862:	83 e0 01             	and    $0x1,%eax
   10865:	f7 d8                	neg    %eax
   10867:	d1 e9                	shr    $1,%ecx
   10869:	25 20 83 b8 ed       	and    $0xedb88320,%eax
   1086e:	31 c8                	xor    %ecx,%eax
   10870:	83 ea 01             	sub    $0x1,%edx
   10873:	75 eb                	jne    10860 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x5e0>
   10875:	48 83 c6 01          	add    $0x1,%rsi
   10879:	4c 39 ce             	cmp    %r9,%rsi
   1087c:	75 c2                	jne    10840 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x5c0>
   1087e:	f7 d0                	not    %eax
   10880:	89 47 10             	mov    %eax,0x10(%rdi)
   10883:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10888:	b8 0d 00 00 00       	mov    $0xd,%eax
   1088d:	41 c6 40 30 01       	movb   $0x1,0x30(%r8)
   10892:	83 0d 13 c9 00 00 08 	orl    $0x8,0xc913(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
   10899:	ee                   	out    %al,(%dx)
   1089a:	b8 0a 00 00 00       	mov    $0xa,%eax
   1089f:	ee                   	out    %al,(%dx)
   108a0:	b8 5b 00 00 00       	mov    $0x5b,%eax
   108a5:	48 8d 0d 54 37 00 00 	lea    0x3754(%rip),%rcx        # 14000 <_data>
   108ac:	0f 1f 40 00          	nopl   0x0(%rax)
   108b0:	48 83 c1 01          	add    $0x1,%rcx
   108b4:	ee                   	out    %al,(%dx)
   108b5:	0f b6 01             	movzbl (%rcx),%eax
   108b8:	84 c0                	test   %al,%al
   108ba:	75 f4                	jne    108b0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x630>
   108bc:	b8 5b 00 00 00       	mov    $0x5b,%eax
   108c1:	ee                   	out    %al,(%dx)
   108c2:	b8 52 00 00 00       	mov    $0x52,%eax
   108c7:	48 8d 0d b9 39 00 00 	lea    0x39b9(%rip),%rcx        # 14287 <_data+0x287>
   108ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
   108d3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   108da:	00 00 00 00 
   108de:	66 90                	xchg   %ax,%ax
   108e0:	48 83 c1 01          	add    $0x1,%rcx
   108e4:	ee                   	out    %al,(%dx)
   108e5:	0f b6 01             	movzbl (%rcx),%eax
   108e8:	84 c0                	test   %al,%al
   108ea:	75 f4                	jne    108e0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x660>
   108ec:	b8 5d 00 00 00       	mov    $0x5d,%eax
   108f1:	ee                   	out    %al,(%dx)
   108f2:	b8 20 00 00 00       	mov    $0x20,%eax
   108f7:	ee                   	out    %al,(%dx)
   108f8:	b8 6d 00 00 00       	mov    $0x6d,%eax
   108fd:	48 8d 0d d4 3e 00 00 	lea    0x3ed4(%rip),%rcx        # 147d8 <_data+0x7d8>
   10904:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10909:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10910:	48 83 c1 01          	add    $0x1,%rcx
   10914:	ee                   	out    %al,(%dx)
   10915:	0f b6 01             	movzbl (%rcx),%eax
   10918:	84 c0                	test   %al,%al
   1091a:	75 f4                	jne    10910 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x690>
   1091c:	b8 0d 00 00 00       	mov    $0xd,%eax
   10921:	ee                   	out    %al,(%dx)
   10922:	b8 0a 00 00 00       	mov    $0xa,%eax
   10927:	ee                   	out    %al,(%dx)
   10928:	b8 5b 00 00 00       	mov    $0x5b,%eax
   1092d:	48 8d 0d cc 36 00 00 	lea    0x36cc(%rip),%rcx        # 14000 <_data>
   10934:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10939:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10940:	48 83 c1 01          	add    $0x1,%rcx
   10944:	ee                   	out    %al,(%dx)
   10945:	0f b6 01             	movzbl (%rcx),%eax
   10948:	84 c0                	test   %al,%al
   1094a:	75 f4                	jne    10940 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x6c0>
   1094c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10951:	ee                   	out    %al,(%dx)
   10952:	b8 52 00 00 00       	mov    $0x52,%eax
   10957:	48 8d 0d 29 39 00 00 	lea    0x3929(%rip),%rcx        # 14287 <_data+0x287>
   1095e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10963:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1096a:	00 00 00 00 
   1096e:	66 90                	xchg   %ax,%ax
   10970:	48 83 c1 01          	add    $0x1,%rcx
   10974:	ee                   	out    %al,(%dx)
   10975:	0f b6 01             	movzbl (%rcx),%eax
   10978:	84 c0                	test   %al,%al
   1097a:	75 f4                	jne    10970 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x6f0>
   1097c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10981:	ee                   	out    %al,(%dx)
   10982:	b8 20 00 00 00       	mov    $0x20,%eax
   10987:	ee                   	out    %al,(%dx)
   10988:	b8 67 00 00 00       	mov    $0x67,%eax
   1098d:	48 8d 0d 84 3e 00 00 	lea    0x3e84(%rip),%rcx        # 14818 <_data+0x818>
   10994:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10999:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   109a0:	48 83 c1 01          	add    $0x1,%rcx
   109a4:	ee                   	out    %al,(%dx)
   109a5:	0f b6 01             	movzbl (%rcx),%eax
   109a8:	84 c0                	test   %al,%al
   109aa:	75 f4                	jne    109a0 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x720>
   109ac:	c3                   	ret
   109ad:	31 c0                	xor    %eax,%eax
   109af:	e9 cc fe ff ff       	jmp    10880 <_ZN10UEFIBridge11RuntimeHook12InstallEarlyEv+0x600>
   109b4:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   109bb:	00 00 00 
   109be:	66 90                	xchg   %ax,%ax

00000000000109c0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc>:
   109c0:	48 83 ec 28          	sub    $0x28,%rsp
   109c4:	8b 05 ce c7 00 00    	mov    0xc7ce(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   109ca:	41 89 f8             	mov    %edi,%r8d
   109cd:	8d 78 01             	lea    0x1(%rax),%edi
   109d0:	8b 05 b2 c7 00 00    	mov    0xc7b2(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   109d6:	89 3d bc c7 00 00    	mov    %edi,0xc7bc(%rip)        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   109dc:	85 c0                	test   %eax,%eax
   109de:	0f 84 94 01 00 00    	je     10b78 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1b8>
   109e4:	8b 35 c6 c7 00 00    	mov    0xc7c6(%rip),%esi        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
   109ea:	83 fe 04             	cmp    $0x4,%esi
   109ed:	74 0a                	je     109f9 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x39>
   109ef:	c7 05 b7 c7 00 00 04 	movl   $0x4,0xc7b7(%rip)        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
   109f6:	00 00 00 
   109f9:	83 ff 08             	cmp    $0x8,%edi
   109fc:	76 0a                	jbe    10a08 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x48>
   109fe:	40 f6 c7 3f          	test   $0x3f,%dil
   10a02:	0f 85 64 01 00 00    	jne    10b6c <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1ac>
   10a08:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10a0d:	b8 0d 00 00 00       	mov    $0xd,%eax
   10a12:	ee                   	out    %al,(%dx)
   10a13:	b8 0a 00 00 00       	mov    $0xa,%eax
   10a18:	ee                   	out    %al,(%dx)
   10a19:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10a1e:	48 8d 0d db 35 00 00 	lea    0x35db(%rip),%rcx        # 14000 <_data>
   10a25:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10a2c:	00 00 00 00 
   10a30:	48 83 c1 01          	add    $0x1,%rcx
   10a34:	ee                   	out    %al,(%dx)
   10a35:	0f b6 01             	movzbl (%rcx),%eax
   10a38:	84 c0                	test   %al,%al
   10a3a:	75 f4                	jne    10a30 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x70>
   10a3c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10a41:	ee                   	out    %al,(%dx)
   10a42:	b8 48 00 00 00       	mov    $0x48,%eax
   10a47:	48 8d 0d c0 38 00 00 	lea    0x38c0(%rip),%rcx        # 1430e <_data+0x30e>
   10a4e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10a53:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10a5a:	00 00 00 00 
   10a5e:	66 90                	xchg   %ax,%ax
   10a60:	48 83 c1 01          	add    $0x1,%rcx
   10a64:	ee                   	out    %al,(%dx)
   10a65:	0f b6 01             	movzbl (%rcx),%eax
   10a68:	84 c0                	test   %al,%al
   10a6a:	75 f4                	jne    10a60 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0xa0>
   10a6c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10a71:	ee                   	out    %al,(%dx)
   10a72:	b8 20 00 00 00       	mov    $0x20,%eax
   10a77:	ee                   	out    %al,(%dx)
   10a78:	44 89 c0             	mov    %r8d,%eax
   10a7b:	ee                   	out    %al,(%dx)
   10a7c:	b8 20 00 00 00       	mov    $0x20,%eax
   10a81:	48 8d 0d 94 38 00 00 	lea    0x3894(%rip),%rcx        # 1431c <_data+0x31c>
   10a88:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10a8d:	0f 1f 00             	nopl   (%rax)
   10a90:	48 83 c1 01          	add    $0x1,%rcx
   10a94:	ee                   	out    %al,(%dx)
   10a95:	0f b6 01             	movzbl (%rcx),%eax
   10a98:	84 c0                	test   %al,%al
   10a9a:	75 f4                	jne    10a90 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0xd0>
   10a9c:	c6 44 24 14 00       	movb   $0x0,0x14(%rsp)
   10aa1:	b9 13 00 00 00       	mov    $0x13,%ecx
   10aa6:	49 89 e0             	mov    %rsp,%r8
   10aa9:	49 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r10
   10ab0:	cc cc cc 
   10ab3:	48 85 ff             	test   %rdi,%rdi
   10ab6:	0f 84 fc 01 00 00    	je     10cb8 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x2f8>
   10abc:	0f 1f 40 00          	nopl   0x0(%rax)
   10ac0:	48 89 f8             	mov    %rdi,%rax
   10ac3:	49 89 cb             	mov    %rcx,%r11
   10ac6:	49 f7 e2             	mul    %r10
   10ac9:	48 89 f8             	mov    %rdi,%rax
   10acc:	48 c1 ea 03          	shr    $0x3,%rdx
   10ad0:	4c 8d 0c 92          	lea    (%rdx,%rdx,4),%r9
   10ad4:	4d 01 c9             	add    %r9,%r9
   10ad7:	4c 29 c8             	sub    %r9,%rax
   10ada:	49 89 f9             	mov    %rdi,%r9
   10add:	48 89 d7             	mov    %rdx,%rdi
   10ae0:	83 c0 30             	add    $0x30,%eax
   10ae3:	49 83 f9 09          	cmp    $0x9,%r9
   10ae7:	41 0f 97 c1          	seta   %r9b
   10aeb:	85 c9                	test   %ecx,%ecx
   10aed:	41 88 04 08          	mov    %al,(%r8,%rcx,1)
   10af1:	0f 95 c2             	setne  %dl
   10af4:	48 83 e9 01          	sub    $0x1,%rcx
   10af8:	41 84 d1             	test   %dl,%r9b
   10afb:	75 c3                	jne    10ac0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x100>
   10afd:	4d 63 db             	movslq %r11d,%r11
   10b00:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10b05:	4b 8d 0c 18          	lea    (%r8,%r11,1),%rcx
   10b09:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10b10:	48 83 c1 01          	add    $0x1,%rcx
   10b14:	ee                   	out    %al,(%dx)
   10b15:	0f b6 01             	movzbl (%rcx),%eax
   10b18:	84 c0                	test   %al,%al
   10b1a:	75 f4                	jne    10b10 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x150>
   10b1c:	b8 20 00 00 00       	mov    $0x20,%eax
   10b21:	48 8d 0d 02 38 00 00 	lea    0x3802(%rip),%rcx        # 1432a <_data+0x32a>
   10b28:	83 fe 04             	cmp    $0x4,%esi
   10b2b:	74 2b                	je     10b58 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x198>
   10b2d:	48 8d 0d ef 37 00 00 	lea    0x37ef(%rip),%rcx        # 14323 <_data+0x323>
   10b34:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10b39:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10b40:	48 83 c1 01          	add    $0x1,%rcx
   10b44:	ee                   	out    %al,(%dx)
   10b45:	0f b6 01             	movzbl (%rcx),%eax
   10b48:	84 c0                	test   %al,%al
   10b4a:	75 f4                	jne    10b40 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x180>
   10b4c:	b8 20 00 00 00       	mov    $0x20,%eax
   10b51:	48 8d 0d d2 37 00 00 	lea    0x37d2(%rip),%rcx        # 1432a <_data+0x32a>
   10b58:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10b5d:	0f 1f 00             	nopl   (%rax)
   10b60:	48 83 c1 01          	add    $0x1,%rcx
   10b64:	ee                   	out    %al,(%dx)
   10b65:	0f b6 01             	movzbl (%rcx),%eax
   10b68:	84 c0                	test   %al,%al
   10b6a:	75 f4                	jne    10b60 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1a0>
   10b6c:	48 83 c4 28          	add    $0x28,%rsp
   10b70:	c3                   	ret
   10b71:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10b78:	83 ff 08             	cmp    $0x8,%edi
   10b7b:	76 06                	jbe    10b83 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1c3>
   10b7d:	40 f6 c7 3f          	test   $0x3f,%dil
   10b81:	75 e9                	jne    10b6c <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1ac>
   10b83:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10b88:	b8 0d 00 00 00       	mov    $0xd,%eax
   10b8d:	ee                   	out    %al,(%dx)
   10b8e:	b8 0a 00 00 00       	mov    $0xa,%eax
   10b93:	ee                   	out    %al,(%dx)
   10b94:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10b99:	48 8d 0d 60 34 00 00 	lea    0x3460(%rip),%rcx        # 14000 <_data>
   10ba0:	48 83 c1 01          	add    $0x1,%rcx
   10ba4:	ee                   	out    %al,(%dx)
   10ba5:	0f b6 01             	movzbl (%rcx),%eax
   10ba8:	84 c0                	test   %al,%al
   10baa:	75 f4                	jne    10ba0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1e0>
   10bac:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10bb1:	ee                   	out    %al,(%dx)
   10bb2:	b8 48 00 00 00       	mov    $0x48,%eax
   10bb7:	48 8d 0d 50 37 00 00 	lea    0x3750(%rip),%rcx        # 1430e <_data+0x30e>
   10bbe:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10bc3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10bca:	00 00 00 00 
   10bce:	66 90                	xchg   %ax,%ax
   10bd0:	48 83 c1 01          	add    $0x1,%rcx
   10bd4:	ee                   	out    %al,(%dx)
   10bd5:	0f b6 01             	movzbl (%rcx),%eax
   10bd8:	84 c0                	test   %al,%al
   10bda:	75 f4                	jne    10bd0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x210>
   10bdc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10be1:	ee                   	out    %al,(%dx)
   10be2:	b8 20 00 00 00       	mov    $0x20,%eax
   10be7:	ee                   	out    %al,(%dx)
   10be8:	44 89 c0             	mov    %r8d,%eax
   10beb:	ee                   	out    %al,(%dx)
   10bec:	b8 20 00 00 00       	mov    $0x20,%eax
   10bf1:	48 8d 0d 1b 37 00 00 	lea    0x371b(%rip),%rcx        # 14313 <_data+0x313>
   10bf8:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10bfd:	0f 1f 00             	nopl   (%rax)
   10c00:	48 83 c1 01          	add    $0x1,%rcx
   10c04:	ee                   	out    %al,(%dx)
   10c05:	0f b6 01             	movzbl (%rcx),%eax
   10c08:	84 c0                	test   %al,%al
   10c0a:	75 f4                	jne    10c00 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x240>
   10c0c:	48 85 ff             	test   %rdi,%rdi
   10c0f:	0f 84 93 00 00 00    	je     10ca8 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x2e8>
   10c15:	c6 44 24 14 00       	movb   $0x0,0x14(%rsp)
   10c1a:	b9 13 00 00 00       	mov    $0x13,%ecx
   10c1f:	49 89 e0             	mov    %rsp,%r8
   10c22:	49 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%r10
   10c29:	cc cc cc 
   10c2c:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10c33:	00 00 00 00 
   10c37:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   10c3e:	00 00 
   10c40:	48 89 f8             	mov    %rdi,%rax
   10c43:	49 f7 e2             	mul    %r10
   10c46:	48 89 f8             	mov    %rdi,%rax
   10c49:	48 c1 ea 03          	shr    $0x3,%rdx
   10c4d:	48 8d 34 92          	lea    (%rdx,%rdx,4),%rsi
   10c51:	48 01 f6             	add    %rsi,%rsi
   10c54:	48 29 f0             	sub    %rsi,%rax
   10c57:	48 89 fe             	mov    %rdi,%rsi
   10c5a:	48 89 d7             	mov    %rdx,%rdi
   10c5d:	48 89 ca             	mov    %rcx,%rdx
   10c60:	83 c0 30             	add    $0x30,%eax
   10c63:	48 83 fe 09          	cmp    $0x9,%rsi
   10c67:	41 0f 97 c1          	seta   %r9b
   10c6b:	85 c9                	test   %ecx,%ecx
   10c6d:	41 88 04 08          	mov    %al,(%r8,%rcx,1)
   10c71:	40 0f 95 c6          	setne  %sil
   10c75:	48 83 e9 01          	sub    $0x1,%rcx
   10c79:	41 84 f1             	test   %sil,%r9b
   10c7c:	75 c2                	jne    10c40 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x280>
   10c7e:	48 63 ca             	movslq %edx,%rcx
   10c81:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10c86:	4c 01 c1             	add    %r8,%rcx
   10c89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10c90:	48 83 c1 01          	add    $0x1,%rcx
   10c94:	ee                   	out    %al,(%dx)
   10c95:	0f b6 01             	movzbl (%rcx),%eax
   10c98:	84 c0                	test   %al,%al
   10c9a:	75 f4                	jne    10c90 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x2d0>
   10c9c:	48 83 c4 28          	add    $0x28,%rsp
   10ca0:	c3                   	ret
   10ca1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   10ca8:	b8 30 00 00 00       	mov    $0x30,%eax
   10cad:	ee                   	out    %al,(%dx)
   10cae:	e9 b9 fe ff ff       	jmp    10b6c <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x1ac>
   10cb3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   10cb8:	b8 30 00 00 00       	mov    $0x30,%eax
   10cbd:	ee                   	out    %al,(%dx)
   10cbe:	e9 59 fe ff ff       	jmp    10b1c <_ZN10UEFIBridge11RuntimeHook9HookEnterEc+0x15c>
   10cc3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   10cca:	00 00 00 
   10ccd:	0f 1f 00             	nopl   (%rax)

0000000000010cd0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv>:
   10cd0:	41 57                	push   %r15
   10cd2:	41 56                	push   %r14
   10cd4:	41 55                	push   %r13
   10cd6:	45 89 c5             	mov    %r8d,%r13d
   10cd9:	41 54                	push   %r12
   10cdb:	4d 89 cc             	mov    %r9,%r12
   10cde:	55                   	push   %rbp
   10cdf:	48 89 d5             	mov    %rdx,%rbp
   10ce2:	57                   	push   %rdi
   10ce3:	56                   	push   %rsi
   10ce4:	53                   	push   %rbx
   10ce5:	48 89 cb             	mov    %rcx,%rbx
   10ce8:	48 81 ec 08 01 00 00 	sub    $0x108,%rsp
   10cef:	8b 05 8b c4 00 00    	mov    0xc48b(%rip),%eax        # 1d180 <_ZN10UEFIBridge11g_diag_busyE>
   10cf5:	4c 8b 3d 1c c0 00 00 	mov    0xc01c(%rip),%r15        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   10cfc:	4c 8b b4 24 70 01 00 	mov    0x170(%rsp),%r14
   10d03:	00 
   10d04:	0f 29 74 24 60       	movaps %xmm6,0x60(%rsp)
   10d09:	0f 29 7c 24 70       	movaps %xmm7,0x70(%rsp)
   10d0e:	44 0f 29 84 24 80 00 	movaps %xmm8,0x80(%rsp)
   10d15:	00 00 
   10d17:	44 0f 29 8c 24 90 00 	movaps %xmm9,0x90(%rsp)
   10d1e:	00 00 
   10d20:	44 0f 29 94 24 a0 00 	movaps %xmm10,0xa0(%rsp)
   10d27:	00 00 
   10d29:	44 0f 29 9c 24 b0 00 	movaps %xmm11,0xb0(%rsp)
   10d30:	00 00 
   10d32:	44 0f 29 a4 24 c0 00 	movaps %xmm12,0xc0(%rsp)
   10d39:	00 00 
   10d3b:	44 0f 29 ac 24 d0 00 	movaps %xmm13,0xd0(%rsp)
   10d42:	00 00 
   10d44:	44 0f 29 b4 24 e0 00 	movaps %xmm14,0xe0(%rsp)
   10d4b:	00 00 
   10d4d:	44 0f 29 bc 24 f0 00 	movaps %xmm15,0xf0(%rsp)
   10d54:	00 00 
   10d56:	85 c0                	test   %eax,%eax
   10d58:	0f 84 8a 00 00 00    	je     10de8 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x118>
   10d5e:	4d 85 ff             	test   %r15,%r15
   10d61:	0f 84 46 03 00 00    	je     110ad <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3dd>
   10d67:	49 8b 47 18          	mov    0x18(%r15),%rax
   10d6b:	48 85 c0             	test   %rax,%rax
   10d6e:	0f 84 39 03 00 00    	je     110ad <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3dd>
   10d74:	4c 89 b4 24 70 01 00 	mov    %r14,0x170(%rsp)
   10d7b:	00 
   10d7c:	0f 28 74 24 60       	movaps 0x60(%rsp),%xmm6
   10d81:	44 0f 28 84 24 80 00 	movaps 0x80(%rsp),%xmm8
   10d88:	00 00 
   10d8a:	0f 28 7c 24 70       	movaps 0x70(%rsp),%xmm7
   10d8f:	44 0f 28 8c 24 90 00 	movaps 0x90(%rsp),%xmm9
   10d96:	00 00 
   10d98:	44 0f 28 94 24 a0 00 	movaps 0xa0(%rsp),%xmm10
   10d9f:	00 00 
   10da1:	44 0f 28 9c 24 b0 00 	movaps 0xb0(%rsp),%xmm11
   10da8:	00 00 
   10daa:	44 0f 28 a4 24 c0 00 	movaps 0xc0(%rsp),%xmm12
   10db1:	00 00 
   10db3:	44 0f 28 ac 24 d0 00 	movaps 0xd0(%rsp),%xmm13
   10dba:	00 00 
   10dbc:	44 0f 28 b4 24 e0 00 	movaps 0xe0(%rsp),%xmm14
   10dc3:	00 00 
   10dc5:	44 0f 28 bc 24 f0 00 	movaps 0xf0(%rsp),%xmm15
   10dcc:	00 00 
   10dce:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
   10dd5:	5b                   	pop    %rbx
   10dd6:	5e                   	pop    %rsi
   10dd7:	5f                   	pop    %rdi
   10dd8:	5d                   	pop    %rbp
   10dd9:	41 5c                	pop    %r12
   10ddb:	41 5d                	pop    %r13
   10ddd:	41 5e                	pop    %r14
   10ddf:	41 5f                	pop    %r15
   10de1:	ff e0                	jmp    *%rax
   10de3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   10de8:	bf 53 00 00 00       	mov    $0x53,%edi
   10ded:	e8 ce fb ff ff       	call   109c0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc>
   10df2:	4d 85 ff             	test   %r15,%r15
   10df5:	0f 84 95 02 00 00    	je     11090 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3c0>
   10dfb:	48 85 db             	test   %rbx,%rbx
   10dfe:	0f 84 53 03 00 00    	je     11157 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x487>
   10e04:	48 85 ed             	test   %rbp,%rbp
   10e07:	74 18                	je     10e21 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x151>
   10e09:	48 8d 35 70 50 00 00 	lea    0x5070(%rip),%rsi        # 15e80 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid>
   10e10:	48 89 ef             	mov    %rbp,%rdi
   10e13:	e8 78 5a ff ff       	call   6890 <CompareGuid>
   10e18:	48 85 c0             	test   %rax,%rax
   10e1b:	0f 85 2f 03 00 00    	jne    11150 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x480>
   10e21:	4c 8d 3d 5a 3a 00 00 	lea    0x3a5a(%rip),%r15        # 14882 <_data+0x882>
   10e28:	48 89 df             	mov    %rbx,%rdi
   10e2b:	4c 89 fe             	mov    %r15,%rsi
   10e2e:	e8 6d 88 ff ff       	call   96a0 <StrCmp>
   10e33:	48 85 c0             	test   %rax,%rax
   10e36:	74 18                	je     10e50 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x180>
   10e38:	48 8d 35 5b 3a 00 00 	lea    0x3a5b(%rip),%rsi        # 1489a <_data+0x89a>
   10e3f:	48 89 df             	mov    %rbx,%rdi
   10e42:	e8 59 88 ff ff       	call   96a0 <StrCmp>
   10e47:	48 85 c0             	test   %rax,%rax
   10e4a:	0f 85 d0 02 00 00    	jne    11120 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x450>
   10e50:	4d 85 f6             	test   %r14,%r14
   10e53:	4c 8d 05 e5 34 00 00 	lea    0x34e5(%rip),%r8        # 1433f <_data+0x33f>
   10e5a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10e5f:	41 0f 95 c1          	setne  %r9b
   10e63:	4d 85 e4             	test   %r12,%r12
   10e66:	0f 95 c0             	setne  %al
   10e69:	41 20 c1             	and    %al,%r9b
   10e6c:	48 8d 05 bd 34 00 00 	lea    0x34bd(%rip),%rax        # 14330 <_data+0x330>
   10e73:	4c 0f 45 c0          	cmovne %rax,%r8
   10e77:	b8 0d 00 00 00       	mov    $0xd,%eax
   10e7c:	ee                   	out    %al,(%dx)
   10e7d:	b8 0a 00 00 00       	mov    $0xa,%eax
   10e82:	ee                   	out    %al,(%dx)
   10e83:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10e88:	48 8d 0d 71 31 00 00 	lea    0x3171(%rip),%rcx        # 14000 <_data>
   10e8f:	90                   	nop
   10e90:	48 83 c1 01          	add    $0x1,%rcx
   10e94:	ee                   	out    %al,(%dx)
   10e95:	0f b6 01             	movzbl (%rcx),%eax
   10e98:	84 c0                	test   %al,%al
   10e9a:	75 f4                	jne    10e90 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x1c0>
   10e9c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10ea1:	ee                   	out    %al,(%dx)
   10ea2:	b8 48 00 00 00       	mov    $0x48,%eax
   10ea7:	48 8d 0d 60 34 00 00 	lea    0x3460(%rip),%rcx        # 1430e <_data+0x30e>
   10eae:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10eb3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10eba:	00 00 00 00 
   10ebe:	66 90                	xchg   %ax,%ax
   10ec0:	48 83 c1 01          	add    $0x1,%rcx
   10ec4:	ee                   	out    %al,(%dx)
   10ec5:	0f b6 01             	movzbl (%rcx),%eax
   10ec8:	84 c0                	test   %al,%al
   10eca:	75 f4                	jne    10ec0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x1f0>
   10ecc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   10ed1:	ee                   	out    %al,(%dx)
   10ed2:	b8 20 00 00 00       	mov    $0x20,%eax
   10ed7:	ee                   	out    %al,(%dx)
   10ed8:	41 0f b6 00          	movzbl (%r8),%eax
   10edc:	84 c0                	test   %al,%al
   10ede:	74 1d                	je     10efd <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x22d>
   10ee0:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10ee5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   10eec:	00 00 00 00 
   10ef0:	49 83 c0 01          	add    $0x1,%r8
   10ef4:	ee                   	out    %al,(%dx)
   10ef5:	41 0f b6 00          	movzbl (%r8),%eax
   10ef9:	84 c0                	test   %al,%al
   10efb:	75 f3                	jne    10ef0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x220>
   10efd:	45 84 c9             	test   %r9b,%r9b
   10f00:	74 18                	je     10f1a <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x24a>
   10f02:	8b 05 80 c2 00 00    	mov    0xc280(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   10f08:	83 0d 9d c2 00 00 20 	orl    $0x20,0xc29d(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
   10f0f:	85 c0                	test   %eax,%eax
   10f11:	74 07                	je     10f1a <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x24a>
   10f13:	83 05 76 c2 00 00 01 	addl   $0x1,0xc276(%rip)        # 1d190 <_ZN10UEFIBridge16g_diag_req_countE>
   10f1a:	48 8b 05 f7 bd 00 00 	mov    0xbdf7(%rip),%rax        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   10f21:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
   10f26:	e8 15 31 ff ff       	call   4040 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv>
   10f2b:	4c 89 fe             	mov    %r15,%rsi
   10f2e:	48 89 df             	mov    %rbx,%rdi
   10f31:	e8 6a 87 ff ff       	call   96a0 <StrCmp>
   10f36:	48 85 c0             	test   %rax,%rax
   10f39:	0f 85 41 05 00 00    	jne    11480 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x7b0>
   10f3f:	4d 85 f6             	test   %r14,%r14
   10f42:	0f 84 18 05 00 00    	je     11460 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x790>
   10f48:	49 83 fc 2f          	cmp    $0x2f,%r12
   10f4c:	0f 86 0e 05 00 00    	jbe    11460 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x790>
   10f52:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
   10f57:	48 8b 38             	mov    (%rax),%rdi
   10f5a:	48 85 ff             	test   %rdi,%rdi
   10f5d:	74 1a                	je     10f79 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2a9>
   10f5f:	48 8d 88 80 00 00 00 	lea    0x80(%rax),%rcx
   10f66:	48 8d 50 32          	lea    0x32(%rax),%rdx
   10f6a:	4c 89 f6             	mov    %r14,%rsi
   10f6d:	4c 8d 80 80 10 00 00 	lea    0x1080(%rax),%r8
   10f74:	e8 e7 d9 ff ff       	call   e960 <_ZN10UEFIBridge14RequestHandler28ProcessSingleVariableRequestEPKvPvS3_Pm>
   10f79:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
   10f7e:	48 c7 40 78 20 00 00 	movq   $0x20,0x78(%rax)
   10f85:	00 
   10f86:	45 31 c0             	xor    %r8d,%r8d
   10f89:	48 8b 05 88 bd 00 00 	mov    0xbd88(%rip),%rax        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   10f90:	48 8b 40 18          	mov    0x18(%rax),%rax
   10f94:	48 85 c0             	test   %rax,%rax
   10f97:	0f 84 3b 05 00 00    	je     114d8 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x808>
   10f9d:	45 89 e8             	mov    %r13d,%r8d
   10fa0:	4c 89 74 24 20       	mov    %r14,0x20(%rsp)
   10fa5:	4d 89 e1             	mov    %r12,%r9
   10fa8:	48 89 ea             	mov    %rbp,%rdx
   10fab:	48 89 d9             	mov    %rbx,%rcx
   10fae:	ff d0                	call   *%rax
   10fb0:	49 89 c0             	mov    %rax,%r8
   10fb3:	8b 05 cf c1 00 00    	mov    0xc1cf(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   10fb9:	85 c0                	test   %eax,%eax
   10fbb:	0f 84 af 04 00 00    	je     11470 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x7a0>
   10fc1:	8b 05 d1 c1 00 00    	mov    0xc1d1(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   10fc7:	83 f8 08             	cmp    $0x8,%eax
   10fca:	0f 87 e7 00 00 00    	ja     110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   10fd0:	ba f8 03 00 00       	mov    $0x3f8,%edx
   10fd5:	b8 0d 00 00 00       	mov    $0xd,%eax
   10fda:	ee                   	out    %al,(%dx)
   10fdb:	b8 0a 00 00 00       	mov    $0xa,%eax
   10fe0:	ee                   	out    %al,(%dx)
   10fe1:	b8 5b 00 00 00       	mov    $0x5b,%eax
   10fe6:	48 8d 0d 13 30 00 00 	lea    0x3013(%rip),%rcx        # 14000 <_data>
   10fed:	0f 1f 00             	nopl   (%rax)
   10ff0:	48 83 c1 01          	add    $0x1,%rcx
   10ff4:	ee                   	out    %al,(%dx)
   10ff5:	0f b6 01             	movzbl (%rcx),%eax
   10ff8:	84 c0                	test   %al,%al
   10ffa:	75 f4                	jne    10ff0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x320>
   10ffc:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11001:	ee                   	out    %al,(%dx)
   11002:	b8 48 00 00 00       	mov    $0x48,%eax
   11007:	48 8d 0d 00 33 00 00 	lea    0x3300(%rip),%rcx        # 1430e <_data+0x30e>
   1100e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11013:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1101a:	00 00 00 00 
   1101e:	66 90                	xchg   %ax,%ax
   11020:	48 83 c1 01          	add    $0x1,%rcx
   11024:	ee                   	out    %al,(%dx)
   11025:	0f b6 01             	movzbl (%rcx),%eax
   11028:	84 c0                	test   %al,%al
   1102a:	75 f4                	jne    11020 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x350>
   1102c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11031:	ee                   	out    %al,(%dx)
   11032:	b8 20 00 00 00       	mov    $0x20,%eax
   11037:	ee                   	out    %al,(%dx)
   11038:	b8 53 00 00 00       	mov    $0x53,%eax
   1103d:	ee                   	out    %al,(%dx)
   1103e:	b8 20 00 00 00       	mov    $0x20,%eax
   11043:	48 8d 0d 05 33 00 00 	lea    0x3305(%rip),%rcx        # 1434f <_data+0x34f>
   1104a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1104f:	90                   	nop
   11050:	48 83 c1 01          	add    $0x1,%rcx
   11054:	ee                   	out    %al,(%dx)
   11055:	0f b6 01             	movzbl (%rcx),%eax
   11058:	84 c0                	test   %al,%al
   1105a:	75 f4                	jne    11050 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x380>
   1105c:	45 89 c2             	mov    %r8d,%r10d
   1105f:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   11064:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11069:	4c 8d 0d 70 3d 00 00 	lea    0x3d70(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11070:	44 89 d0             	mov    %r10d,%eax
   11073:	d3 e8                	shr    %cl,%eax
   11075:	83 e0 0f             	and    $0xf,%eax
   11078:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   1107d:	ee                   	out    %al,(%dx)
   1107e:	83 e9 04             	sub    $0x4,%ecx
   11081:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11084:	75 ea                	jne    11070 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3a0>
   11086:	eb 2f                	jmp    110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   11088:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   1108f:	00 
   11090:	8b 05 f2 c0 00 00    	mov    0xc0f2(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   11096:	85 c0                	test   %eax,%eax
   11098:	0f 84 b2 02 00 00    	je     11350 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x680>
   1109e:	8b 05 f4 c0 00 00    	mov    0xc0f4(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   110a4:	83 f8 08             	cmp    $0x8,%eax
   110a7:	0f 86 b3 02 00 00    	jbe    11360 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x690>
   110ad:	49 b8 03 00 00 00 00 	movabs $0x8000000000000003,%r8
   110b4:	00 00 80 
   110b7:	0f 28 74 24 60       	movaps 0x60(%rsp),%xmm6
   110bc:	0f 28 7c 24 70       	movaps 0x70(%rsp),%xmm7
   110c1:	4c 89 c0             	mov    %r8,%rax
   110c4:	44 0f 28 84 24 80 00 	movaps 0x80(%rsp),%xmm8
   110cb:	00 00 
   110cd:	44 0f 28 8c 24 90 00 	movaps 0x90(%rsp),%xmm9
   110d4:	00 00 
   110d6:	44 0f 28 94 24 a0 00 	movaps 0xa0(%rsp),%xmm10
   110dd:	00 00 
   110df:	44 0f 28 9c 24 b0 00 	movaps 0xb0(%rsp),%xmm11
   110e6:	00 00 
   110e8:	44 0f 28 a4 24 c0 00 	movaps 0xc0(%rsp),%xmm12
   110ef:	00 00 
   110f1:	44 0f 28 ac 24 d0 00 	movaps 0xd0(%rsp),%xmm13
   110f8:	00 00 
   110fa:	44 0f 28 b4 24 e0 00 	movaps 0xe0(%rsp),%xmm14
   11101:	00 00 
   11103:	44 0f 28 bc 24 f0 00 	movaps 0xf0(%rsp),%xmm15
   1110a:	00 00 
   1110c:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
   11113:	5b                   	pop    %rbx
   11114:	5e                   	pop    %rsi
   11115:	5f                   	pop    %rdi
   11116:	5d                   	pop    %rbp
   11117:	41 5c                	pop    %r12
   11119:	41 5d                	pop    %r13
   1111b:	41 5e                	pop    %r14
   1111d:	41 5f                	pop    %r15
   1111f:	c3                   	ret
   11120:	48 8d 35 8d 37 00 00 	lea    0x378d(%rip),%rsi        # 148b4 <_data+0x8b4>
   11127:	48 89 df             	mov    %rbx,%rdi
   1112a:	e8 71 85 ff ff       	call   96a0 <StrCmp>
   1112f:	48 85 c0             	test   %rax,%rax
   11132:	0f 84 18 fd ff ff    	je     10e50 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x180>
   11138:	48 8d 35 8f 37 00 00 	lea    0x378f(%rip),%rsi        # 148ce <_data+0x8ce>
   1113f:	48 89 df             	mov    %rbx,%rdi
   11142:	e8 59 85 ff ff       	call   96a0 <StrCmp>
   11147:	48 85 c0             	test   %rax,%rax
   1114a:	0f 84 00 fd ff ff    	je     10e50 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x180>
   11150:	4c 8b 3d c1 bb 00 00 	mov    0xbbc1(%rip),%r15        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   11157:	4d 85 ff             	test   %r15,%r15
   1115a:	0f 84 30 ff ff ff    	je     11090 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3c0>
   11160:	4d 8b 0f             	mov    (%r15),%r9
   11163:	4d 85 c9             	test   %r9,%r9
   11166:	0f 84 d4 00 00 00    	je     11240 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x570>
   1116c:	41 80 7f 31 00       	cmpb   $0x0,0x31(%r15)
   11171:	0f 85 c9 00 00 00    	jne    11240 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x570>
   11177:	41 c6 47 31 01       	movb   $0x1,0x31(%r15)
   1117c:	49 8b 09             	mov    (%r9),%rcx
   1117f:	4c 89 fa             	mov    %r15,%rdx
   11182:	48 85 c9             	test   %rcx,%rcx
   11185:	0f 84 ad 00 00 00    	je     11238 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x568>
   1118b:	49 83 79 08 00       	cmpq   $0x0,0x8(%r9)
   11190:	0f 84 a2 00 00 00    	je     11238 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x568>
   11196:	4c 8b 41 10          	mov    0x10(%rcx),%r8
   1119a:	49 8b 11             	mov    (%r9),%rdx
   1119d:	45 8b 50 10          	mov    0x10(%r8),%r10d
   111a1:	41 8b 48 14          	mov    0x14(%r8),%ecx
   111a5:	48 8b 12             	mov    (%rdx),%rdx
   111a8:	48 8d 82 00 04 00 00 	lea    0x400(%rdx),%rax
   111af:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
   111b4:	48 8d 82 00 14 00 00 	lea    0x1400(%rdx),%rax
   111bb:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
   111c0:	41 39 ca             	cmp    %ecx,%r10d
   111c3:	74 60                	je     11225 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x555>
   111c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   111cc:	00 00 00 00 
   111d0:	89 ce                	mov    %ecx,%esi
   111d2:	48 8b 44 24 50       	mov    0x50(%rsp),%rax
   111d7:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
   111dc:	4c 89 cf             	mov    %r9,%rdi
   111df:	48 c1 e6 06          	shl    $0x6,%rsi
   111e3:	4c 89 44 24 48       	mov    %r8,0x48(%rsp)
   111e8:	48 01 c6             	add    %rax,%rsi
   111eb:	89 4c 24 44          	mov    %ecx,0x44(%rsp)
   111ef:	4c 89 4c 24 38       	mov    %r9,0x38(%rsp)
   111f4:	e8 27 eb ff ff       	call   fd20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot>
   111f9:	8b 4c 24 44          	mov    0x44(%rsp),%ecx
   111fd:	4c 8b 44 24 48       	mov    0x48(%rsp),%r8
   11202:	83 c1 01             	add    $0x1,%ecx
   11205:	83 e1 3f             	and    $0x3f,%ecx
   11208:	41 89 48 14          	mov    %ecx,0x14(%r8)
   1120c:	49 8b 50 28          	mov    0x28(%r8),%rdx
   11210:	48 83 c2 01          	add    $0x1,%rdx
   11214:	49 89 50 28          	mov    %rdx,0x28(%r8)
   11218:	41 8b 50 10          	mov    0x10(%r8),%edx
   1121c:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
   11221:	39 d1                	cmp    %edx,%ecx
   11223:	75 ab                	jne    111d0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x500>
   11225:	49 8b 50 20          	mov    0x20(%r8),%rdx
   11229:	48 83 c2 01          	add    $0x1,%rdx
   1122d:	49 89 50 20          	mov    %rdx,0x20(%r8)
   11231:	48 8b 15 e0 ba 00 00 	mov    0xbae0(%rip),%rdx        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   11238:	41 c6 47 31 00       	movb   $0x0,0x31(%r15)
   1123d:	49 89 d7             	mov    %rdx,%r15
   11240:	49 8b 47 18          	mov    0x18(%r15),%rax
   11244:	48 85 c0             	test   %rax,%rax
   11247:	0f 84 43 fe ff ff    	je     11090 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3c0>
   1124d:	45 89 e8             	mov    %r13d,%r8d
   11250:	4c 89 74 24 20       	mov    %r14,0x20(%rsp)
   11255:	4d 89 e1             	mov    %r12,%r9
   11258:	48 89 ea             	mov    %rbp,%rdx
   1125b:	48 89 d9             	mov    %rbx,%rcx
   1125e:	ff d0                	call   *%rax
   11260:	49 89 c0             	mov    %rax,%r8
   11263:	8b 05 1f bf 00 00    	mov    0xbf1f(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   11269:	85 c0                	test   %eax,%eax
   1126b:	0f 84 cf 00 00 00    	je     11340 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x670>
   11271:	8b 05 21 bf 00 00    	mov    0xbf21(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   11277:	83 f8 08             	cmp    $0x8,%eax
   1127a:	0f 87 37 fe ff ff    	ja     110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   11280:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11285:	b8 0d 00 00 00       	mov    $0xd,%eax
   1128a:	ee                   	out    %al,(%dx)
   1128b:	b8 0a 00 00 00       	mov    $0xa,%eax
   11290:	ee                   	out    %al,(%dx)
   11291:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11296:	48 8d 0d 63 2d 00 00 	lea    0x2d63(%rip),%rcx        # 14000 <_data>
   1129d:	0f 1f 00             	nopl   (%rax)
   112a0:	48 83 c1 01          	add    $0x1,%rcx
   112a4:	ee                   	out    %al,(%dx)
   112a5:	0f b6 01             	movzbl (%rcx),%eax
   112a8:	84 c0                	test   %al,%al
   112aa:	75 f4                	jne    112a0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x5d0>
   112ac:	b8 5b 00 00 00       	mov    $0x5b,%eax
   112b1:	ee                   	out    %al,(%dx)
   112b2:	b8 48 00 00 00       	mov    $0x48,%eax
   112b7:	48 8d 0d 50 30 00 00 	lea    0x3050(%rip),%rcx        # 1430e <_data+0x30e>
   112be:	ba f8 03 00 00       	mov    $0x3f8,%edx
   112c3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   112ca:	00 00 00 00 
   112ce:	66 90                	xchg   %ax,%ax
   112d0:	48 83 c1 01          	add    $0x1,%rcx
   112d4:	ee                   	out    %al,(%dx)
   112d5:	0f b6 01             	movzbl (%rcx),%eax
   112d8:	84 c0                	test   %al,%al
   112da:	75 f4                	jne    112d0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x600>
   112dc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   112e1:	ee                   	out    %al,(%dx)
   112e2:	b8 20 00 00 00       	mov    $0x20,%eax
   112e7:	ee                   	out    %al,(%dx)
   112e8:	b8 53 00 00 00       	mov    $0x53,%eax
   112ed:	ee                   	out    %al,(%dx)
   112ee:	b8 20 00 00 00       	mov    $0x20,%eax
   112f3:	48 8d 0d 55 30 00 00 	lea    0x3055(%rip),%rcx        # 1434f <_data+0x34f>
   112fa:	ba f8 03 00 00       	mov    $0x3f8,%edx
   112ff:	90                   	nop
   11300:	48 83 c1 01          	add    $0x1,%rcx
   11304:	ee                   	out    %al,(%dx)
   11305:	0f b6 01             	movzbl (%rcx),%eax
   11308:	84 c0                	test   %al,%al
   1130a:	75 f4                	jne    11300 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x630>
   1130c:	45 89 c2             	mov    %r8d,%r10d
   1130f:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   11314:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11319:	4c 8d 0d c0 3a 00 00 	lea    0x3ac0(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11320:	44 89 d0             	mov    %r10d,%eax
   11323:	d3 e8                	shr    %cl,%eax
   11325:	83 e0 0f             	and    $0xf,%eax
   11328:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   1132d:	ee                   	out    %al,(%dx)
   1132e:	83 e9 04             	sub    $0x4,%ecx
   11331:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11334:	75 ea                	jne    11320 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x650>
   11336:	e9 7c fd ff ff       	jmp    110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   1133b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11340:	8b 05 3e be 00 00    	mov    0xbe3e(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11346:	e9 2c ff ff ff       	jmp    11277 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x5a7>
   1134b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11350:	8b 05 2e be 00 00    	mov    0xbe2e(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11356:	e9 49 fd ff ff       	jmp    110a4 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3d4>
   1135b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11360:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11365:	b8 0d 00 00 00       	mov    $0xd,%eax
   1136a:	ee                   	out    %al,(%dx)
   1136b:	b8 0a 00 00 00       	mov    $0xa,%eax
   11370:	ee                   	out    %al,(%dx)
   11371:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11376:	48 8d 0d 83 2c 00 00 	lea    0x2c83(%rip),%rcx        # 14000 <_data>
   1137d:	0f 1f 00             	nopl   (%rax)
   11380:	48 83 c1 01          	add    $0x1,%rcx
   11384:	ee                   	out    %al,(%dx)
   11385:	0f b6 01             	movzbl (%rcx),%eax
   11388:	84 c0                	test   %al,%al
   1138a:	75 f4                	jne    11380 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x6b0>
   1138c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11391:	ee                   	out    %al,(%dx)
   11392:	b8 48 00 00 00       	mov    $0x48,%eax
   11397:	48 8d 0d 70 2f 00 00 	lea    0x2f70(%rip),%rcx        # 1430e <_data+0x30e>
   1139e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   113a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   113aa:	00 00 00 00 
   113ae:	66 90                	xchg   %ax,%ax
   113b0:	48 83 c1 01          	add    $0x1,%rcx
   113b4:	ee                   	out    %al,(%dx)
   113b5:	0f b6 01             	movzbl (%rcx),%eax
   113b8:	84 c0                	test   %al,%al
   113ba:	75 f4                	jne    113b0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x6e0>
   113bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   113c1:	ee                   	out    %al,(%dx)
   113c2:	b8 20 00 00 00       	mov    $0x20,%eax
   113c7:	ee                   	out    %al,(%dx)
   113c8:	b8 53 00 00 00       	mov    $0x53,%eax
   113cd:	ee                   	out    %al,(%dx)
   113ce:	b8 20 00 00 00       	mov    $0x20,%eax
   113d3:	48 8d 0d 75 2f 00 00 	lea    0x2f75(%rip),%rcx        # 1434f <_data+0x34f>
   113da:	ba f8 03 00 00       	mov    $0x3f8,%edx
   113df:	90                   	nop
   113e0:	48 83 c1 01          	add    $0x1,%rcx
   113e4:	ee                   	out    %al,(%dx)
   113e5:	0f b6 01             	movzbl (%rcx),%eax
   113e8:	84 c0                	test   %al,%al
   113ea:	75 f4                	jne    113e0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x710>
   113ec:	b8 30 00 00 00       	mov    $0x30,%eax
   113f1:	ee                   	out    %al,(%dx)
   113f2:	b9 18 00 00 00       	mov    $0x18,%ecx
   113f7:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   113fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11402:	4c 8d 0d d7 39 00 00 	lea    0x39d7(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11409:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   11410:	44 89 c0             	mov    %r8d,%eax
   11413:	d3 e8                	shr    %cl,%eax
   11415:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   1141a:	ee                   	out    %al,(%dx)
   1141b:	83 e9 04             	sub    $0x4,%ecx
   1141e:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11421:	75 ed                	jne    11410 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x740>
   11423:	e9 85 fc ff ff       	jmp    110ad <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3dd>
   11428:	48 8d 35 9f 34 00 00 	lea    0x349f(%rip),%rsi        # 148ce <_data+0x8ce>
   1142f:	48 89 df             	mov    %rbx,%rdi
   11432:	e8 69 82 ff ff       	call   96a0 <StrCmp>
   11437:	49 b8 0e 00 00 00 00 	movabs $0x800000000000000e,%r8
   1143e:	00 00 80 
   11441:	48 85 c0             	test   %rax,%rax
   11444:	0f 85 3f fb ff ff    	jne    10f89 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2b9>
   1144a:	4d 85 f6             	test   %r14,%r14
   1144d:	74 11                	je     11460 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x790>
   1144f:	4d 85 e4             	test   %r12,%r12
   11452:	0f 85 2e fb ff ff    	jne    10f86 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2b6>
   11458:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   1145f:	00 
   11460:	49 b8 02 00 00 00 00 	movabs $0x8000000000000002,%r8
   11467:	00 00 80 
   1146a:	e9 1a fb ff ff       	jmp    10f89 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2b9>
   1146f:	90                   	nop
   11470:	8b 05 0e bd 00 00    	mov    0xbd0e(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11476:	e9 4c fb ff ff       	jmp    10fc7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2f7>
   1147b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11480:	48 8d 35 2d 34 00 00 	lea    0x342d(%rip),%rsi        # 148b4 <_data+0x8b4>
   11487:	48 89 df             	mov    %rbx,%rdi
   1148a:	e8 11 82 ff ff       	call   96a0 <StrCmp>
   1148f:	48 85 c0             	test   %rax,%rax
   11492:	75 94                	jne    11428 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x758>
   11494:	4d 85 f6             	test   %r14,%r14
   11497:	74 c7                	je     11460 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x790>
   11499:	49 b8 04 00 00 00 00 	movabs $0x8000000000000004,%r8
   114a0:	00 00 80 
   114a3:	49 81 fc 00 10 00 00 	cmp    $0x1000,%r12
   114aa:	0f 87 d9 fa ff ff    	ja     10f89 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2b9>
   114b0:	4c 8b 7c 24 38       	mov    0x38(%rsp),%r15
   114b5:	4c 89 e2             	mov    %r12,%rdx
   114b8:	4c 89 f6             	mov    %r14,%rsi
   114bb:	49 8d bf 80 00 00 00 	lea    0x80(%r15),%rdi
   114c2:	e8 b9 58 ff ff       	call   6d80 <CopyMem>
   114c7:	4d 89 a7 80 10 00 00 	mov    %r12,0x1080(%r15)
   114ce:	e9 b3 fa ff ff       	jmp    10f86 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x2b6>
   114d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   114d8:	8b 05 aa bc 00 00    	mov    0xbcaa(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   114de:	85 c0                	test   %eax,%eax
   114e0:	0f 84 d2 00 00 00    	je     115b8 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x8e8>
   114e6:	8b 05 ac bc 00 00    	mov    0xbcac(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   114ec:	83 f8 08             	cmp    $0x8,%eax
   114ef:	0f 87 c2 fb ff ff    	ja     110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   114f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
   114fa:	b8 0d 00 00 00       	mov    $0xd,%eax
   114ff:	ee                   	out    %al,(%dx)
   11500:	b8 0a 00 00 00       	mov    $0xa,%eax
   11505:	ee                   	out    %al,(%dx)
   11506:	b8 5b 00 00 00       	mov    $0x5b,%eax
   1150b:	48 8d 0d ee 2a 00 00 	lea    0x2aee(%rip),%rcx        # 14000 <_data>
   11512:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11519:	00 00 00 00 
   1151d:	0f 1f 00             	nopl   (%rax)
   11520:	48 83 c1 01          	add    $0x1,%rcx
   11524:	ee                   	out    %al,(%dx)
   11525:	0f b6 01             	movzbl (%rcx),%eax
   11528:	84 c0                	test   %al,%al
   1152a:	75 f4                	jne    11520 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x850>
   1152c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11531:	ee                   	out    %al,(%dx)
   11532:	b8 48 00 00 00       	mov    $0x48,%eax
   11537:	48 8d 0d d0 2d 00 00 	lea    0x2dd0(%rip),%rcx        # 1430e <_data+0x30e>
   1153e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11543:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1154a:	00 00 00 00 
   1154e:	66 90                	xchg   %ax,%ax
   11550:	48 83 c1 01          	add    $0x1,%rcx
   11554:	ee                   	out    %al,(%dx)
   11555:	0f b6 01             	movzbl (%rcx),%eax
   11558:	84 c0                	test   %al,%al
   1155a:	75 f4                	jne    11550 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x880>
   1155c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11561:	ee                   	out    %al,(%dx)
   11562:	b8 20 00 00 00       	mov    $0x20,%eax
   11567:	ee                   	out    %al,(%dx)
   11568:	b8 53 00 00 00       	mov    $0x53,%eax
   1156d:	ee                   	out    %al,(%dx)
   1156e:	b8 20 00 00 00       	mov    $0x20,%eax
   11573:	48 8d 0d d5 2d 00 00 	lea    0x2dd5(%rip),%rcx        # 1434f <_data+0x34f>
   1157a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1157f:	90                   	nop
   11580:	48 83 c1 01          	add    $0x1,%rcx
   11584:	ee                   	out    %al,(%dx)
   11585:	0f b6 01             	movzbl (%rcx),%eax
   11588:	84 c0                	test   %al,%al
   1158a:	75 f4                	jne    11580 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x8b0>
   1158c:	45 89 c2             	mov    %r8d,%r10d
   1158f:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   11594:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11599:	4c 8d 0d 40 38 00 00 	lea    0x3840(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   115a0:	44 89 d0             	mov    %r10d,%eax
   115a3:	d3 e8                	shr    %cl,%eax
   115a5:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   115aa:	ee                   	out    %al,(%dx)
   115ab:	83 e9 04             	sub    $0x4,%ecx
   115ae:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   115b1:	75 ed                	jne    115a0 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x8d0>
   115b3:	e9 ff fa ff ff       	jmp    110b7 <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x3e7>
   115b8:	8b 05 c6 bb 00 00    	mov    0xbbc6(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   115be:	e9 29 ff ff ff       	jmp    114ec <_ZN10UEFIBridge11RuntimeHook17HookedSetVariableEPtP8EFI_GUIDjmPv+0x81c>
   115c3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   115ca:	00 00 00 
   115cd:	0f 1f 00             	nopl   (%rax)

00000000000115d0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv>:
   115d0:	41 57                	push   %r15
   115d2:	41 56                	push   %r14
   115d4:	41 55                	push   %r13
   115d6:	41 54                	push   %r12
   115d8:	4d 89 cc             	mov    %r9,%r12
   115db:	55                   	push   %rbp
   115dc:	48 89 d5             	mov    %rdx,%rbp
   115df:	57                   	push   %rdi
   115e0:	bf 47 00 00 00       	mov    $0x47,%edi
   115e5:	56                   	push   %rsi
   115e6:	53                   	push   %rbx
   115e7:	48 89 cb             	mov    %rcx,%rbx
   115ea:	48 81 ec 18 01 00 00 	sub    $0x118,%rsp
   115f1:	4c 89 84 24 70 01 00 	mov    %r8,0x170(%rsp)
   115f8:	00 
   115f9:	0f 29 74 24 70       	movaps %xmm6,0x70(%rsp)
   115fe:	0f 29 bc 24 80 00 00 	movaps %xmm7,0x80(%rsp)
   11605:	00 
   11606:	44 0f 29 84 24 90 00 	movaps %xmm8,0x90(%rsp)
   1160d:	00 00 
   1160f:	44 0f 29 8c 24 a0 00 	movaps %xmm9,0xa0(%rsp)
   11616:	00 00 
   11618:	44 0f 29 94 24 b0 00 	movaps %xmm10,0xb0(%rsp)
   1161f:	00 00 
   11621:	44 0f 29 9c 24 c0 00 	movaps %xmm11,0xc0(%rsp)
   11628:	00 00 
   1162a:	44 0f 29 a4 24 d0 00 	movaps %xmm12,0xd0(%rsp)
   11631:	00 00 
   11633:	44 0f 29 ac 24 e0 00 	movaps %xmm13,0xe0(%rsp)
   1163a:	00 00 
   1163c:	44 0f 29 b4 24 f0 00 	movaps %xmm14,0xf0(%rsp)
   11643:	00 00 
   11645:	44 0f 29 bc 24 00 01 	movaps %xmm15,0x100(%rsp)
   1164c:	00 00 
   1164e:	e8 6d f3 ff ff       	call   109c0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc>
   11653:	48 8b 05 be b6 00 00 	mov    0xb6be(%rip),%rax        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   1165a:	8b 15 28 bb 00 00    	mov    0xbb28(%rip),%edx        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   11660:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
   11665:	85 d2                	test   %edx,%edx
   11667:	0f 84 9b 01 00 00    	je     11808 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x238>
   1166d:	48 85 c0             	test   %rax,%rax
   11670:	0f 84 da 03 00 00    	je     11a50 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x480>
   11676:	48 85 db             	test   %rbx,%rbx
   11679:	74 15                	je     11690 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xc0>
   1167b:	48 85 ed             	test   %rbp,%rbp
   1167e:	0f 85 9c 03 00 00    	jne    11a20 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x450>
   11684:	48 85 db             	test   %rbx,%rbx
   11687:	0f 85 8d 01 00 00    	jne    1181a <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x24a>
   1168d:	0f 1f 00             	nopl   (%rax)
   11690:	4c 8b 30             	mov    (%rax),%r14
   11693:	4d 85 f6             	test   %r14,%r14
   11696:	0f 84 ae 00 00 00    	je     1174a <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x17a>
   1169c:	80 78 31 00          	cmpb   $0x0,0x31(%rax)
   116a0:	0f 85 a4 00 00 00    	jne    1174a <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x17a>
   116a6:	c6 40 31 01          	movb   $0x1,0x31(%rax)
   116aa:	49 8b 16             	mov    (%r14),%rdx
   116ad:	48 85 d2             	test   %rdx,%rdx
   116b0:	0f 84 8b 00 00 00    	je     11741 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x171>
   116b6:	49 83 7e 08 00       	cmpq   $0x0,0x8(%r14)
   116bb:	0f 84 80 00 00 00    	je     11741 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x171>
   116c1:	4c 8b 7a 10          	mov    0x10(%rdx),%r15
   116c5:	49 8b 16             	mov    (%r14),%rdx
   116c8:	45 8b 4f 10          	mov    0x10(%r15),%r9d
   116cc:	45 8b 6f 14          	mov    0x14(%r15),%r13d
   116d0:	48 8b 12             	mov    (%rdx),%rdx
   116d3:	48 8d 82 00 04 00 00 	lea    0x400(%rdx),%rax
   116da:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
   116df:	48 8d 82 00 14 00 00 	lea    0x1400(%rdx),%rax
   116e6:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
   116eb:	45 39 e9             	cmp    %r13d,%r9d
   116ee:	74 3e                	je     1172e <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x15e>
   116f0:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
   116f5:	44 89 ee             	mov    %r13d,%esi
   116f8:	48 8b 54 24 40       	mov    0x40(%rsp),%rdx
   116fd:	4c 89 f7             	mov    %r14,%rdi
   11700:	48 c1 e6 06          	shl    $0x6,%rsi
   11704:	48 01 c6             	add    %rax,%rsi
   11707:	e8 14 e6 ff ff       	call   fd20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot>
   1170c:	41 8d 45 01          	lea    0x1(%r13),%eax
   11710:	83 e0 3f             	and    $0x3f,%eax
   11713:	41 89 47 14          	mov    %eax,0x14(%r15)
   11717:	41 89 c5             	mov    %eax,%r13d
   1171a:	49 8b 57 28          	mov    0x28(%r15),%rdx
   1171e:	48 83 c2 01          	add    $0x1,%rdx
   11722:	49 89 57 28          	mov    %rdx,0x28(%r15)
   11726:	41 8b 57 10          	mov    0x10(%r15),%edx
   1172a:	39 d0                	cmp    %edx,%eax
   1172c:	75 c2                	jne    116f0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x120>
   1172e:	49 8b 47 20          	mov    0x20(%r15),%rax
   11732:	48 83 c0 01          	add    $0x1,%rax
   11736:	49 89 47 20          	mov    %rax,0x20(%r15)
   1173a:	48 8b 05 d7 b5 00 00 	mov    0xb5d7(%rip),%rax        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   11741:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
   11746:	c6 47 31 00          	movb   $0x0,0x31(%rdi)
   1174a:	48 8b 40 10          	mov    0x10(%rax),%rax
   1174e:	48 85 c0             	test   %rax,%rax
   11751:	0f 84 f9 02 00 00    	je     11a50 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x480>
   11757:	48 8b bc 24 80 01 00 	mov    0x180(%rsp),%rdi
   1175e:	00 
   1175f:	4d 89 e1             	mov    %r12,%r9
   11762:	48 89 ea             	mov    %rbp,%rdx
   11765:	48 89 d9             	mov    %rbx,%rcx
   11768:	4c 8b 84 24 70 01 00 	mov    0x170(%rsp),%r8
   1176f:	00 
   11770:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
   11775:	ff d0                	call   *%rax
   11777:	49 89 c0             	mov    %rax,%r8
   1177a:	8b 05 08 ba 00 00    	mov    0xba08(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   11780:	85 c0                	test   %eax,%eax
   11782:	0f 84 38 04 00 00    	je     11bc0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x5f0>
   11788:	8b 05 0a ba 00 00    	mov    0xba0a(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   1178e:	83 f8 08             	cmp    $0x8,%eax
   11791:	0f 86 38 04 00 00    	jbe    11bcf <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x5ff>
   11797:	0f 28 74 24 70       	movaps 0x70(%rsp),%xmm6
   1179c:	4c 89 c0             	mov    %r8,%rax
   1179f:	0f 28 bc 24 80 00 00 	movaps 0x80(%rsp),%xmm7
   117a6:	00 
   117a7:	44 0f 28 84 24 90 00 	movaps 0x90(%rsp),%xmm8
   117ae:	00 00 
   117b0:	44 0f 28 8c 24 a0 00 	movaps 0xa0(%rsp),%xmm9
   117b7:	00 00 
   117b9:	44 0f 28 94 24 b0 00 	movaps 0xb0(%rsp),%xmm10
   117c0:	00 00 
   117c2:	44 0f 28 9c 24 c0 00 	movaps 0xc0(%rsp),%xmm11
   117c9:	00 00 
   117cb:	44 0f 28 a4 24 d0 00 	movaps 0xd0(%rsp),%xmm12
   117d2:	00 00 
   117d4:	44 0f 28 ac 24 e0 00 	movaps 0xe0(%rsp),%xmm13
   117db:	00 00 
   117dd:	44 0f 28 b4 24 f0 00 	movaps 0xf0(%rsp),%xmm14
   117e4:	00 00 
   117e6:	44 0f 28 bc 24 00 01 	movaps 0x100(%rsp),%xmm15
   117ed:	00 00 
   117ef:	48 81 c4 18 01 00 00 	add    $0x118,%rsp
   117f6:	5b                   	pop    %rbx
   117f7:	5e                   	pop    %rsi
   117f8:	5f                   	pop    %rdi
   117f9:	5d                   	pop    %rbp
   117fa:	41 5c                	pop    %r12
   117fc:	41 5d                	pop    %r13
   117fe:	41 5e                	pop    %r14
   11800:	41 5f                	pop    %r15
   11802:	c3                   	ret
   11803:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11808:	48 85 c0             	test   %rax,%rax
   1180b:	0f 84 3f 02 00 00    	je     11a50 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x480>
   11811:	48 85 db             	test   %rbx,%rbx
   11814:	0f 84 92 03 00 00    	je     11bac <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x5dc>
   1181a:	48 85 ed             	test   %rbp,%rbp
   1181d:	74 18                	je     11837 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x267>
   1181f:	48 8d 35 5a 46 00 00 	lea    0x465a(%rip),%rsi        # 15e80 <_ZZN10UEFIBridge11RuntimeHook13IsOurVariableEPtP8EFI_GUIDE8kOurGuid>
   11826:	48 89 ef             	mov    %rbp,%rdi
   11829:	e8 62 50 ff ff       	call   6890 <CompareGuid>
   1182e:	48 85 c0             	test   %rax,%rax
   11831:	0f 85 69 03 00 00    	jne    11ba0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x5d0>
   11837:	48 8d 35 44 30 00 00 	lea    0x3044(%rip),%rsi        # 14882 <_data+0x882>
   1183e:	48 89 df             	mov    %rbx,%rdi
   11841:	e8 5a 7e ff ff       	call   96a0 <StrCmp>
   11846:	48 85 c0             	test   %rax,%rax
   11849:	0f 85 09 03 00 00    	jne    11b58 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x588>
   1184f:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11854:	b8 0d 00 00 00       	mov    $0xd,%eax
   11859:	ee                   	out    %al,(%dx)
   1185a:	b8 0a 00 00 00       	mov    $0xa,%eax
   1185f:	ee                   	out    %al,(%dx)
   11860:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11865:	48 8d 0d 94 27 00 00 	lea    0x2794(%rip),%rcx        # 14000 <_data>
   1186c:	48 83 c1 01          	add    $0x1,%rcx
   11870:	ee                   	out    %al,(%dx)
   11871:	0f b6 01             	movzbl (%rcx),%eax
   11874:	84 c0                	test   %al,%al
   11876:	75 f4                	jne    1186c <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x29c>
   11878:	b8 5b 00 00 00       	mov    $0x5b,%eax
   1187d:	ee                   	out    %al,(%dx)
   1187e:	b8 48 00 00 00       	mov    $0x48,%eax
   11883:	48 8d 0d 84 2a 00 00 	lea    0x2a84(%rip),%rcx        # 1430e <_data+0x30e>
   1188a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1188f:	90                   	nop
   11890:	48 83 c1 01          	add    $0x1,%rcx
   11894:	ee                   	out    %al,(%dx)
   11895:	0f b6 01             	movzbl (%rcx),%eax
   11898:	84 c0                	test   %al,%al
   1189a:	75 f4                	jne    11890 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x2c0>
   1189c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   118a1:	ee                   	out    %al,(%dx)
   118a2:	b8 20 00 00 00       	mov    $0x20,%eax
   118a7:	ee                   	out    %al,(%dx)
   118a8:	b8 47 00 00 00       	mov    $0x47,%eax
   118ad:	48 8d 0d c7 2a 00 00 	lea    0x2ac7(%rip),%rcx        # 1437b <_data+0x37b>
   118b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   118b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   118c0:	48 83 c1 01          	add    $0x1,%rcx
   118c4:	ee                   	out    %al,(%dx)
   118c5:	0f b6 01             	movzbl (%rcx),%eax
   118c8:	84 c0                	test   %al,%al
   118ca:	75 f4                	jne    118c0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x2f0>
   118cc:	4d 85 e4             	test   %r12,%r12
   118cf:	0f 84 5b 05 00 00    	je     11e30 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x860>
   118d5:	48 8d 35 be 2f 00 00 	lea    0x2fbe(%rip),%rsi        # 1489a <_data+0x89a>
   118dc:	48 89 df             	mov    %rbx,%rdi
   118df:	48 8b 2d 32 b4 00 00 	mov    0xb432(%rip),%rbp        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   118e6:	e8 b5 7d ff ff       	call   96a0 <StrCmp>
   118eb:	48 85 c0             	test   %rax,%rax
   118ee:	0f 85 4c 05 00 00    	jne    11e40 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x870>
   118f4:	48 8b 55 78          	mov    0x78(%rbp),%rdx
   118f8:	49 39 14 24          	cmp    %rdx,(%r12)
   118fc:	0f 82 9e 03 00 00    	jb     11ca0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6d0>
   11902:	48 83 bc 24 80 01 00 	cmpq   $0x0,0x180(%rsp)
   11909:	00 00 
   1190b:	0f 84 af 05 00 00    	je     11ec0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x8f0>
   11911:	48 83 bc 24 70 01 00 	cmpq   $0x0,0x170(%rsp)
   11918:	00 00 
   1191a:	74 0e                	je     1192a <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x35a>
   1191c:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
   11923:	00 
   11924:	c7 00 07 00 00 00    	movl   $0x7,(%rax)
   1192a:	48 8b bc 24 80 01 00 	mov    0x180(%rsp),%rdi
   11931:	00 
   11932:	48 8d 75 32          	lea    0x32(%rbp),%rsi
   11936:	e8 45 54 ff ff       	call   6d80 <CopyMem>
   1193b:	48 8b 55 78          	mov    0x78(%rbp),%rdx
   1193f:	49 89 14 24          	mov    %rdx,(%r12)
   11943:	45 31 c0             	xor    %r8d,%r8d
   11946:	8b 05 3c b8 00 00    	mov    0xb83c(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   1194c:	85 c0                	test   %eax,%eax
   1194e:	0f 84 64 03 00 00    	je     11cb8 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6e8>
   11954:	8b 05 3e b8 00 00    	mov    0xb83e(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   1195a:	83 f8 08             	cmp    $0x8,%eax
   1195d:	0f 87 34 fe ff ff    	ja     11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11963:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11968:	b8 0d 00 00 00       	mov    $0xd,%eax
   1196d:	ee                   	out    %al,(%dx)
   1196e:	b8 0a 00 00 00       	mov    $0xa,%eax
   11973:	ee                   	out    %al,(%dx)
   11974:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11979:	48 8d 0d 80 26 00 00 	lea    0x2680(%rip),%rcx        # 14000 <_data>
   11980:	48 83 c1 01          	add    $0x1,%rcx
   11984:	ee                   	out    %al,(%dx)
   11985:	0f b6 01             	movzbl (%rcx),%eax
   11988:	84 c0                	test   %al,%al
   1198a:	75 f4                	jne    11980 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x3b0>
   1198c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11991:	ee                   	out    %al,(%dx)
   11992:	b8 48 00 00 00       	mov    $0x48,%eax
   11997:	48 8d 0d 70 29 00 00 	lea    0x2970(%rip),%rcx        # 1430e <_data+0x30e>
   1199e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   119a3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   119aa:	00 00 00 00 
   119ae:	66 90                	xchg   %ax,%ax
   119b0:	48 83 c1 01          	add    $0x1,%rcx
   119b4:	ee                   	out    %al,(%dx)
   119b5:	0f b6 01             	movzbl (%rcx),%eax
   119b8:	84 c0                	test   %al,%al
   119ba:	75 f4                	jne    119b0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x3e0>
   119bc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   119c1:	ee                   	out    %al,(%dx)
   119c2:	b8 20 00 00 00       	mov    $0x20,%eax
   119c7:	ee                   	out    %al,(%dx)
   119c8:	b8 47 00 00 00       	mov    $0x47,%eax
   119cd:	ee                   	out    %al,(%dx)
   119ce:	b8 20 00 00 00       	mov    $0x20,%eax
   119d3:	48 8d 0d 75 29 00 00 	lea    0x2975(%rip),%rcx        # 1434f <_data+0x34f>
   119da:	ba f8 03 00 00       	mov    $0x3f8,%edx
   119df:	90                   	nop
   119e0:	48 83 c1 01          	add    $0x1,%rcx
   119e4:	ee                   	out    %al,(%dx)
   119e5:	0f b6 01             	movzbl (%rcx),%eax
   119e8:	84 c0                	test   %al,%al
   119ea:	75 f4                	jne    119e0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x410>
   119ec:	45 89 c2             	mov    %r8d,%r10d
   119ef:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   119f4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   119f9:	4c 8d 0d e0 33 00 00 	lea    0x33e0(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11a00:	44 89 d0             	mov    %r10d,%eax
   11a03:	d3 e8                	shr    %cl,%eax
   11a05:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   11a0a:	ee                   	out    %al,(%dx)
   11a0b:	83 e9 04             	sub    $0x4,%ecx
   11a0e:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11a11:	75 ed                	jne    11a00 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x430>
   11a13:	e9 7f fd ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11a18:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   11a1f:	00 
   11a20:	48 8d 35 39 44 00 00 	lea    0x4439(%rip),%rsi        # 15e60 <_ZN10UEFIBridge19gInfinityMemVarGuidE>
   11a27:	48 89 ef             	mov    %rbp,%rdi
   11a2a:	e8 61 4e ff ff       	call   6890 <CompareGuid>
   11a2f:	48 85 c0             	test   %rax,%rax
   11a32:	0f 84 90 02 00 00    	je     11cc8 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6f8>
   11a38:	48 83 3d d8 b2 00 00 	cmpq   $0x0,0xb2d8(%rip)        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   11a3f:	00 
   11a40:	0f 85 d9 fd ff ff    	jne    1181f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x24f>
   11a46:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   11a4d:	00 00 00 
   11a50:	8b 05 32 b7 00 00    	mov    0xb732(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   11a56:	85 c0                	test   %eax,%eax
   11a58:	0f 85 32 02 00 00    	jne    11c90 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6c0>
   11a5e:	8b 05 20 b7 00 00    	mov    0xb720(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11a64:	49 b8 03 00 00 00 00 	movabs $0x8000000000000003,%r8
   11a6b:	00 00 80 
   11a6e:	83 f8 08             	cmp    $0x8,%eax
   11a71:	0f 87 20 fd ff ff    	ja     11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11a77:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11a7c:	b8 0d 00 00 00       	mov    $0xd,%eax
   11a81:	ee                   	out    %al,(%dx)
   11a82:	b8 0a 00 00 00       	mov    $0xa,%eax
   11a87:	ee                   	out    %al,(%dx)
   11a88:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11a8d:	48 8d 0d 6c 25 00 00 	lea    0x256c(%rip),%rcx        # 14000 <_data>
   11a94:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11a9b:	00 00 00 00 
   11a9f:	90                   	nop
   11aa0:	48 83 c1 01          	add    $0x1,%rcx
   11aa4:	ee                   	out    %al,(%dx)
   11aa5:	0f b6 01             	movzbl (%rcx),%eax
   11aa8:	84 c0                	test   %al,%al
   11aaa:	75 f4                	jne    11aa0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x4d0>
   11aac:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11ab1:	ee                   	out    %al,(%dx)
   11ab2:	b8 48 00 00 00       	mov    $0x48,%eax
   11ab7:	48 8d 0d 50 28 00 00 	lea    0x2850(%rip),%rcx        # 1430e <_data+0x30e>
   11abe:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11ac3:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11aca:	00 00 00 00 
   11ace:	66 90                	xchg   %ax,%ax
   11ad0:	48 83 c1 01          	add    $0x1,%rcx
   11ad4:	ee                   	out    %al,(%dx)
   11ad5:	0f b6 01             	movzbl (%rcx),%eax
   11ad8:	84 c0                	test   %al,%al
   11ada:	75 f4                	jne    11ad0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x500>
   11adc:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11ae1:	ee                   	out    %al,(%dx)
   11ae2:	b8 20 00 00 00       	mov    $0x20,%eax
   11ae7:	ee                   	out    %al,(%dx)
   11ae8:	b8 47 00 00 00       	mov    $0x47,%eax
   11aed:	ee                   	out    %al,(%dx)
   11aee:	b8 20 00 00 00       	mov    $0x20,%eax
   11af3:	48 8d 0d 55 28 00 00 	lea    0x2855(%rip),%rcx        # 1434f <_data+0x34f>
   11afa:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11aff:	90                   	nop
   11b00:	48 83 c1 01          	add    $0x1,%rcx
   11b04:	ee                   	out    %al,(%dx)
   11b05:	0f b6 01             	movzbl (%rcx),%eax
   11b08:	84 c0                	test   %al,%al
   11b0a:	75 f4                	jne    11b00 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x530>
   11b0c:	b8 30 00 00 00       	mov    $0x30,%eax
   11b11:	ee                   	out    %al,(%dx)
   11b12:	b9 18 00 00 00       	mov    $0x18,%ecx
   11b17:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   11b1d:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11b22:	4c 8d 0d b7 32 00 00 	lea    0x32b7(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11b29:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   11b30:	44 89 c0             	mov    %r8d,%eax
   11b33:	d3 e8                	shr    %cl,%eax
   11b35:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   11b3a:	ee                   	out    %al,(%dx)
   11b3b:	83 e9 04             	sub    $0x4,%ecx
   11b3e:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11b41:	75 ed                	jne    11b30 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x560>
   11b43:	49 b8 03 00 00 00 00 	movabs $0x8000000000000003,%r8
   11b4a:	00 00 80 
   11b4d:	e9 45 fc ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11b52:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   11b58:	48 8d 35 3b 2d 00 00 	lea    0x2d3b(%rip),%rsi        # 1489a <_data+0x89a>
   11b5f:	48 89 df             	mov    %rbx,%rdi
   11b62:	e8 39 7b ff ff       	call   96a0 <StrCmp>
   11b67:	48 85 c0             	test   %rax,%rax
   11b6a:	0f 84 df fc ff ff    	je     1184f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x27f>
   11b70:	48 8d 35 3d 2d 00 00 	lea    0x2d3d(%rip),%rsi        # 148b4 <_data+0x8b4>
   11b77:	48 89 df             	mov    %rbx,%rdi
   11b7a:	e8 21 7b ff ff       	call   96a0 <StrCmp>
   11b7f:	48 85 c0             	test   %rax,%rax
   11b82:	0f 84 c7 fc ff ff    	je     1184f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x27f>
   11b88:	48 8d 35 3f 2d 00 00 	lea    0x2d3f(%rip),%rsi        # 148ce <_data+0x8ce>
   11b8f:	48 89 df             	mov    %rbx,%rdi
   11b92:	e8 09 7b ff ff       	call   96a0 <StrCmp>
   11b97:	48 85 c0             	test   %rax,%rax
   11b9a:	0f 84 af fc ff ff    	je     1184f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x27f>
   11ba0:	48 8b 05 71 b1 00 00 	mov    0xb171(%rip),%rax        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   11ba7:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
   11bac:	48 85 c0             	test   %rax,%rax
   11baf:	0f 85 db fa ff ff    	jne    11690 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xc0>
   11bb5:	e9 96 fe ff ff       	jmp    11a50 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x480>
   11bba:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   11bc0:	8b 05 be b5 00 00    	mov    0xb5be(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11bc6:	83 f8 08             	cmp    $0x8,%eax
   11bc9:	0f 87 c8 fb ff ff    	ja     11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11bcf:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11bd4:	b8 0d 00 00 00       	mov    $0xd,%eax
   11bd9:	ee                   	out    %al,(%dx)
   11bda:	b8 0a 00 00 00       	mov    $0xa,%eax
   11bdf:	ee                   	out    %al,(%dx)
   11be0:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11be5:	48 8d 0d 14 24 00 00 	lea    0x2414(%rip),%rcx        # 14000 <_data>
   11bec:	0f 1f 40 00          	nopl   0x0(%rax)
   11bf0:	48 83 c1 01          	add    $0x1,%rcx
   11bf4:	ee                   	out    %al,(%dx)
   11bf5:	0f b6 01             	movzbl (%rcx),%eax
   11bf8:	84 c0                	test   %al,%al
   11bfa:	75 f4                	jne    11bf0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x620>
   11bfc:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11c01:	ee                   	out    %al,(%dx)
   11c02:	b8 48 00 00 00       	mov    $0x48,%eax
   11c07:	48 8d 0d 00 27 00 00 	lea    0x2700(%rip),%rcx        # 1430e <_data+0x30e>
   11c0e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11c13:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11c1a:	00 00 00 00 
   11c1e:	66 90                	xchg   %ax,%ax
   11c20:	48 83 c1 01          	add    $0x1,%rcx
   11c24:	ee                   	out    %al,(%dx)
   11c25:	0f b6 01             	movzbl (%rcx),%eax
   11c28:	84 c0                	test   %al,%al
   11c2a:	75 f4                	jne    11c20 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x650>
   11c2c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11c31:	ee                   	out    %al,(%dx)
   11c32:	b8 20 00 00 00       	mov    $0x20,%eax
   11c37:	ee                   	out    %al,(%dx)
   11c38:	b8 47 00 00 00       	mov    $0x47,%eax
   11c3d:	ee                   	out    %al,(%dx)
   11c3e:	b8 20 00 00 00       	mov    $0x20,%eax
   11c43:	48 8d 0d 05 27 00 00 	lea    0x2705(%rip),%rcx        # 1434f <_data+0x34f>
   11c4a:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11c4f:	90                   	nop
   11c50:	48 83 c1 01          	add    $0x1,%rcx
   11c54:	ee                   	out    %al,(%dx)
   11c55:	0f b6 01             	movzbl (%rcx),%eax
   11c58:	84 c0                	test   %al,%al
   11c5a:	75 f4                	jne    11c50 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x680>
   11c5c:	45 89 c2             	mov    %r8d,%r10d
   11c5f:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   11c64:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11c69:	4c 8d 0d 70 31 00 00 	lea    0x3170(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   11c70:	44 89 d0             	mov    %r10d,%eax
   11c73:	d3 e8                	shr    %cl,%eax
   11c75:	83 e0 0f             	and    $0xf,%eax
   11c78:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   11c7d:	ee                   	out    %al,(%dx)
   11c7e:	83 e9 04             	sub    $0x4,%ecx
   11c81:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   11c84:	75 ea                	jne    11c70 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6a0>
   11c86:	e9 0c fb ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11c8b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11c90:	8b 05 02 b5 00 00    	mov    0xb502(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   11c96:	e9 c9 fd ff ff       	jmp    11a64 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x494>
   11c9b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11ca0:	49 b8 05 00 00 00 00 	movabs $0x8000000000000005,%r8
   11ca7:	00 00 80 
   11caa:	49 89 14 24          	mov    %rdx,(%r12)
   11cae:	e9 93 fc ff ff       	jmp    11946 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x376>
   11cb3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11cb8:	8b 05 c6 b4 00 00    	mov    0xb4c6(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   11cbe:	e9 97 fc ff ff       	jmp    1195a <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x38a>
   11cc3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11cc8:	48 8d 35 8b 2b 00 00 	lea    0x2b8b(%rip),%rsi        # 1485a <_data+0x85a>
   11ccf:	48 89 df             	mov    %rbx,%rdi
   11cd2:	e8 c9 79 ff ff       	call   96a0 <StrCmp>
   11cd7:	48 85 c0             	test   %rax,%rax
   11cda:	0f 85 10 02 00 00    	jne    11ef0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x920>
   11ce0:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11ce5:	b8 0d 00 00 00       	mov    $0xd,%eax
   11cea:	ee                   	out    %al,(%dx)
   11ceb:	b8 0a 00 00 00       	mov    $0xa,%eax
   11cf0:	ee                   	out    %al,(%dx)
   11cf1:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11cf6:	48 8d 0d 03 23 00 00 	lea    0x2303(%rip),%rcx        # 14000 <_data>
   11cfd:	0f 1f 00             	nopl   (%rax)
   11d00:	48 83 c1 01          	add    $0x1,%rcx
   11d04:	ee                   	out    %al,(%dx)
   11d05:	0f b6 01             	movzbl (%rcx),%eax
   11d08:	84 c0                	test   %al,%al
   11d0a:	75 f4                	jne    11d00 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x730>
   11d0c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11d11:	ee                   	out    %al,(%dx)
   11d12:	b8 48 00 00 00       	mov    $0x48,%eax
   11d17:	48 8d 0d f0 25 00 00 	lea    0x25f0(%rip),%rcx        # 1430e <_data+0x30e>
   11d1e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11d23:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11d2a:	00 00 00 00 
   11d2e:	66 90                	xchg   %ax,%ax
   11d30:	48 83 c1 01          	add    $0x1,%rcx
   11d34:	ee                   	out    %al,(%dx)
   11d35:	0f b6 01             	movzbl (%rcx),%eax
   11d38:	84 c0                	test   %al,%al
   11d3a:	75 f4                	jne    11d30 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x760>
   11d3c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11d41:	ee                   	out    %al,(%dx)
   11d42:	b8 20 00 00 00       	mov    $0x20,%eax
   11d47:	ee                   	out    %al,(%dx)
   11d48:	b8 47 00 00 00       	mov    $0x47,%eax
   11d4d:	48 8d 0d 0a 26 00 00 	lea    0x260a(%rip),%rcx        # 1435e <_data+0x35e>
   11d54:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11d59:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   11d60:	48 83 c1 01          	add    $0x1,%rcx
   11d64:	ee                   	out    %al,(%dx)
   11d65:	0f b6 01             	movzbl (%rcx),%eax
   11d68:	84 c0                	test   %al,%al
   11d6a:	75 f4                	jne    11d60 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x790>
   11d6c:	e8 cf 22 ff ff       	call   4040 <_ZN10UEFIBridgeL23CaptureLiveWindowsBuildEv>
   11d71:	8b 05 39 b4 00 00    	mov    0xb439(%rip),%eax        # 1d1b0 <_ZN10UEFIBridge12g_diag_stageE>
   11d77:	66 0f 6e 05 19 b4 00 	movd   0xb419(%rip),%xmm0        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   11d7e:	00 
   11d7f:	c7 44 24 50 44 46 4e 	movl   $0x494e4644,0x50(%rsp)
   11d86:	49 
   11d87:	66 0f 6e 0d 05 b4 00 	movd   0xb405(%rip),%xmm1        # 1d194 <_ZN10UEFIBridge18g_diag_last_statusE>
   11d8e:	00 
   11d8f:	49 b8 02 00 00 00 00 	movabs $0x8000000000000002,%r8
   11d96:	00 00 80 
   11d99:	89 44 24 54          	mov    %eax,0x54(%rsp)
   11d9d:	8b 05 09 b4 00 00    	mov    0xb409(%rip),%eax        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
   11da3:	66 0f 62 c1          	punpckldq %xmm1,%xmm0
   11da7:	89 44 24 58          	mov    %eax,0x58(%rsp)
   11dab:	8b 05 f7 b3 00 00    	mov    0xb3f7(%rip),%eax        # 1d1a8 <_ZN10UEFIBridge16g_diag_win_buildE>
   11db1:	66 0f d6 44 24 68    	movq   %xmm0,0x68(%rsp)
   11db7:	89 44 24 5c          	mov    %eax,0x5c(%rsp)
   11dbb:	48 8b 05 de b3 00 00 	mov    0xb3de(%rip),%rax        # 1d1a0 <_ZN10UEFIBridge13g_diag_os_cr3E>
   11dc2:	48 89 44 24 60       	mov    %rax,0x60(%rsp)
   11dc7:	4d 85 e4             	test   %r12,%r12
   11dca:	0f 84 c7 f9 ff ff    	je     11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11dd0:	48 83 bc 24 80 01 00 	cmpq   $0x0,0x180(%rsp)
   11dd7:	00 00 
   11dd9:	0f 84 2c 02 00 00    	je     1200b <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xa3b>
   11ddf:	49 83 3c 24 1f       	cmpq   $0x1f,(%r12)
   11de4:	0f 86 21 02 00 00    	jbe    1200b <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xa3b>
   11dea:	48 83 bc 24 70 01 00 	cmpq   $0x0,0x170(%rsp)
   11df1:	00 00 
   11df3:	74 0e                	je     11e03 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x833>
   11df5:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
   11dfc:	00 
   11dfd:	c7 00 07 00 00 00    	movl   $0x7,(%rax)
   11e03:	48 8b bc 24 80 01 00 	mov    0x180(%rsp),%rdi
   11e0a:	00 
   11e0b:	48 8d 74 24 50       	lea    0x50(%rsp),%rsi
   11e10:	ba 20 00 00 00       	mov    $0x20,%edx
   11e15:	e8 66 4f ff ff       	call   6d80 <CopyMem>
   11e1a:	49 c7 04 24 20 00 00 	movq   $0x20,(%r12)
   11e21:	00 
   11e22:	45 31 c0             	xor    %r8d,%r8d
   11e25:	e9 6d f9 ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11e2a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   11e30:	49 b8 02 00 00 00 00 	movabs $0x8000000000000002,%r8
   11e37:	00 00 80 
   11e3a:	e9 07 fb ff ff       	jmp    11946 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x376>
   11e3f:	90                   	nop
   11e40:	48 8d 35 6d 2a 00 00 	lea    0x2a6d(%rip),%rsi        # 148b4 <_data+0x8b4>
   11e47:	48 89 df             	mov    %rbx,%rdi
   11e4a:	e8 51 78 ff ff       	call   96a0 <StrCmp>
   11e4f:	49 b8 0e 00 00 00 00 	movabs $0x800000000000000e,%r8
   11e56:	00 00 80 
   11e59:	48 85 c0             	test   %rax,%rax
   11e5c:	0f 85 e4 fa ff ff    	jne    11946 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x376>
   11e62:	48 8b 95 80 10 00 00 	mov    0x1080(%rbp),%rdx
   11e69:	49 39 14 24          	cmp    %rdx,(%r12)
   11e6d:	0f 82 2d fe ff ff    	jb     11ca0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x6d0>
   11e73:	48 83 bc 24 80 01 00 	cmpq   $0x0,0x180(%rsp)
   11e7a:	00 00 
   11e7c:	74 42                	je     11ec0 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x8f0>
   11e7e:	48 83 bc 24 70 01 00 	cmpq   $0x0,0x170(%rsp)
   11e85:	00 00 
   11e87:	74 0e                	je     11e97 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x8c7>
   11e89:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
   11e90:	00 
   11e91:	c7 00 07 00 00 00    	movl   $0x7,(%rax)
   11e97:	48 8b bc 24 80 01 00 	mov    0x180(%rsp),%rdi
   11e9e:	00 
   11e9f:	48 8d b5 80 00 00 00 	lea    0x80(%rbp),%rsi
   11ea6:	e8 d5 4e ff ff       	call   6d80 <CopyMem>
   11eab:	48 8b 95 80 10 00 00 	mov    0x1080(%rbp),%rdx
   11eb2:	e9 88 fa ff ff       	jmp    1193f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x36f>
   11eb7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   11ebe:	00 00 
   11ec0:	48 85 d2             	test   %rdx,%rdx
   11ec3:	0f 85 67 ff ff ff    	jne    11e30 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x860>
   11ec9:	48 83 bc 24 70 01 00 	cmpq   $0x0,0x170(%rsp)
   11ed0:	00 00 
   11ed2:	0f 84 67 fa ff ff    	je     1193f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x36f>
   11ed8:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
   11edf:	00 
   11ee0:	c7 00 07 00 00 00    	movl   $0x7,(%rax)
   11ee6:	e9 54 fa ff ff       	jmp    1193f <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x36f>
   11eeb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   11ef0:	48 8d 35 ed 29 00 00 	lea    0x29ed(%rip),%rsi        # 148e4 <_data+0x8e4>
   11ef7:	48 89 df             	mov    %rbx,%rdi
   11efa:	e8 a1 77 ff ff       	call   96a0 <StrCmp>
   11eff:	48 85 c0             	test   %rax,%rax
   11f02:	0f 85 30 fb ff ff    	jne    11a38 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x468>
   11f08:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11f0d:	b8 0d 00 00 00       	mov    $0xd,%eax
   11f12:	ee                   	out    %al,(%dx)
   11f13:	b8 0a 00 00 00       	mov    $0xa,%eax
   11f18:	ee                   	out    %al,(%dx)
   11f19:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11f1e:	48 8d 0d db 20 00 00 	lea    0x20db(%rip),%rcx        # 14000 <_data>
   11f25:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11f2c:	00 00 00 00 
   11f30:	48 83 c1 01          	add    $0x1,%rcx
   11f34:	ee                   	out    %al,(%dx)
   11f35:	0f b6 01             	movzbl (%rcx),%eax
   11f38:	84 c0                	test   %al,%al
   11f3a:	75 f4                	jne    11f30 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x960>
   11f3c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   11f41:	ee                   	out    %al,(%dx)
   11f42:	b8 48 00 00 00       	mov    $0x48,%eax
   11f47:	48 8d 0d c0 23 00 00 	lea    0x23c0(%rip),%rcx        # 1430e <_data+0x30e>
   11f4e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11f53:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   11f5a:	00 00 00 00 
   11f5e:	66 90                	xchg   %ax,%ax
   11f60:	48 83 c1 01          	add    $0x1,%rcx
   11f64:	ee                   	out    %al,(%dx)
   11f65:	0f b6 01             	movzbl (%rcx),%eax
   11f68:	84 c0                	test   %al,%al
   11f6a:	75 f4                	jne    11f60 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x990>
   11f6c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   11f71:	ee                   	out    %al,(%dx)
   11f72:	b8 20 00 00 00       	mov    $0x20,%eax
   11f77:	ee                   	out    %al,(%dx)
   11f78:	b8 47 00 00 00       	mov    $0x47,%eax
   11f7d:	48 8d 0d e9 23 00 00 	lea    0x23e9(%rip),%rcx        # 1436d <_data+0x36d>
   11f84:	ba f8 03 00 00       	mov    $0x3f8,%edx
   11f89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   11f90:	48 83 c1 01          	add    $0x1,%rcx
   11f94:	ee                   	out    %al,(%dx)
   11f95:	0f b6 01             	movzbl (%rcx),%eax
   11f98:	84 c0                	test   %al,%al
   11f9a:	75 f4                	jne    11f90 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x9c0>
   11f9c:	49 b8 02 00 00 00 00 	movabs $0x8000000000000002,%r8
   11fa3:	00 00 80 
   11fa6:	8b 05 e4 b1 00 00    	mov    0xb1e4(%rip),%eax        # 1d190 <_ZN10UEFIBridge16g_diag_req_countE>
   11fac:	89 44 24 50          	mov    %eax,0x50(%rsp)
   11fb0:	4d 85 e4             	test   %r12,%r12
   11fb3:	0f 84 de f7 ff ff    	je     11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   11fb9:	48 83 bc 24 80 01 00 	cmpq   $0x0,0x180(%rsp)
   11fc0:	00 00 
   11fc2:	74 5e                	je     12022 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xa52>
   11fc4:	49 83 3c 24 03       	cmpq   $0x3,(%r12)
   11fc9:	76 57                	jbe    12022 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xa52>
   11fcb:	48 83 bc 24 70 01 00 	cmpq   $0x0,0x170(%rsp)
   11fd2:	00 00 
   11fd4:	74 0e                	je     11fe4 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0xa14>
   11fd6:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
   11fdd:	00 
   11fde:	c7 00 07 00 00 00    	movl   $0x7,(%rax)
   11fe4:	48 8b bc 24 80 01 00 	mov    0x180(%rsp),%rdi
   11feb:	00 
   11fec:	48 8d 74 24 50       	lea    0x50(%rsp),%rsi
   11ff1:	ba 04 00 00 00       	mov    $0x4,%edx
   11ff6:	e8 85 4d ff ff       	call   6d80 <CopyMem>
   11ffb:	49 c7 04 24 04 00 00 	movq   $0x4,(%r12)
   12002:	00 
   12003:	45 31 c0             	xor    %r8d,%r8d
   12006:	e9 8c f7 ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   1200b:	49 c7 04 24 20 00 00 	movq   $0x20,(%r12)
   12012:	00 
   12013:	49 b8 05 00 00 00 00 	movabs $0x8000000000000005,%r8
   1201a:	00 00 80 
   1201d:	e9 75 f7 ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   12022:	49 c7 04 24 04 00 00 	movq   $0x4,(%r12)
   12029:	00 
   1202a:	49 b8 05 00 00 00 00 	movabs $0x8000000000000005,%r8
   12031:	00 00 80 
   12034:	e9 5e f7 ff ff       	jmp    11797 <_ZN10UEFIBridge11RuntimeHook17HookedGetVariableEPtP8EFI_GUIDPjPmPv+0x1c7>
   12039:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000012040 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES>:
   12040:	41 57                	push   %r15
   12042:	41 56                	push   %r14
   12044:	41 55                	push   %r13
   12046:	41 54                	push   %r12
   12048:	55                   	push   %rbp
   12049:	57                   	push   %rdi
   1204a:	bf 54 00 00 00       	mov    $0x54,%edi
   1204f:	56                   	push   %rsi
   12050:	53                   	push   %rbx
   12051:	48 81 ec c8 00 00 00 	sub    $0xc8,%rsp
   12058:	48 89 8c 24 10 01 00 	mov    %rcx,0x110(%rsp)
   1205f:	00 
   12060:	48 89 94 24 18 01 00 	mov    %rdx,0x118(%rsp)
   12067:	00 
   12068:	0f 29 74 24 20       	movaps %xmm6,0x20(%rsp)
   1206d:	0f 29 7c 24 30       	movaps %xmm7,0x30(%rsp)
   12072:	44 0f 29 44 24 40    	movaps %xmm8,0x40(%rsp)
   12078:	44 0f 29 4c 24 50    	movaps %xmm9,0x50(%rsp)
   1207e:	44 0f 29 54 24 60    	movaps %xmm10,0x60(%rsp)
   12084:	44 0f 29 5c 24 70    	movaps %xmm11,0x70(%rsp)
   1208a:	44 0f 29 a4 24 80 00 	movaps %xmm12,0x80(%rsp)
   12091:	00 00 
   12093:	44 0f 29 ac 24 90 00 	movaps %xmm13,0x90(%rsp)
   1209a:	00 00 
   1209c:	44 0f 29 b4 24 a0 00 	movaps %xmm14,0xa0(%rsp)
   120a3:	00 00 
   120a5:	44 0f 29 bc 24 b0 00 	movaps %xmm15,0xb0(%rsp)
   120ac:	00 00 
   120ae:	e8 0d e9 ff ff       	call   109c0 <_ZN10UEFIBridge11RuntimeHook9HookEnterEc>
   120b3:	48 8b 2d 5e ac 00 00 	mov    0xac5e(%rip),%rbp        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   120ba:	48 85 ed             	test   %rbp,%rbp
   120bd:	0f 84 56 01 00 00    	je     12219 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1d9>
   120c3:	4c 8b 65 00          	mov    0x0(%rbp),%r12
   120c7:	4d 85 e4             	test   %r12,%r12
   120ca:	74 0a                	je     120d6 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x96>
   120cc:	80 7d 31 00          	cmpb   $0x0,0x31(%rbp)
   120d0:	0f 84 a2 00 00 00    	je     12178 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x138>
   120d6:	48 8b 45 08          	mov    0x8(%rbp),%rax
   120da:	48 85 c0             	test   %rax,%rax
   120dd:	0f 84 36 01 00 00    	je     12219 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1d9>
   120e3:	48 8b 94 24 18 01 00 	mov    0x118(%rsp),%rdx
   120ea:	00 
   120eb:	48 8b 8c 24 10 01 00 	mov    0x110(%rsp),%rcx
   120f2:	00 
   120f3:	ff d0                	call   *%rax
   120f5:	49 89 c0             	mov    %rax,%r8
   120f8:	8b 05 8a b0 00 00    	mov    0xb08a(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   120fe:	85 c0                	test   %eax,%eax
   12100:	0f 85 12 02 00 00    	jne    12318 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x2d8>
   12106:	8b 05 78 b0 00 00    	mov    0xb078(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   1210c:	83 f8 08             	cmp    $0x8,%eax
   1210f:	0f 86 12 02 00 00    	jbe    12327 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x2e7>
   12115:	0f 28 74 24 20       	movaps 0x20(%rsp),%xmm6
   1211a:	0f 28 7c 24 30       	movaps 0x30(%rsp),%xmm7
   1211f:	4c 89 c0             	mov    %r8,%rax
   12122:	44 0f 28 44 24 40    	movaps 0x40(%rsp),%xmm8
   12128:	44 0f 28 4c 24 50    	movaps 0x50(%rsp),%xmm9
   1212e:	44 0f 28 54 24 60    	movaps 0x60(%rsp),%xmm10
   12134:	44 0f 28 5c 24 70    	movaps 0x70(%rsp),%xmm11
   1213a:	44 0f 28 a4 24 80 00 	movaps 0x80(%rsp),%xmm12
   12141:	00 00 
   12143:	44 0f 28 ac 24 90 00 	movaps 0x90(%rsp),%xmm13
   1214a:	00 00 
   1214c:	44 0f 28 b4 24 a0 00 	movaps 0xa0(%rsp),%xmm14
   12153:	00 00 
   12155:	44 0f 28 bc 24 b0 00 	movaps 0xb0(%rsp),%xmm15
   1215c:	00 00 
   1215e:	48 81 c4 c8 00 00 00 	add    $0xc8,%rsp
   12165:	5b                   	pop    %rbx
   12166:	5e                   	pop    %rsi
   12167:	5f                   	pop    %rdi
   12168:	5d                   	pop    %rbp
   12169:	41 5c                	pop    %r12
   1216b:	41 5d                	pop    %r13
   1216d:	41 5e                	pop    %r14
   1216f:	41 5f                	pop    %r15
   12171:	c3                   	ret
   12172:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   12178:	c6 45 31 01          	movb   $0x1,0x31(%rbp)
   1217c:	49 8b 04 24          	mov    (%r12),%rax
   12180:	48 89 ea             	mov    %rbp,%rdx
   12183:	48 85 c0             	test   %rax,%rax
   12186:	74 7d                	je     12205 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1c5>
   12188:	49 83 7c 24 08 00    	cmpq   $0x0,0x8(%r12)
   1218e:	74 75                	je     12205 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1c5>
   12190:	4c 8b 78 10          	mov    0x10(%rax),%r15
   12194:	49 8b 14 24          	mov    (%r12),%rdx
   12198:	41 8b 47 10          	mov    0x10(%r15),%eax
   1219c:	41 8b 5f 14          	mov    0x14(%r15),%ebx
   121a0:	4c 8b 2a             	mov    (%rdx),%r13
   121a3:	4d 8d b5 00 04 00 00 	lea    0x400(%r13),%r14
   121aa:	49 81 c5 00 14 00 00 	add    $0x1400,%r13
   121b1:	39 d8                	cmp    %ebx,%eax
   121b3:	74 3d                	je     121f2 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1b2>
   121b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   121bc:	00 00 00 00 
   121c0:	89 de                	mov    %ebx,%esi
   121c2:	83 c3 01             	add    $0x1,%ebx
   121c5:	4c 89 ea             	mov    %r13,%rdx
   121c8:	4c 89 e7             	mov    %r12,%rdi
   121cb:	48 c1 e6 06          	shl    $0x6,%rsi
   121cf:	83 e3 3f             	and    $0x3f,%ebx
   121d2:	4c 01 f6             	add    %r14,%rsi
   121d5:	e8 46 db ff ff       	call   fd20 <_ZN10UEFIBridge14RequestHandler17ProcessOneRequestERK11RequestSlotP12ResponseSlot>
   121da:	41 89 5f 14          	mov    %ebx,0x14(%r15)
   121de:	49 8b 47 28          	mov    0x28(%r15),%rax
   121e2:	48 83 c0 01          	add    $0x1,%rax
   121e6:	49 89 47 28          	mov    %rax,0x28(%r15)
   121ea:	41 8b 47 10          	mov    0x10(%r15),%eax
   121ee:	39 c3                	cmp    %eax,%ebx
   121f0:	75 ce                	jne    121c0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x180>
   121f2:	49 8b 47 20          	mov    0x20(%r15),%rax
   121f6:	48 83 c0 01          	add    $0x1,%rax
   121fa:	49 89 47 20          	mov    %rax,0x20(%r15)
   121fe:	48 8b 15 13 ab 00 00 	mov    0xab13(%rip),%rdx        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   12205:	c6 45 31 00          	movb   $0x0,0x31(%rbp)
   12209:	48 89 d5             	mov    %rdx,%rbp
   1220c:	48 8b 45 08          	mov    0x8(%rbp),%rax
   12210:	48 85 c0             	test   %rax,%rax
   12213:	0f 85 ca fe ff ff    	jne    120e3 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0xa3>
   12219:	8b 05 69 af 00 00    	mov    0xaf69(%rip),%eax        # 1d188 <_ZN10UEFIBridge14g_diag_va_doneE>
   1221f:	85 c0                	test   %eax,%eax
   12221:	0f 84 c9 01 00 00    	je     123f0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x3b0>
   12227:	8b 05 6b af 00 00    	mov    0xaf6b(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   1222d:	49 b8 03 00 00 00 00 	movabs $0x8000000000000003,%r8
   12234:	00 00 80 
   12237:	83 f8 08             	cmp    $0x8,%eax
   1223a:	0f 87 d5 fe ff ff    	ja     12115 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0xd5>
   12240:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12245:	b8 0d 00 00 00       	mov    $0xd,%eax
   1224a:	ee                   	out    %al,(%dx)
   1224b:	b8 0a 00 00 00       	mov    $0xa,%eax
   12250:	ee                   	out    %al,(%dx)
   12251:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12256:	48 8d 0d a3 1d 00 00 	lea    0x1da3(%rip),%rcx        # 14000 <_data>
   1225d:	0f 1f 00             	nopl   (%rax)
   12260:	48 83 c1 01          	add    $0x1,%rcx
   12264:	ee                   	out    %al,(%dx)
   12265:	0f b6 01             	movzbl (%rcx),%eax
   12268:	84 c0                	test   %al,%al
   1226a:	75 f4                	jne    12260 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x220>
   1226c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12271:	ee                   	out    %al,(%dx)
   12272:	b8 48 00 00 00       	mov    $0x48,%eax
   12277:	48 8d 0d 90 20 00 00 	lea    0x2090(%rip),%rcx        # 1430e <_data+0x30e>
   1227e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12283:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1228a:	00 00 00 00 
   1228e:	66 90                	xchg   %ax,%ax
   12290:	48 83 c1 01          	add    $0x1,%rcx
   12294:	ee                   	out    %al,(%dx)
   12295:	0f b6 01             	movzbl (%rcx),%eax
   12298:	84 c0                	test   %al,%al
   1229a:	75 f4                	jne    12290 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x250>
   1229c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   122a1:	ee                   	out    %al,(%dx)
   122a2:	b8 20 00 00 00       	mov    $0x20,%eax
   122a7:	ee                   	out    %al,(%dx)
   122a8:	b8 54 00 00 00       	mov    $0x54,%eax
   122ad:	ee                   	out    %al,(%dx)
   122ae:	b8 20 00 00 00       	mov    $0x20,%eax
   122b3:	48 8d 0d 95 20 00 00 	lea    0x2095(%rip),%rcx        # 1434f <_data+0x34f>
   122ba:	ba f8 03 00 00       	mov    $0x3f8,%edx
   122bf:	90                   	nop
   122c0:	48 83 c1 01          	add    $0x1,%rcx
   122c4:	ee                   	out    %al,(%dx)
   122c5:	0f b6 01             	movzbl (%rcx),%eax
   122c8:	84 c0                	test   %al,%al
   122ca:	75 f4                	jne    122c0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x280>
   122cc:	b8 30 00 00 00       	mov    $0x30,%eax
   122d1:	ee                   	out    %al,(%dx)
   122d2:	b9 18 00 00 00       	mov    $0x18,%ecx
   122d7:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   122dd:	ba f8 03 00 00       	mov    $0x3f8,%edx
   122e2:	4c 8d 0d f7 2a 00 00 	lea    0x2af7(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   122e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   122f0:	44 89 c0             	mov    %r8d,%eax
   122f3:	d3 e8                	shr    %cl,%eax
   122f5:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   122fa:	ee                   	out    %al,(%dx)
   122fb:	83 e9 04             	sub    $0x4,%ecx
   122fe:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   12301:	75 ed                	jne    122f0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x2b0>
   12303:	49 b8 03 00 00 00 00 	movabs $0x8000000000000003,%r8
   1230a:	00 00 80 
   1230d:	e9 03 fe ff ff       	jmp    12115 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0xd5>
   12312:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   12318:	8b 05 7a ae 00 00    	mov    0xae7a(%rip),%eax        # 1d198 <_ZN10UEFIBridge17g_diag_hook_callsE>
   1231e:	83 f8 08             	cmp    $0x8,%eax
   12321:	0f 87 ee fd ff ff    	ja     12115 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0xd5>
   12327:	ba f8 03 00 00       	mov    $0x3f8,%edx
   1232c:	b8 0d 00 00 00       	mov    $0xd,%eax
   12331:	ee                   	out    %al,(%dx)
   12332:	b8 0a 00 00 00       	mov    $0xa,%eax
   12337:	ee                   	out    %al,(%dx)
   12338:	b8 5b 00 00 00       	mov    $0x5b,%eax
   1233d:	48 8d 0d bc 1c 00 00 	lea    0x1cbc(%rip),%rcx        # 14000 <_data>
   12344:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1234b:	00 00 00 00 
   1234f:	90                   	nop
   12350:	48 83 c1 01          	add    $0x1,%rcx
   12354:	ee                   	out    %al,(%dx)
   12355:	0f b6 01             	movzbl (%rcx),%eax
   12358:	84 c0                	test   %al,%al
   1235a:	75 f4                	jne    12350 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x310>
   1235c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12361:	ee                   	out    %al,(%dx)
   12362:	b8 48 00 00 00       	mov    $0x48,%eax
   12367:	48 8d 0d a0 1f 00 00 	lea    0x1fa0(%rip),%rcx        # 1430e <_data+0x30e>
   1236e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12373:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1237a:	00 00 00 00 
   1237e:	66 90                	xchg   %ax,%ax
   12380:	48 83 c1 01          	add    $0x1,%rcx
   12384:	ee                   	out    %al,(%dx)
   12385:	0f b6 01             	movzbl (%rcx),%eax
   12388:	84 c0                	test   %al,%al
   1238a:	75 f4                	jne    12380 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x340>
   1238c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   12391:	ee                   	out    %al,(%dx)
   12392:	b8 20 00 00 00       	mov    $0x20,%eax
   12397:	ee                   	out    %al,(%dx)
   12398:	b8 54 00 00 00       	mov    $0x54,%eax
   1239d:	ee                   	out    %al,(%dx)
   1239e:	b8 20 00 00 00       	mov    $0x20,%eax
   123a3:	48 8d 0d a5 1f 00 00 	lea    0x1fa5(%rip),%rcx        # 1434f <_data+0x34f>
   123aa:	ba f8 03 00 00       	mov    $0x3f8,%edx
   123af:	90                   	nop
   123b0:	48 83 c1 01          	add    $0x1,%rcx
   123b4:	ee                   	out    %al,(%dx)
   123b5:	0f b6 01             	movzbl (%rcx),%eax
   123b8:	84 c0                	test   %al,%al
   123ba:	75 f4                	jne    123b0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x370>
   123bc:	45 89 c2             	mov    %r8d,%r10d
   123bf:	b9 1c 00 00 00       	mov    $0x1c,%ecx
   123c4:	ba f8 03 00 00       	mov    $0x3f8,%edx
   123c9:	4c 8d 0d 10 2a 00 00 	lea    0x2a10(%rip),%r9        # 14de0 <_ZZN10UEFIBridge11SerialTrace5Hex32EjE1k>
   123d0:	44 89 d0             	mov    %r10d,%eax
   123d3:	d3 e8                	shr    %cl,%eax
   123d5:	83 e0 0f             	and    $0xf,%eax
   123d8:	41 0f b6 04 01       	movzbl (%r9,%rax,1),%eax
   123dd:	ee                   	out    %al,(%dx)
   123de:	83 e9 04             	sub    $0x4,%ecx
   123e1:	83 f9 fc             	cmp    $0xfffffffc,%ecx
   123e4:	75 ea                	jne    123d0 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x390>
   123e6:	e9 2a fd ff ff       	jmp    12115 <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0xd5>
   123eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   123f0:	8b 05 8e ad 00 00    	mov    0xad8e(%rip),%eax        # 1d184 <_ZN10UEFIBridge17g_diag_boot_callsE>
   123f6:	e9 32 fe ff ff       	jmp    1222d <_ZN10UEFIBridge11RuntimeHook13HookedGetTimeEP8EFI_TIMEP21EFI_TIME_CAPABILITIES+0x1ed>
   123fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000012400 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE>:
   12400:	41 55                	push   %r13
   12402:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12407:	b8 0d 00 00 00       	mov    $0xd,%eax
   1240c:	41 54                	push   %r12
   1240e:	55                   	push   %rbp
   1240f:	48 89 fd             	mov    %rdi,%rbp
   12412:	53                   	push   %rbx
   12413:	48 83 ec 08          	sub    $0x8,%rsp
   12417:	ee                   	out    %al,(%dx)
   12418:	b8 0a 00 00 00       	mov    $0xa,%eax
   1241d:	ee                   	out    %al,(%dx)
   1241e:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12423:	48 8d 0d d6 1b 00 00 	lea    0x1bd6(%rip),%rcx        # 14000 <_data>
   1242a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   12430:	48 83 c1 01          	add    $0x1,%rcx
   12434:	ee                   	out    %al,(%dx)
   12435:	0f b6 01             	movzbl (%rcx),%eax
   12438:	84 c0                	test   %al,%al
   1243a:	75 f4                	jne    12430 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x30>
   1243c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12441:	ee                   	out    %al,(%dx)
   12442:	b8 56 00 00 00       	mov    $0x56,%eax
   12447:	48 8d 0d dd 1b 00 00 	lea    0x1bdd(%rip),%rcx        # 1402b <_data+0x2b>
   1244e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12453:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1245a:	00 00 00 00 
   1245e:	66 90                	xchg   %ax,%ax
   12460:	48 83 c1 01          	add    $0x1,%rcx
   12464:	ee                   	out    %al,(%dx)
   12465:	0f b6 01             	movzbl (%rcx),%eax
   12468:	84 c0                	test   %al,%al
   1246a:	75 f4                	jne    12460 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x60>
   1246c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   12471:	ee                   	out    %al,(%dx)
   12472:	b8 20 00 00 00       	mov    $0x20,%eax
   12477:	ee                   	out    %al,(%dx)
   12478:	b8 43 00 00 00       	mov    $0x43,%eax
   1247d:	48 8d 0d 05 1f 00 00 	lea    0x1f05(%rip),%rcx        # 14389 <_data+0x389>
   12484:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12489:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   12490:	48 83 c1 01          	add    $0x1,%rcx
   12494:	ee                   	out    %al,(%dx)
   12495:	0f b6 01             	movzbl (%rcx),%eax
   12498:	84 c0                	test   %al,%al
   1249a:	75 f4                	jne    12490 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x90>
   1249c:	4c 8d 2d 7d ad 00 00 	lea    0xad7d(%rip),%r13        # 1d220 <RT>
   124a3:	49 8b 45 00          	mov    0x0(%r13),%rax
   124a7:	48 8b 58 40          	mov    0x40(%rax),%rbx
   124ab:	48 85 ed             	test   %rbp,%rbp
   124ae:	0f 84 36 01 00 00    	je     125ea <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x1ea>
   124b4:	4c 8b 65 28          	mov    0x28(%rbp),%r12
   124b8:	4d 85 e4             	test   %r12,%r12
   124bb:	74 76                	je     12533 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x133>
   124bd:	48 8d 15 f2 1e 00 00 	lea    0x1ef2(%rip),%rdx        # 143b6 <_data+0x3b6>
   124c4:	4c 89 e6             	mov    %r12,%rsi
   124c7:	48 89 df             	mov    %rbx,%rdi
   124ca:	e8 21 a7 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   124cf:	49 8d 74 24 08       	lea    0x8(%r12),%rsi
   124d4:	48 8d 15 e7 1e 00 00 	lea    0x1ee7(%rip),%rdx        # 143c2 <_data+0x3c2>
   124db:	48 89 df             	mov    %rbx,%rdi
   124de:	e8 0d a7 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   124e3:	49 8d 74 24 10       	lea    0x10(%r12),%rsi
   124e8:	48 8d 15 e5 1e 00 00 	lea    0x1ee5(%rip),%rdx        # 143d4 <_data+0x3d4>
   124ef:	48 89 df             	mov    %rbx,%rdi
   124f2:	e8 f9 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   124f7:	49 8d 74 24 18       	lea    0x18(%r12),%rsi
   124fc:	48 8d 15 e7 1e 00 00 	lea    0x1ee7(%rip),%rdx        # 143ea <_data+0x3ea>
   12503:	48 89 df             	mov    %rbx,%rdi
   12506:	e8 e5 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   1250b:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
   12510:	48 8d 15 e9 1e 00 00 	lea    0x1ee9(%rip),%rdx        # 14400 <_data+0x400>
   12517:	48 89 df             	mov    %rbx,%rdi
   1251a:	e8 d1 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   1251f:	49 8d 74 24 28       	lea    0x28(%r12),%rsi
   12524:	48 8d 15 e7 1e 00 00 	lea    0x1ee7(%rip),%rdx        # 14412 <_data+0x412>
   1252b:	48 89 df             	mov    %rbx,%rdi
   1252e:	e8 bd a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   12533:	4c 8b 65 20          	mov    0x20(%rbp),%r12
   12537:	4d 85 e4             	test   %r12,%r12
   1253a:	74 3a                	je     12576 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x176>
   1253c:	48 8d 15 e3 1e 00 00 	lea    0x1ee3(%rip),%rdx        # 14426 <_data+0x426>
   12543:	4c 89 e6             	mov    %r12,%rsi
   12546:	48 89 df             	mov    %rbx,%rdi
   12549:	e8 a2 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   1254e:	49 8d 74 24 08       	lea    0x8(%r12),%rsi
   12553:	48 8d 15 d5 1e 00 00 	lea    0x1ed5(%rip),%rdx        # 1442f <_data+0x42f>
   1255a:	48 89 df             	mov    %rbx,%rdi
   1255d:	e8 8e a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   12562:	49 8d 74 24 10       	lea    0x10(%r12),%rsi
   12567:	48 8d 15 c9 1e 00 00 	lea    0x1ec9(%rip),%rdx        # 14437 <_data+0x437>
   1256e:	48 89 df             	mov    %rbx,%rdi
   12571:	e8 7a a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   12576:	48 8b 75 18          	mov    0x18(%rbp),%rsi
   1257a:	48 85 f6             	test   %rsi,%rsi
   1257d:	74 0f                	je     1258e <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x18e>
   1257f:	48 8d 15 bc 1e 00 00 	lea    0x1ebc(%rip),%rdx        # 14442 <_data+0x442>
   12586:	48 89 df             	mov    %rbx,%rdi
   12589:	e8 62 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   1258e:	48 8b 75 10          	mov    0x10(%rbp),%rsi
   12592:	48 85 f6             	test   %rsi,%rsi
   12595:	74 0f                	je     125a6 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x1a6>
   12597:	48 8d 15 ad 1e 00 00 	lea    0x1ead(%rip),%rdx        # 1444b <_data+0x44b>
   1259e:	48 89 df             	mov    %rbx,%rdi
   125a1:	e8 4a a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   125a6:	48 8b 6d 08          	mov    0x8(%rbp),%rbp
   125aa:	48 85 ed             	test   %rbp,%rbp
   125ad:	74 25                	je     125d4 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x1d4>
   125af:	48 8d 75 10          	lea    0x10(%rbp),%rsi
   125b3:	48 8d 15 9a 1e 00 00 	lea    0x1e9a(%rip),%rdx        # 14454 <_data+0x454>
   125ba:	48 89 df             	mov    %rbx,%rdi
   125bd:	e8 2e a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   125c2:	48 8d 15 97 1e 00 00 	lea    0x1e97(%rip),%rdx        # 14460 <_data+0x460>
   125c9:	48 89 ee             	mov    %rbp,%rsi
   125cc:	48 89 df             	mov    %rbx,%rdi
   125cf:	e8 1c a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   125d4:	48 8d 15 94 1e 00 00 	lea    0x1e94(%rip),%rdx        # 1446f <_data+0x46f>
   125db:	48 8d 35 36 a7 00 00 	lea    0xa736(%rip),%rsi        # 1cd18 <_ZN10UEFIBridge11RuntimeHook9instance_E>
   125e2:	48 89 df             	mov    %rbx,%rdi
   125e5:	e8 06 a6 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   125ea:	4c 89 ee             	mov    %r13,%rsi
   125ed:	48 89 df             	mov    %rbx,%rdi
   125f0:	48 8d 15 36 1d 00 00 	lea    0x1d36(%rip),%rdx        # 1432d <_data+0x32d>
   125f7:	e8 f4 a5 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   125fc:	48 8d 35 d5 ab 00 00 	lea    0xabd5(%rip),%rsi        # 1d1d8 <ST>
   12603:	48 8d 15 1d 1d 00 00 	lea    0x1d1d(%rip),%rdx        # 14327 <_data+0x327>
   1260a:	48 89 df             	mov    %rbx,%rdi
   1260d:	e8 de a5 ff ff       	call   cbf0 <_ZN10UEFIBridge6CvtOneEPU6ms_abiFmmPPvES1_PKc>
   12612:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12617:	b8 0d 00 00 00       	mov    $0xd,%eax
   1261c:	83 0d 89 ab 00 00 04 	orl    $0x4,0xab89(%rip)        # 1d1ac <_ZN10UEFIBridge12g_diag_flagsE>
   12623:	ee                   	out    %al,(%dx)
   12624:	b8 0a 00 00 00       	mov    $0xa,%eax
   12629:	ee                   	out    %al,(%dx)
   1262a:	b8 5b 00 00 00       	mov    $0x5b,%eax
   1262f:	48 8d 0d ca 19 00 00 	lea    0x19ca(%rip),%rcx        # 14000 <_data>
   12636:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1263d:	00 00 00 
   12640:	48 83 c1 01          	add    $0x1,%rcx
   12644:	ee                   	out    %al,(%dx)
   12645:	0f b6 01             	movzbl (%rcx),%eax
   12648:	84 c0                	test   %al,%al
   1264a:	75 f4                	jne    12640 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x240>
   1264c:	b8 5b 00 00 00       	mov    $0x5b,%eax
   12651:	ee                   	out    %al,(%dx)
   12652:	b8 56 00 00 00       	mov    $0x56,%eax
   12657:	48 8d 0d cd 19 00 00 	lea    0x19cd(%rip),%rcx        # 1402b <_data+0x2b>
   1265e:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12663:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1266a:	00 00 00 00 
   1266e:	66 90                	xchg   %ax,%ax
   12670:	48 83 c1 01          	add    $0x1,%rcx
   12674:	ee                   	out    %al,(%dx)
   12675:	0f b6 01             	movzbl (%rcx),%eax
   12678:	84 c0                	test   %al,%al
   1267a:	75 f4                	jne    12670 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x270>
   1267c:	b8 5d 00 00 00       	mov    $0x5d,%eax
   12681:	ee                   	out    %al,(%dx)
   12682:	b8 20 00 00 00       	mov    $0x20,%eax
   12687:	ee                   	out    %al,(%dx)
   12688:	b8 43 00 00 00       	mov    $0x43,%eax
   1268d:	48 8d 0d 0c 1d 00 00 	lea    0x1d0c(%rip),%rcx        # 143a0 <_data+0x3a0>
   12694:	ba f8 03 00 00       	mov    $0x3f8,%edx
   12699:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   126a0:	48 83 c1 01          	add    $0x1,%rcx
   126a4:	ee                   	out    %al,(%dx)
   126a5:	0f b6 01             	movzbl (%rcx),%eax
   126a8:	84 c0                	test   %al,%al
   126aa:	75 f4                	jne    126a0 <_ZN10UEFIBridge18ConvertPointersAllEPNS_12ConvertGraphE+0x2a0>
   126ac:	48 83 c4 08          	add    $0x8,%rsp
   126b0:	5b                   	pop    %rbx
   126b1:	5d                   	pop    %rbp
   126b2:	41 5c                	pop    %r12
   126b4:	41 5d                	pop    %r13
   126b6:	c3                   	ret
   126b7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   126be:	00 00 

00000000000126c0 <_GLOBAL__sub_I_main.c>:
   126c0:	66 0f ef c0          	pxor   %xmm0,%xmm0
   126c4:	31 c0                	xor    %eax,%eax
   126c6:	48 c7 05 8f 94 00 00 	movq   $0x0,0x948f(%rip)        # 1bb60 <_ZN10UEFIBridgeL14g_runtime_hookE>
   126cd:	00 00 00 00 
   126d1:	48 c7 05 ac 94 00 00 	movq   $0x0,0x94ac(%rip)        # 1bb88 <_ZN10UEFIBridgeL14g_runtime_hookE+0x28>
   126d8:	00 00 00 00 
   126dc:	66 89 05 ad 94 00 00 	mov    %ax,0x94ad(%rip)        # 1bb90 <_ZN10UEFIBridgeL14g_runtime_hookE+0x30>
   126e3:	48 c7 05 ea 94 00 00 	movq   $0x0,0x94ea(%rip)        # 1bbd8 <_ZN10UEFIBridgeL14g_runtime_hookE+0x78>
   126ea:	00 00 00 00 
   126ee:	48 c7 05 e7 a4 00 00 	movq   $0x0,0xa4e7(%rip)        # 1cbe0 <_ZN10UEFIBridgeL14g_runtime_hookE+0x1080>
   126f5:	00 00 00 00 
   126f9:	0f 11 05 68 94 00 00 	movups %xmm0,0x9468(%rip)        # 1bb68 <_ZN10UEFIBridgeL14g_runtime_hookE+0x8>
   12700:	0f 11 05 71 94 00 00 	movups %xmm0,0x9471(%rip)        # 1bb78 <_ZN10UEFIBridgeL14g_runtime_hookE+0x18>
   12707:	c3                   	ret
   12708:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   1270f:	00 

0000000000012710 <_GLOBAL__sub_D_main.c>:
   12710:	48 8b 0d 01 a5 00 00 	mov    0xa501(%rip),%rcx        # 1cc18 <_ZN10UEFIBridgeL9g_handlerE+0x18>
   12717:	48 85 c9             	test   %rcx,%rcx
   1271a:	74 2a                	je     12746 <_GLOBAL__sub_D_main.c+0x36>
   1271c:	53                   	push   %rbx
   1271d:	48 8d 1d ac aa 00 00 	lea    0xaaac(%rip),%rbx        # 1d1d0 <BS>
   12724:	45 31 c0             	xor    %r8d,%r8d
   12727:	31 d2                	xor    %edx,%edx
   12729:	48 8b 03             	mov    (%rbx),%rax
   1272c:	48 83 ec 20          	sub    $0x20,%rsp
   12730:	ff 50 58             	call   *0x58(%rax)
   12733:	48 8b 03             	mov    (%rbx),%rax
   12736:	48 8b 0d db a4 00 00 	mov    0xa4db(%rip),%rcx        # 1cc18 <_ZN10UEFIBridgeL9g_handlerE+0x18>
   1273d:	ff 50 70             	call   *0x70(%rax)
   12740:	48 83 c4 20          	add    $0x20,%rsp
   12744:	5b                   	pop    %rbx
   12745:	c3                   	ret
   12746:	c3                   	ret
   12747:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   1274e:	00 00 
